'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const { fetchWeather, publicWeather, parseQuery } = require('./environment')._test;

const successBody = JSON.stringify({
  location: { name: 'Tangerang', localtime: '2026-09-22 12:00' },
  current: {
    condition: { text: 'Clear', code: 1000 },
    air_quality: { pm2_5: 10, pm10: 15 },
    temp_c: 30,
    humidity: 60,
    uv: 4,
  },
});

function query(suffix) {
  return { raw: `Tangerang-${suffix}`, normalized: `tangerang-${suffix}` };
}

test('retries one transient timeout and returns successful response', async () => {
  let attempts = 0;
  const result = await fetchWeather(query('retry'), {
    request: async () => {
      attempts += 1;
      if (attempts === 1) throw new Error('timeout');
      return { status: 200, body: successBody };
    },
    retryDelayMs: 1,
    random: () => 0,
  });

  assert.equal(attempts, 2);
  assert.equal(result.status, 200);
  assert.equal(result.body.location.name, 'Tangerang');
});

test('does not retry permanent upstream errors', async () => {
  let attempts = 0;
  const result = await fetchWeather(query('not-found'), {
    request: async () => {
      attempts += 1;
      return { status: 404, body: '{}' };
    },
  });

  assert.equal(attempts, 1);
  assert.equal(result.status, 404);
  assert.equal(result.error.error.code, 'location_not_found');
});

test('second attempt uses remaining total time budget', async () => {
  let clock = 0;
  const timeouts = [];
  let attempts = 0;
  const result = await fetchWeather(query('budget'), {
    attemptTimeoutMs: 8000,
    totalBudgetMs: 15000,
    retryDelayMs: 300,
    random: () => 0,
    now: () => clock,
    wait: async (ms) => { clock += ms; },
    request: async (_query, timeoutMs) => {
      attempts += 1;
      timeouts.push(timeoutMs);
      if (attempts === 1) {
        clock += timeoutMs;
        throw new Error('timeout');
      }
      return { status: 200, body: successBody };
    },
  });

  assert.equal(result.status, 200);
  assert.deepEqual(timeouts, [8000, 6700]);
});

test('passes through day/night flag and drops invalid values', () => {
  const body = (isDay) => ({
    location: { name: 'Jakarta', localtime: '2026-11-11 12:00' },
    current: { condition: { text: 'Sunny', code: 1000 }, temp_c: 31, is_day: isDay },
  });

  assert.equal(publicWeather(body(1)).current.is_day, 1);
  assert.equal(publicWeather(body(0)).current.is_day, 0);
  assert.equal('is_day' in publicWeather(body('yes')).current, false);
  assert.equal('is_day' in publicWeather(body(2)).current, false);
});

test('rounds coordinates to two decimals for cache and upstream', () => {
  const url = (q) => new URL(`https://x.test/api/environment?q=${encodeURIComponent(q)}`);
  assert.deepEqual(parseQuery(url('-6.200412,106.816633')), { raw: '-6.20,106.82', normalized: '-6.20,106.82' });
  assert.deepEqual(parseQuery(url('-6.2049, 106.8199')), { raw: '-6.20,106.82', normalized: '-6.20,106.82' });
  assert.equal(parseQuery(url('Jakarta')).raw, 'Jakarta');
  assert.equal(parseQuery(url('91,0')), null);
});
