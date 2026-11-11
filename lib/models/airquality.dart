/// Current-concentration PM estimates. These are not official indices:
/// ISPU and AQI are defined on 24-hour averages from monitoring stations.
class AirQuality {
  final double? pm2_5;
  final double? pm10;

  const AirQuality({this.pm2_5, this.pm10});

  /// Estimated ISPU: the higher of the PM2.5 and PM10 sub-indices.
  int? get ispu {
    final values = <int>[];
    if (pm2_5 != null) values.add(pm25ISPU(pm2_5!));
    if (pm10 != null) values.add(pm10ISPU(pm10!));
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

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

/// ISPU breakpoints from Permen LHK No. P.14/MENLHK/SETJEN/KUM.1/7/2020,
/// Lampiran I (Berita Negara RI 2020 No. 774). Each pair is
/// (concentration µg/m³, ISPU) at the upper bound of a category.
/// The regulation gives no ISPU upper bound for its ">300" row; this uses
/// 500, the top of the concentration column.
const _pm25IspuBreakpoints = [
  (0.0, 0),
  (15.5, 50),
  (55.4, 100),
  (150.4, 200),
  (250.4, 300),
  (500.0, 500),
];

const _pm10IspuBreakpoints = [
  (0.0, 0),
  (50.0, 50),
  (150.0, 100),
  (350.0, 200),
  (420.0, 300),
  (500.0, 500),
];

/// ISPU sub-index using the regulation's equation
/// I = (Ia - Ib) / (Xa - Xb) * (Xx - Xb) + Ib, rounded as in its worked
/// example (PM2.5 31.4 µg/m³ -> ISPU 70).
int _ispu(double concentration, List<(double, int)> breakpoints) {
  final c = concentration.clamp(0, breakpoints.last.$1).toDouble();
  for (var i = 1; i < breakpoints.length; i++) {
    final (xa, ia) = breakpoints[i];
    if (c <= xa) {
      final (xb, ib) = breakpoints[i - 1];
      return ((ia - ib) / (xa - xb) * (c - xb) + ib).round();
    }
  }
  return breakpoints.last.$2;
}

int pm25ISPU(double concentration) =>
    _ispu(concentration, _pm25IspuBreakpoints);

int pm10ISPU(double concentration) =>
    _ispu(concentration, _pm10IspuBreakpoints);
