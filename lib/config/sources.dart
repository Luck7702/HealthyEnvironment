/// A reference shown to users so each threshold can be traced to its source.
class Source {
  final String label;
  final String url;

  const Source(this.label, this.url);
}

class Sources {
  static const epaAqi = Source(
    'US EPA: AQI breakpoints',
    'https://aqs.epa.gov/aqsweb/documents/codetables/aqi_breakpoints.html',
  );
  static const whoUv = Source(
    'WHO: Indeks UV',
    'https://www.who.int/news-room/questions-and-answers/item/radiation-the-ultraviolet-(uv)-index',
  );
  static const icnirpUv = Source(
    'ICNIRP: kategori Indeks UV',
    'https://www.icnirp.org/en/applications/uv-index/index.html',
  );
  static const nwsHeatIndex = Source(
    'NOAA/NWS: klasifikasi indeks panas',
    'https://www.weather.gov/ama/heatindex',
  );
  static const oshaHeatIndex = Source(
    'OSHA: Using the Heat Index (arsip)',
    'https://web.archive.org/web/2013/http://www.osha.gov/SLTC/heatillness/heat_index/protective_measures.html',
  );
  static const nwsDewPoint = Source(
    'NOAA/NWS: kenyamanan titik embun',
    'https://www.weather.gov/arx/heat_index',
  );
  static const nwsLightning = Source(
    'NOAA/NWS: keselamatan petir',
    'https://www.weather.gov/safety/lightning-safety',
  );
  static const weatherApi = Source(
    'WeatherAPI.com: data cuaca dan kualitas udara',
    'https://www.weatherapi.com/',
  );
  static const bmkg = Source(
    'BMKG: peringatan dini cuaca resmi',
    'https://www.bmkg.go.id/',
  );

  static const all = [
    epaAqi,
    whoUv,
    icnirpUv,
    nwsHeatIndex,
    oshaHeatIndex,
    nwsDewPoint,
    nwsLightning,
    weatherApi,
    bmkg,
  ];
}
