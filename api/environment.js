'use strict';

const https = require('node:https');

const localDevelopment = process.env.VERCEL_ENV === 'development'
  || (!process.env.VERCEL_ENV && process.env.NODE_ENV !== 'production');

if (localDevelopment) {
  try {
    process.loadEnvFile('.env.local');
  } catch (error) {
    if (error && error.code !== 'ENOENT') throw error;
  }
}

const API_HOST = 'api.weatherapi.com';
const API_PATH = '/v1/current.json';
const REQUEST_TIMEOUT_MS = positiveInt(process.env.WEATHER_TIMEOUT_MS, 10000, 1000, 10000);
const TOTAL_REQUEST_BUDGET_MS = positiveInt(process.env.WEATHER_TOTAL_TIMEOUT_MS, 15000, 2000, 30000);
const RETRY_DELAY_MS = positiveInt(process.env.WEATHER_RETRY_DELAY_MS, 300, 100, 2000);
const CACHE_TTL_MS = positiveInt(process.env.CACHE_TTL_MS, 5 * 60 * 1000, 1000, 60 * 60 * 1000);
const MAX_CACHE_ENTRIES = positiveInt(process.env.MAX_CACHE_ENTRIES, 256, 8, 5000);
const MAX_CONCURRENT_UPSTREAM = positiveInt(process.env.MAX_CONCURRENT_UPSTREAM, 8, 1, 100);
const GLOBAL_REQUESTS_PER_MINUTE = positiveInt(process.env.UPSTREAM_REQUESTS_PER_MINUTE, 60, 1, 10000);
const IP_REQUESTS_PER_MINUTE = positiveInt(process.env.IP_REQUESTS_PER_MINUTE, 30, 1, 1000);
const MAX_IP_BUCKETS = positiveInt(process.env.MAX_IP_BUCKETS, 5000, 100, 50000);
const ALLOWED_ORIGINS = parseOrigins(process.env.CORS_ORIGINS);
const WEATHER_API_KEY = process.env.WEATHER_API_KEY;

const cache = new Map();
const inflight = new Map();
const ipBuckets = new Map();
const globalBucket = { started: 0, count: 0 };
let activeUpstream = 0;

function positiveInt(value, fallback, min, max) {
  const n = Number.parseInt(value || '', 10);
  return Number.isInteger(n) && n >= min && n <= max ? n : fallback;
}

function parseOrigins(value) {
  if (!value) return new Set();
  return new Set(value.split(',').map((item) => item.trim()).filter(Boolean));
}

function errorBody(code, message) {
  return { error: { code, message } };
}

function json(res, status, body, extraHeaders = {}) {
  res.statusCode = status;
  for (const [name, value] of Object.entries(extraHeaders)) res.setHeader(name, value);
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.end(JSON.stringify(body));
}

function corsHeaders(req) {
  const origin = req.headers.origin;
  if (!origin || !ALLOWED_ORIGINS.has(origin)) return {};
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Accept, Content-Type',
    Vary: 'Origin',
  };
}

function clientAddress(req) {
  // Vercel supplies these platform headers. Use them only for per-instance throttling.
  const realIp = req.headers['x-real-ip'];
  if (typeof realIp === 'string' && realIp.trim()) return realIp.trim();
  const forwarded = req.headers['x-forwarded-for'];
  if (typeof forwarded === 'string' && forwarded.trim()) return forwarded.split(',')[0].trim();
  return 'unknown';
}

function allowRate(bucket, limit, now) {
  if (now - bucket.started >= 60000) {
    bucket.started = now;
    bucket.count = 0;
  }
  if (bucket.count >= limit) return false;
  bucket.count += 1;
  return true;
}

function rateLimit(req) {
  const now = Date.now();
  if (!globalBucket.started) globalBucket.started = now;
  if (!allowRate(globalBucket, GLOBAL_REQUESTS_PER_MINUTE, now)) return { retryAfter: 60 };
  const ip = clientAddress(req);
  let bucket = ipBuckets.get(ip);
  if (!bucket) {
    if (ipBuckets.size >= MAX_IP_BUCKETS) ipBuckets.delete(ipBuckets.keys().next().value);
    bucket = { started: now, count: 0 };
    ipBuckets.set(ip, bucket);
  }
  if (!allowRate(bucket, IP_REQUESTS_PER_MINUTE, now)) return { retryAfter: 60 };
  return null;
}

function parseQuery(url) {
  const params = new URLSearchParams(url.search);
  const entries = [...params.entries()];
  if (entries.length !== 1 || entries[0][0] !== 'q') return null;
  const query = entries[0][1].trim();
  if (!query || query.length > 120 || /[\u0000-\u001f\u007f]/u.test(query)) return null;
  if (/^[-+]?\d+(?:\.\d+)?\s*,\s*[-+]?\d+(?:\.\d+)?$/u.test(query)) {
    const [latText, lonText] = query.split(',').map((part) => part.trim());
    const lat = Number(latText);
    const lon = Number(lonText);
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return { raw: query, normalized: `${lat},${lon}` };
  }
  if (!/^[\p{L}\p{N}][\p{L}\p{N} .,'()\-_/]*$/u.test(query)) return null;
  return { raw: query, normalized: query.toLocaleLowerCase('en-US').replace(/\s+/gu, ' ') };
}

function publicWeather(body) {
  if (!body || typeof body !== 'object' || !body.location || !body.current) return null;
  const locationName = body.location.name;
  const localtime = body.location.localtime;
  const current = body.current;
  const condition = current.condition;
  const air = current.air_quality;
  if (typeof locationName !== 'string' || typeof localtime !== 'string' || !condition || typeof condition !== 'object') return null;
  const finite = (value) => typeof value === 'number' && Number.isFinite(value) ? value : undefined;
  const safeCondition = {};
  if (typeof condition.text === 'string') safeCondition.text = condition.text;
  if (Number.isInteger(condition.code)) safeCondition.code = condition.code;
  const safeAir = {};
  if (finite(air && air.pm2_5) !== undefined) safeAir.pm2_5 = finite(air.pm2_5);
  if (finite(air && air.pm10) !== undefined) safeAir.pm10 = finite(air.pm10);
  const safeCurrent = { condition: safeCondition, air_quality: safeAir };
  for (const [key, value] of [['temp_c', current.temp_c], ['humidity', current.humidity], ['uv', current.uv]]) {
    if (finite(value) !== undefined) safeCurrent[key] = finite(value);
  }
  if (!Object.keys(safeCondition).length && !Object.keys(safeAir).length && !Object.keys(safeCurrent).some((key) => key !== 'condition' && key !== 'air_quality')) return null;
  return { location: { name: locationName, localtime }, current: safeCurrent };
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function upstream(query, timeoutMs) {
  return new Promise((resolve, reject) => {
    const params = new URLSearchParams({ key: WEATHER_API_KEY, q: query, aqi: 'yes' });
    const request = https.get({ hostname: API_HOST, path: `${API_PATH}?${params}`, method: 'GET', headers: { Accept: 'application/json' } }, (response) => {
      let data = '';
      response.setEncoding('utf8');
      response.on('data', (chunk) => { if (data.length < 1024 * 1024) data += chunk; });
      response.on('end', () => resolve({ status: response.statusCode || 0, body: data }));
    });
    request.setTimeout(timeoutMs, () => request.destroy(new Error('timeout')));
    request.on('error', reject);
  });
}

function parseUpstreamResponse(response) {
  if (response.status === 404) {
    return { retryable: false, result: { status: 404, error: errorBody('location_not_found', 'Location not found') } };
  }
  if (response.status === 429) {
    return { retryable: false, result: { status: 429, retryAfter: 60, error: errorBody('rate_limited', 'Weather service rate limit reached') } };
  }
  if (response.status >= 500) {
    const timeout = response.status === 504;
    return {
      retryable: true,
      result: { status: timeout ? 504 : 502, error: errorBody(timeout ? 'upstream_timeout' : 'upstream_unavailable', timeout ? 'Weather service timed out' : 'Weather service unavailable') },
    };
  }
  let body;
  try { body = JSON.parse(response.body); } catch {
    return { retryable: false, result: { status: 502, error: errorBody('invalid_response', 'Weather service returned invalid data') } };
  }
  const upstreamError = body && typeof body === 'object' ? body.error : null;
  if (upstreamError && [2007, 2008, 2009].includes(upstreamError.code)) {
    return { retryable: false, result: { status: 429, retryAfter: 60, error: errorBody('rate_limited', 'Weather service rate limit reached') } };
  }
  if (upstreamError && upstreamError.code === 1006) {
    return { retryable: false, result: { status: 404, error: errorBody('location_not_found', 'Location not found') } };
  }
  if (response.status < 200 || response.status >= 300) {
    return { retryable: false, result: { status: 502, error: errorBody('upstream_unavailable', 'Weather service unavailable') } };
  }
  const safe = publicWeather(body);
  if (!safe) {
    return { retryable: false, result: { status: 502, error: errorBody('invalid_response', 'Weather service returned incomplete data') } };
  }
  return { retryable: false, result: { status: 200, body: safe } };
}

async function fetchWeather(query, options = {}) {
  const cached = cache.get(query.normalized);
  if (cached && cached.expires > Date.now()) return { status: 200, body: cached.body };
  if (cached) cache.delete(query.normalized);
  if (inflight.has(query.normalized)) return inflight.get(query.normalized);
  if (activeUpstream >= MAX_CONCURRENT_UPSTREAM) return { status: 503, error: errorBody('upstream_unavailable', 'Weather service temporarily unavailable') };
  const task = (async () => {
    activeUpstream += 1;
    try {
      const request = options.request || upstream;
      const now = options.now || Date.now;
      const sleep = options.wait || wait;
      const random = options.random || Math.random;
      const attemptTimeoutMs = options.attemptTimeoutMs || REQUEST_TIMEOUT_MS;
      const totalBudgetMs = options.totalBudgetMs || TOTAL_REQUEST_BUDGET_MS;
      const retryDelayMs = options.retryDelayMs || RETRY_DELAY_MS;
      const started = now();
      let lastResult;

      for (let attempt = 0; attempt < 2; attempt += 1) {
        const remaining = totalBudgetMs - (now() - started);
        if (remaining <= 0) break;
        try {
          const response = await request(query.raw, Math.min(attemptTimeoutMs, remaining));
          const outcome = parseUpstreamResponse(response);
          lastResult = outcome.result;
          if (!outcome.retryable || attempt === 1) break;
        } catch (err) {
          const timeout = err && err.message === 'timeout';
          lastResult = { status: timeout ? 504 : 502, error: errorBody(timeout ? 'upstream_timeout' : 'upstream_unavailable', timeout ? 'Weather service timed out' : 'Weather service unavailable') };
          if (attempt === 1) break;
        }

        const budgetAfterAttempt = totalBudgetMs - (now() - started);
        const retryDelay = Math.min(retryDelayMs + Math.floor(random() * 201), Math.max(0, budgetAfterAttempt - 1));
        if (retryDelay <= 0) break;
        await sleep(retryDelay);
      }

      const result = lastResult || { status: 504, error: errorBody('upstream_timeout', 'Weather service timed out') };
      if (result.status === 200) {
        cache.set(query.normalized, { expires: Date.now() + CACHE_TTL_MS, body: result.body });
        while (cache.size > MAX_CACHE_ENTRIES) cache.delete(cache.keys().next().value);
      }
      return result;
    } finally { activeUpstream -= 1; }
  })();
  inflight.set(query.normalized, task);
  try { return await task; } finally { inflight.delete(query.normalized); }
}

async function handler(req, res) {
  const headers = corsHeaders(req);
  let url;
  try { url = new URL(req.url || '', 'https://vercel.local'); } catch { return json(res, 404, errorBody('invalid_request', 'Invalid request'), headers); }
  if (url.pathname !== '/api/environment') return json(res, 404, errorBody('not_found', 'Not found'), headers);
  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    for (const [name, value] of Object.entries(headers)) res.setHeader(name, value);
    return res.end();
  }
  if (req.method !== 'GET') return json(res, 405, errorBody('method_not_allowed', 'Method not allowed'), { ...headers, Allow: 'GET, OPTIONS' });
  if (!WEATHER_API_KEY) return json(res, 503, errorBody('server_misconfigured', 'Weather service is not configured'), headers);
  const query = parseQuery(url);
  if (!query) return json(res, 400, errorBody('invalid_query', 'Query must contain one valid q parameter'), headers);
  const limited = rateLimit(req);
  if (limited) return json(res, 429, errorBody('rate_limited', 'Too many requests'), { ...headers, 'Retry-After': String(limited.retryAfter) });
  const result = await fetchWeather(query);
  return json(res, result.status, result.error || result.body, result.retryAfter ? { ...headers, 'Retry-After': String(result.retryAfter) } : headers);
}

module.exports = handler;
module.exports._test = { fetchWeather, parseUpstreamResponse };
