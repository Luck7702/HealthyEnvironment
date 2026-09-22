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
      if ({
        1087,
        1117,
        1171,
        1195,
        1201,
        1225,
        1246,
        1252,
        1258,
        1264,
        1273,
        1276,
        1279,
        1282,
      }.contains(code)) {
        return 1;
      }
      if ({
        1063,
        1066,
        1069,
        1072,
        1114,
        1150,
        1153,
        1168,
        1180,
        1183,
        1186,
        1189,
        1192,
        1198,
        1204,
        1207,
        1210,
        1213,
        1216,
        1219,
        1222,
        1237,
        1240,
        1243,
        1249,
        1255,
        1261,
      }.contains(code)) {
        return 0.5;
      }
      if ({1000, 1003, 1006, 1009, 1030, 1135, 1147}.contains(code)) return 0;
    }
    if (_hasThunder || text.contains('blizzard')) return 1;
    if (RegExp(r'rain|hujan|drizzle|gerimis|sleet|salju|snow').hasMatch(text)) {
      return 0.5;
    }
    if (_hasSmokeOrHaze) return 0.5;
    if (RegExp(
      r'clear|sunny|cloud|overcast|mist|fog|cerah|berawan|kabut',
    ).hasMatch(text)) {
      return 0;
    }
    if (text.isEmpty || text == 'not specified') return null;
    return null;
  }

  bool get _hasThunder {
    if ({1087, 1273, 1276, 1279, 1282}.contains(conditionCode)) return true;
    final text = condition?.toLowerCase() ?? '';
    return RegExp(r'thunder|petir|lightning').hasMatch(text);
  }

  bool get _hasSmokeOrHaze {
    final text = condition?.toLowerCase() ?? '';
    return RegExp(r'smoke|smoky|haze|asap').hasMatch(text);
  }

  double get riskScore {
    final values = componentSeverity.values;
    return values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  }

  RiskState get riskState {
    if (componentSeverity.isEmpty) return RiskState.unknown;
    return aqi != null && uv != null && temp != null
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
        recs.add(
          'Cari tempat teduh; gunakan jaket lengan panjang dan tabir surya.',
        );
      } else if (uv! >= 3) {
        recs.add(
          'Gunakan jaket lengan panjang dan tabir surya saat berkendara.',
        );
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
    if (_hasThunder) {
      recs.add('Berlindung di dalam saat ada petir.');
    } else if (_hasSmokeOrHaze) {
      if (aqi == null || aqi! < 51) {
        recs.add(
          'Kurangi aktivitas luar dan gunakan masker saat udara berasap.',
        );
      }
    } else if (severity != null && severity >= 0.5) {
      recs.add('Waspadai cuaca buruk; berhati-hati saat berkendara.');
    }
    return recs.toSet().toList();
  }

  static const emptyWeather = Weather();
}
