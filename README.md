# LingkunganSehat

**Live app: [app.lingkungansehat.my.id](https://app.lingkungansehat.my.id)**

LingkunganSehat ("Healthy Environment") is a mobile-first web app that rates the outdoor health risk where you are, right now, as *Rendah*, *Sedang* or *Tinggi* (low, moderate, high). It gives short advice in Bahasa Indonesia. It is built for drivers and riders who spend the day outside.

The app uses your GPS position or a city you enter. It combines four hazards:

- **Air quality:** US EPA AQI from PM2.5 and PM10
- **UV:** the WHO UV Index
- **Heat:** the NWS heat index from temperature and humidity, raised one level in direct daytime sun
- **Weather:** thunder, heavy rain, fog and other hazardous conditions

The overall rating is the worst of the four, and data refreshes every five minutes. Ratings are indicative, not medical advice. See [Environmental risk analysis](#environmental-risk-analysis) for thresholds and sources.

**Stack:** Flutter web client, plus a Vercel Node.js function (`api/environment.js`) that proxies WeatherAPI.com so the API key never reaches the browser.

## Local development

Prerequisites:

* Node.js 22.x
* FVM and Flutter stable
* Chrome (for Flutter web)
* Vercel CLI

Install Vercel CLI once:

```sh
npm install -g vercel
```

Set up project dependencies:

```sh
fvm install
fvm flutter pub get
cp -n .env.example .env.local
```

Edit `.env.local`: set `WEATHER_API_KEY` to a local WeatherAPI key. Keep this file local. `CORS_ORIGINS=http://localhost:8080` allows the local Flutter browser origin; do not put `WEATHER_API_KEY` in Flutter `--dart-define`.

On first API run, authenticate and link this directory when Vercel asks:

```sh
vercel login
vercel link
```

Run two terminals:

```sh
# Terminal 1: API
npm run dev:api
```

```sh
# Terminal 2: Flutter web
fvm flutter run -d chrome --web-port 8080 --dart-define=ENVIRONMENT_API_URL=http://localhost:3000/api/environment
```

`npm run dev:api` uses `vercel.dev.json` with `--local-config`. This API-only config disables the production Flutter build and serves the empty `vercel-dev-output` directory, so Vercel dev exposes Functions without serving repository files. Do not replace it with bare `vercel dev`; that invokes the production build path. Restart Terminal 1 after changing `.env.local`.

Optional smoke check:

```sh
curl 'http://localhost:3000/api/environment?q=Jakarta'
```

Client calls `GET /api/environment?q=...`. `ENVIRONMENT_API_URL` defaults to `/api/environment`, so production same-origin builds need no `--dart-define`.

### Check page scrolling

Run Flutter with static demo data and extra recommendations; no API needed:

```sh
fvm flutter run -d chrome --web-port 8080 --dart-define=SCROLL_DEMO=true
```

Use Chrome device toolbar to try a mobile viewport (for example, 320 × 700), then a desktop viewport (1024 × 768). Scroll over the recommendations: the whole page, including the header, should move. `SCROLL_DEMO` works only in debug builds.

## Environment API

`api/environment.js` is a Vercel Node.js Function. Production and Preview use Vercel environment variables: configure `WEATHER_API_KEY` and `CORS_ORIGINS` in Vercel, then deploy with `vercel`. Transient upstream failures receive one retry within a 15-second total budget; `WEATHER_TIMEOUT_MS`, `WEATHER_TOTAL_TIMEOUT_MS`, and `WEATHER_RETRY_DELAY_MS` tune that policy. Deploy build script [`scripts/vercel-build.sh`](scripts/vercel-build.sh) installs FVM-selected Flutter SDK and builds `build/web`; no local key upload is needed.

Function accepts one bounded `q` parameter containing a city or latitude/longitude pair. It uses five-minute in-memory cache, identical in-flight request dedupe, max 256 cache entries, max 8 concurrent upstream calls, single-process global limit 60 upstream requests/minute, and per-IP limit 30 requests/minute with max 5,000 tracked IP buckets. Limits and cache are per Vercel instance, not global across scaled instances; use an external gateway for global enforcement.

It returns stable safe JSON errors: `invalid_query`, `location_not_found`, `rate_limited`, `upstream_timeout`, `upstream_unavailable`, `invalid_response`, and `server_misconfigured`. It does not return API keys, upstream URLs, upstream bodies, or internal error details. CORS uses exact origins; `*` is unsupported. CORS is not auth.

## Reliability

Environment data loads on startup, refreshes every five minutes, stops loading after location, network, or invalid-response failures, preserves last successful readings during refresh failure, and exposes retry. Initial failures provide retry plus manual location entry.

## Environmental risk analysis

The overall risk is the highest of four hazard levels (Rendah, Sedang, Tinggi). Every numeric cut-off below comes from the cited source. How each source's categories group into the three app levels is the app's own mapping. Ratings are indicative, not medical advice.

| Hazard | Rendah | Sedang | Tinggi | Source |
|---|---|---|---|---|
| Air quality (US EPA AQI from PM2.5/PM10) | 0–50 | 51–150 | ≥151 | [EPA AQI breakpoints](https://aqs.epa.gov/aqsweb/documents/codetables/aqi_breakpoints.html) |
| UV Index | 0–2 | 3–7 | ≥8 | [WHO UV Index](https://www.who.int/news-room/questions-and-answers/item/radiation-the-ultraviolet-%28uv%29-index) action levels; dialog labels use the [ICNIRP](https://www.icnirp.org/en/applications/uv-index/index.html) five categories |
| Heat (NWS heat index) | below Extreme Caution (<90 °F / 32.2 °C) | Extreme Caution (90–103 °F) | Danger and above (≥103 °F / 39.4 °C) | [NWS heat index classification](https://www.weather.gov/ama/heatindex) |
| Weather condition | clear, cloud, mist | rain, snow, smoke/haze, fog | thunder, heavy rain/snow, blizzard | [WeatherAPI condition codes](https://www.weatherapi.com/docs/weather_conditions.json), [NWS lightning safety](https://www.weather.gov/safety/lightning-safety) |

- **Direct sun.** NWS heat index values assume shade; full sun can add up to 15 °F. During daylight (`is_day`) with a clear or partly cloudy sky (condition codes 1000/1003), heat risk moves up one NWS level, following OSHA's advice to apply the next highest risk level when working in direct sun ([OSHA, *Using the Heat Index*, archived](https://web.archive.org/web/2013/http://www.osha.gov/SLTC/heatillness/heat_index/protective_measures.html)).
- **Heat fallback.** Without valid humidity, the heat index falls back to air temperature.
- **Humidity is information only.** The card shows the [NWS dew point comfort scale](https://www.weather.gov/arx/heat_index) (≤55 °F dry and comfortable, 55–65 °F sticky, ≥65 °F oppressive), with dew point from the Magnus formula. Humidity's effect on the body is already counted through the heat index.
- **No cold rule.** No credible source supports a cold threshold above freezing for this use case, so cold does not affect the risk.
- **Indicative AQI.** PM2.5/PM10-derived AQI is a single current reading, not an official daily, NowCast, all-pollutant AQI, or Indonesian ISPU.

Invalid or missing readings remain unknown (`null`). Known elevated hazards remain visible when other readings are missing; when every indicator is unknown, UI states risk is unavailable instead of inventing a safe zero. Recommendations stay short and tied to known hazards.

The app's Information screen and each metric dialog link to these sources.

If an actual WeatherAPI key was ever supplied to an old client build or external build system, rotate it there. Repository config previously used an empty `OPENWEATHER_KEY` default; no literal credential is confirmed in tracked source. Rotation does not remove secrets from existing build artifacts or repository history.

## License

[MIT](LICENSE)
