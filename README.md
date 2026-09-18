# HealthyEnvironment App

Flutter web app for outdoor environment risk prevention.

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

## Environment API

`api/environment.js` is a Vercel Node.js Function. Production and Preview use Vercel environment variables: configure `WEATHER_API_KEY` and `CORS_ORIGINS` in Vercel, then deploy with `vercel`. Deploy build script [`scripts/vercel-build.sh`](scripts/vercel-build.sh) installs FVM-selected Flutter SDK and builds `build/web`; no local key upload is needed.

Function accepts one bounded `q` parameter containing a city or latitude/longitude pair. It uses five-minute in-memory cache, identical in-flight request dedupe, max 256 cache entries, max 8 concurrent upstream calls, single-process global limit 60 upstream requests/minute, and per-IP limit 30 requests/minute with max 5,000 tracked IP buckets. Limits and cache are per Vercel instance, not global across scaled instances; use an external gateway for global enforcement.

It returns stable safe JSON errors: `invalid_query`, `location_not_found`, `rate_limited`, `upstream_timeout`, `upstream_unavailable`, `invalid_response`, and `server_misconfigured`. It does not return API keys, upstream URLs, upstream bodies, or internal error details. CORS uses exact origins; `*` is unsupported. CORS is not auth.

## Reliability

Environment data loads on startup, refreshes every five minutes, stops loading after location, network, or invalid-response failures, preserves last successful readings during refresh failure, and exposes retry. Initial failures provide retry plus manual location entry.

Current verification: `fvm flutter analyze` and `fvm flutter test` pass after integration into `dev-overhaul`. Production builds, Android SDK validation, and deployed integration remain pending.

## Environmental risk analysis

Risk uses strongest known hazard across AQI, UV Index, temperature, and weather condition. AQI, UV, and temperature cutoffs are app heuristics: AQI `<51` low, `51–150` moderate, `>=151` high; UV `<3` low, `3–7` moderate, `>=8` high; temperature `15 <= T < 30°C` low, `30 <= T < 35°C` moderate, `T >= 35°C` high, `T < 15°C` moderate, `T <= 0°C` high. Decimal readings stay precise. These are not a validated medical score or probability.

Invalid or missing readings remain unknown (`null`). Known elevated hazards remain visible when other readings are missing; when every indicator is unknown, UI states risk is unavailable instead of inventing a safe zero. Recommendations stay short and tied to known hazards.

AQI guidance references [EPA AQI breakpoints](https://aqs.epa.gov/aqsweb/documents/codetables/aqi_breakpoints.html) and [EPA PM2.5 rounding/truncation guidance](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=P101AP0Q.TXT). UV guidance references [WHO UV Index guidance](https://www.who.int/news-room/questions-and-answers/item/radiation-the-ultraviolet-%28uv%29-index): protection begins at 3+, with midday exposure avoidance at 8+. Weather condition interpretation references [WeatherAPI condition codes](https://www.weatherapi.com/docs/weather_conditions.json), [NWS heat safety](https://www.weather.gov/safety/heat-during), and [NWS lightning safety](https://www.weather.gov/safety/lightning-safety). PM2.5/PM10-derived AQI is a current-sample estimate, not official daily, NowCast, or all-pollutant AQI.

If an actual WeatherAPI key was ever supplied to an old client build or external build system, rotate it there. Repository config previously used an empty `OPENWEATHER_KEY` default; no literal credential is confirmed in tracked source. Rotation does not remove secrets from existing build artifacts or repository history.
