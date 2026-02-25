class AirQuality {
  // Gaseous Particles are to be yet implemented because as far as technology goes, mask can't really prevent gaseous partices,
  // so currently we are only considering pm2_5 and pm10 to reduce complexity.

  // double co;
  // double no2;
  // double o3;
  // double so2;

  double pm2_5;
  double pm10;

  AirQuality({
    // required this.co,
    // required this.no2,
    // required this.o3,
    // required this.so2,
    required this.pm2_5,
    required this.pm10,
  });

  int get aqi {
    return overallAQI([pm25AQI(pm2_5), pm10AQI(pm10)]);
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

int overallAQI(List<double> subAQIs) {
  return subAQIs.map((e) => e.round()).reduce((a, b) => a > b ? a : b);
}

double pm25AQI(double c) {
  if (c <= 12.0) {
    return calculateSubAQI(
      concentration: c,
      cLow: 0.0,
      cHigh: 12.0,
      iLow: 0,
      iHigh: 50,
    );
  }
  if (c <= 35.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 12.1,
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
  if (c <= 150.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 55.5,
      cHigh: 150.4,
      iLow: 151,
      iHigh: 200,
    );
  }
  if (c <= 250.4) {
    return calculateSubAQI(
      concentration: c,
      cLow: 150.5,
      cHigh: 250.4,
      iLow: 201,
      iHigh: 300,
    );
  }
  return calculateSubAQI(
    concentration: c,
    cLow: 250.5,
    cHigh: 500.4,
    iLow: 301,
    iHigh: 500,
  );
}

double pm10AQI(double c) {
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
