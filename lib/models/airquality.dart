/// Current-concentration PM estimate, not an official daily/NowCast AQI.
class AirQuality {
  final double? pm2_5;
  final double? pm10;

  const AirQuality({this.pm2_5, this.pm10});

  int? get aqi {
    final values = <double>[];
    if (pm2_5 != null) values.add(pm25AQI(pm2_5!));
    if (pm10 != null) values.add(pm10AQI(pm10!));
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b).round();
  }
}

double calculateSubAQI({
  required double concentration,
  required double cLow,
  required double cHigh,
  required int iLow,
  required int iHigh,
}) {
  return ((iHigh - iLow) / (cHigh - cLow)) * (concentration - cLow) + iLow;
}

double _truncate(double value, int decimals) {
  final factor = decimals == 1 ? 10 : 1;
  return (value * factor).floorToDouble() / factor;
}

double pm25AQI(double concentration) {
  final c = _truncate(concentration.clamp(0, 325.4), 1);
  if (c <= 9.0) {
    return calculateSubAQI(
      concentration: c,
      cLow: 0,
      cHigh: 9,
      iLow: 0,
      iHigh: 50,
    );
  }
  if (c <= 35.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 9.1,
      cHigh: 35.4,
      iLow: 51,
      iHigh: 100,
    );
  }
  if (c <= 55.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 35.5,
      cHigh: 55.4,
      iLow: 101,
      iHigh: 150,
    );
  }
  if (c <= 125.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 55.5,
      cHigh: 125.4,
      iLow: 151,
      iHigh: 200,
    );
  }
  if (c <= 225.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 125.5,
      cHigh: 225.4,
      iLow: 201,
      iHigh: 300,
    );
  }
  return calculateSubAQI(
    concentration: c,
    cLow: 225.5,
    cHigh: 325.4,
    iLow: 301,
    iHigh: 500,
  );
}

double pm10AQI(double concentration) {
  final c = _truncate(concentration.clamp(0, 604).toDouble(), 0);
  if (c <= 54) {
    return calculateSubAQI(
      concentration: c,
      cLow: 0,
      cHigh: 54,
      iLow: 0,
      iHigh: 50,
    );
  }
  if (c <= 154) {
    return calculateSubAQI(
      concentration: c,
      cLow: 55,
      cHigh: 154,
      iLow: 51,
      iHigh: 100,
    );
  }
  if (c <= 254) {
    return calculateSubAQI(
      concentration: c,
      cLow: 155,
      cHigh: 254,
      iLow: 101,
      iHigh: 150,
    );
  }
  if (c <= 354) {
    return calculateSubAQI(
      concentration: c,
      cLow: 255,
      cHigh: 354,
      iLow: 151,
      iHigh: 200,
    );
  }
  if (c <= 424) {
    return calculateSubAQI(
      concentration: c,
      cLow: 355,
      cHigh: 424,
      iLow: 201,
      iHigh: 300,
    );
  }
  return calculateSubAQI(
    concentration: c,
    cLow: 425,
    cHigh: 604,
    iLow: 301,
    iHigh: 500,
  );
}
