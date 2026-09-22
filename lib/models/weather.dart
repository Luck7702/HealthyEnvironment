class Weather {
  final int aqi;
  final double uv;
  final double temp;
  final double humidity;
  final String condition;

  Weather({
    required this.aqi,
    required this.uv,
    required this.temp,
    required this.humidity,
    this.condition = "Not Specified",
  });

  double get riskScore {
    double score = 0;
    score += ((aqi - 50) / 100).clamp(0, 1.0) * 0.5;
    score += ((uv - 3) / 8).clamp(0, 1.0) * 0.3;
    score += ((temp - 25) / 10).clamp(0, 1.0) * 0.2;

    return score;
  }

  String get getRiskLevel {
    double score = riskScore;
    if (score < 0.4) return "Rendah";
    if (score < 0.7) return "Sedang";
    return "Tinggi";
  }

  static Weather get emptyWeather {
    return Weather(aqi: 0, uv: 0, temp: 0, humidity: 0);
  }
}
