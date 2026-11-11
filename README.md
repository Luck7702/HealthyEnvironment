# LingkunganSehat

**Live app: [app.lingkungansehat.my.id](https://app.lingkungansehat.my.id)**

LingkunganSehat ("Healthy Environment") is a mobile-first web app that rates the outdoor health risk where you are, right now, as *Rendah*, *Sedang* or *Tinggi* (low, moderate, high). It gives short advice in Bahasa Indonesia. It is built for drivers and riders who spend the day outside.

The app uses your GPS position or a city you enter. It combines four hazards:

- **Air quality:** estimated ISPU, Indonesia's official index, from PM2.5 and PM10 (US EPA AQI shown for comparison)
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

## Install and Android widget

- **Web (PWA):** the home screen shows a "Pasang di layar utama" banner. Android/Chrome uses the browser install prompt; iOS shows the Share → "Tambah ke Layar Utama" steps. Manifest shortcuts open `?buka=info` (sources) and `?buka=lokasi` (change location).
- **Android home-screen widget (for a future Play Store build):** `RiskWidgetProvider` (`android/app/src/main/kotlin/.../RiskWidgetProvider.kt`, layout `res/layout/risk_widget.xml`) shows location, risk level, ISPU/UV/temperature and update time. Flutter writes the values through [`home_widget`](https://pub.dev/packages/home_widget) after each successful load (`lib/services/home_widget_sync_android.dart`); the widget does not fetch data itself, so it shows what the app last loaded. It has not been built or run on a device yet. Before publishing, change `applicationId`/`namespace` from `com.example.LingkunganSehat` and add release signing.

## Environmental risk analysis

The overall risk is the highest of four hazard levels (Rendah, Sedang, Tinggi). Every numeric cut-off below comes from the cited source. How each source's categories group into the three app levels is the app's own mapping. Ratings are indicative, not medical advice.

| Hazard | Rendah | Sedang | Tinggi | Source |
|---|---|---|---|---|
| Air quality (estimated ISPU from PM2.5/PM10) | Baik (0–50) | Sedang (51–100) | Tidak Sehat and worse (≥101) | [Permen LHK P.14/2020](https://peraturan.bpk.go.id/Details/163466/permen-lhk-no-14-tahun-2020) Lampiran I–II |
| UV Index | 0–2 | 3–7 | ≥8 | [WHO UV Index](https://www.who.int/news-room/questions-and-answers/item/radiation-the-ultraviolet-%28uv%29-index) action levels; dialog labels use the [ICNIRP](https://www.icnirp.org/en/applications/uv-index/index.html) five categories |
| Heat (NWS heat index) | below Extreme Caution (<90 °F / 32.2 °C) | Extreme Caution (90–103 °F) | Danger and above (≥103 °F / 39.4 °C) | [NWS heat index classification](https://www.weather.gov/ama/heatindex) |
| Weather condition | clear, cloud, mist | rain, snow, smoke/haze, fog | thunder, heavy rain/snow, blizzard | [WeatherAPI condition codes](https://www.weatherapi.com/docs/weather_conditions.json), [NWS lightning safety](https://www.weather.gov/safety/lightning-safety) |

- **Direct sun.** NWS heat index values assume shade; full sun can add up to 15 °F. During daylight (`is_day`) with a clear or partly cloudy sky (condition codes 1000/1003), heat risk moves up one NWS level, following OSHA's advice to apply the next highest risk level when working in direct sun ([OSHA, *Using the Heat Index*, archived](https://web.archive.org/web/2013/http://www.osha.gov/SLTC/heatillness/heat_index/protective_measures.html)).
- **Heat fallback.** Without valid humidity, the heat index falls back to air temperature.
- **Humidity is information only.** The card shows the [NWS dew point comfort scale](https://www.weather.gov/arx/heat_index) (≤55 °F dry and comfortable, 55–65 °F sticky, ≥65 °F oppressive), with dew point from the Magnus formula. Humidity's effect on the body is already counted through the heat index.
- **No cold rule.** No credible source supports a cold threshold above freezing for this use case, so cold does not affect the risk.
- **ISPU.** Sub-indices use the regulation's linear equation and Lampiran I breakpoints (PM2.5: 15.5 / 55.4 / 150.4 / 250.4 / 500 µg/m³; PM10: 50 / 150 / 350 / 420 / 500 µg/m³), rounded as in its worked example (PM2.5 31.4 µg/m³ → ISPU 70). The regulation gives no ISPU value for the top of its ">300" row, so the app uses 500. Air-quality advice quotes Lampiran II ("Apa yang harus dilakukan"). The source file on BPK's database still carries a "RANCANGAN" header, but it is the promulgated text (Berita Negara RI 2020 No. 774).
- **Estimates, not official readings.** Official ISPU uses 24-hour averages from monitoring stations and up to seven pollutants. The app uses a single current PM2.5/PM10 reading from WeatherAPI's model, so it shows "perkiraan ISPU". The US EPA AQI ([breakpoints](https://aqs.epa.gov/aqsweb/documents/codetables/aqi_breakpoints.html)) appears in the dialog for comparison only.

Invalid or missing readings remain unknown (`null`). Known elevated hazards remain visible when other readings are missing; when every indicator is unknown, UI states risk is unavailable instead of inventing a safe zero. Recommendations stay short and tied to known hazards.

The app's Information screen and each metric dialog link to these sources.

If an actual WeatherAPI key was ever supplied to an old client build or external build system, rotate it there. Repository config previously used an empty `OPENWEATHER_KEY` default; no literal credential is confirmed in tracked source. Rotation does not remove secrets from existing build artifacts or repository history.

## License

[MIT](LICENSE)
