enum RiskState { unknown, incomplete, known }

class Weather {
  final int? aqi;
  final double? uv;
  final double? temp;
  final double? humidity;
  final String? condition;
  final int? conditionCode;

  const Weather({
    this.aqi,
    this.uv,
    this.temp,
    this.humidity,
    this.condition,
    this.conditionCode,
  });

  Map<String, double> get componentSeverity {
    final values = <String, double>{};
    if (aqi != null) values['AQI'] = _band(aqi!.toDouble(), 51, 151, 301);
    if (uv != null) values['UV'] = _band(uv!, 3, 8, 11);
    if (temp != null) {
      final heat = _band(temp!, 30, 35, 40);
      final cold = temp! <= 0
          ? 1.0
          : temp! < 15
          ? 0.5
          : 0.0;
      values['Suhu'] = heat > cold ? heat : cold;
    }
    final weather = _conditionSeverity;
    if (weather != null) values['Cuaca'] = weather;
    return values;
  }

  double _band(double value, double moderate, double high, double extreme) {
    if (value < moderate) return 0;
    if (value < high) return 0.5;
    if (value < extreme) return 0.75;
    return 1;
  }

  double? get _conditionSeverity {
    final text = condition?.toLowerCase() ?? '';
    final code = conditionCode;
    if (code != null) {
      if ({1087, 1273, 1276, 1282}.contains(code)) return 1;
      if ({
        1063,
        1150,
        1153,
        1180,
        1183,
        1186,
        1189,
        1192,
        1195,
        1240,
        1243,
        1246,
      }.contains(code)) {
        return 0.5;
      }
      if (code == 1279) return 0.75;
      if ({1000, 1003, 1006, 1009, 1030, 1135, 1147}.contains(code)) return 0;
    }
    if (RegExp(r'thunder|petir|lightning').hasMatch(text)) return 1;
    if (RegExp(r'rain|hujan|drizzle|gerimis|sleet|salju|snow').hasMatch(text)) {
      return 0.5;
    }
    if (text.isEmpty || text == 'not specified') return null;
    return null;
  }

  double get riskScore {
    final values = componentSeverity.values;
    return values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  }

  RiskState get riskState {
    if (componentSeverity.isEmpty) return RiskState.unknown;
    final count = [
      aqi,
      uv,
      temp,
      humidity,
    ].where((value) => value != null).length;
    return count == 4 && _conditionSeverity != null
        ? RiskState.known
        : RiskState.incomplete;
  }

  String get getRiskLevel {
    if (riskState == RiskState.unknown) return 'Belum diketahui';
    if (riskScore < 0.5) return 'Rendah';
    if (riskScore < 0.75) return 'Sedang';
    return 'Tinggi';
  }

  String get riskDescription => switch (riskState) {
    RiskState.unknown =>
      'Risiko belum diketahui: data lingkungan belum tersedia.',
    RiskState.incomplete => 'Risiko sementara: sebagian data belum tersedia.',
    RiskState.known => 'Risiko berdasarkan data lingkungan saat ini.',
  };

  List<String> get recommendations {
    final recs = <String>[];
    if (aqi != null) {
      if (aqi! >= 151) {
        recs.add('Kurangi aktivitas luar; gunakan masker yang sesuai.');
      } else if (aqi! >= 101) {
        recs.add('Kelompok sensitif sebaiknya kurangi aktivitas luar.');
      } else if (aqi! >= 51) {
        recs.add('Pertimbangkan mengurangi aktivitas berat di luar.');
      }
    }
    if (uv != null) {
      if (uv! >= 8) {
        recs.add('Hindari matahari tengah hari; gunakan pelindung UV.');
      } else if (uv! >= 3) {
        recs.add('Gunakan pelindung UV saat berada di luar.');
      }
    }
    if (temp != null) {
      if (temp! >= 35) {
        recs.add(
          'Cari tempat teduh, minum cukup, dan kurangi aktivitas berat.',
        );
      } else if (temp! >= 30) {
        recs.add('Minum cukup dan beristirahat dari panas.');
      } else if (temp! <= 0) {
        recs.add('Gunakan pakaian hangat dan batasi paparan dingin.');
      } else if (temp! < 15) {
        recs.add('Gunakan pakaian hangat saat berada di luar.');
      }
    }
    if (humidity != null && humidity! < 40) {
      recs.add('Minum cukup karena udara kering.');
    }
    final severity = _conditionSeverity;
    if (severity != null && severity >= 1) {
      recs.add('Berlindung di dalam saat ada petir.');
    } else if (severity != null && severity >= 0.5) {
      recs.add('Waspadai hujan; berhati-hati saat berkendara.');
    }
    return recs.toSet().toList();
  }

  static const emptyWeather = Weather();
}
