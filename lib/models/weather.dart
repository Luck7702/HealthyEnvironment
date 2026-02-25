class Weather {
  final int aqi;
  final int uv;
  final int temp;
  final int humidity;


  Weather({
    required this.aqi,
    required this.uv,
    required this.temp,
    required this.humidity,
  });

  double get riskScore {
    double score = 0;   
    score += ((aqi - 70) / 80).clamp(0, 1.0) * 0.5;  // Score increases in an increment within range AQI 70 (0%) to AQI 140 (100%) which contributes to top score of 0.4
    
    score += ((uv - 4) / 3).clamp(0, 1.0) * 0.3; // 
    
    score += ((temp - 27) / 4).clamp(0, 1.0) * 0.2; // 
    
    return score; 
  }

  String get getRiskLevel {
    double score = riskScore;
    if (score < 0.4) return "Rendah";
    if (score < 0.7) return "Sedang";
    return "Tinggi";
  }

  
}


Weather emptyWeather(){
    return Weather(aqi: 0, uv: 0, temp: 0, humidity: 0);
  }