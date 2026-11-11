import 'dart:math' as math;

enum RiskState { unknown, incomplete, known }

/// What a piece of advice is about.
enum Hazard { air, uv, heat, weather, smoke }

class Advice {
  final Hazard hazard;
  final String text;

  const Advice(this.hazard, this.text);
}

class Weather {
  /// Estimated ISPU (Indonesian air quality index); drives the risk score.
  final int? ispu;

  /// Estimated US EPA AQI, shown only for comparison.
  final int? aqi;
  final double? uv;
  final double? temp;
  final double? humidity;
  final String? condition;
  final int? conditionCode;

  /// WeatherAPI `is_day`: true in daylight, false at night, null if unknown.
  final bool? isDay;

  const Weather({
    this.ispu,
    this.aqi,
    this.uv,
    this.temp,
    this.humidity,
    this.condition,
    this.conditionCode,
    this.isDay,
  });

  Map<String, double> get componentSeverity {
    final values = <String, double>{};
    // ISPU: Baik ≤50 Rendah, Sedang 51–100, Tidak Sehat and worse ≥101 Tinggi.
    if (ispu != null) values['ISPU'] = _band(ispu!.toDouble(), 51, 101, 301);
    if (uv != null) values['UV'] = _band(uv!, 3, 8, 11);
    final heat = heatSeverity;
    if (heat != null) values['Suhu'] = heat;
    final weather = _conditionSeverity;
    if (weather != null) values['Cuaca'] = weather;
    return values;
  }

  double? get heatIndex {
    if (temp == null || humidity == null) return null;
    if (humidity! < 0 || humidity! > 100) return null;

    final tempF = temp! * 9 / 5 + 32;
    final simpleEstimate =
        0.5 * (tempF + 61 + (tempF - 68) * 1.2 + humidity! * 0.094);
    var heatIndexF = (simpleEstimate + tempF) / 2;

    if (heatIndexF >= 80) {
      heatIndexF =
          -42.379 +
          2.04901523 * tempF +
          10.14333127 * humidity! -
          0.22475541 * tempF * humidity! -
          0.00683783 * tempF * tempF -
          0.05481717 * humidity! * humidity! +
          0.00122874 * tempF * tempF * humidity! +
          0.00085282 * tempF * humidity! * humidity! -
          0.00000199 * tempF * tempF * humidity! * humidity!;

      if (humidity! < 13 && tempF >= 80 && tempF <= 112) {
        heatIndexF -=
            (13 - humidity!) / 4 * math.sqrt((17 - (tempF - 95).abs()) / 17);
      } else if (humidity! > 85 && tempF >= 80 && tempF <= 87) {
        heatIndexF += (humidity! - 85) / 10 * (87 - tempF) / 5;
      }
    }

    return (heatIndexF - 32) * 5 / 9;
  }

  /// Dew point in °C from [temp] and [humidity] (Magnus formula with
  /// a = 17.62, b = 243.12 °C).
  double? get dewPoint {
    if (temp == null || humidity == null) return null;
    if (humidity! <= 0 || humidity! > 100) return null;
    const a = 17.62;
    const b = 243.12;
    final gamma = math.log(humidity! / 100) + a * temp! / (b + temp!);
    return b * gamma / (a - gamma);
  }

  /// NWS summer dew point comfort level, for information only (not scored):
  /// 0 dry and comfortable (≤ 55 °F), 1 sticky (55–65 °F),
  /// 2 oppressive (≥ 65 °F). Source: NWS, https://www.weather.gov/arx/heat_index
  int? get dewPointComfort {
    final celsius = dewPoint;
    if (celsius == null) return null;
    final fahrenheit = celsius * 9 / 5 + 32;
    if (fahrenheit <= 55) return 0;
    if (fahrenheit < 65) return 1;
    return 2;
  }

  /// NWS heat index classification of [heatIndex] (or air temperature when
  /// humidity is unavailable): 0 below Caution, 1 Caution (80–90 °F),
  /// 2 Extreme Caution (90–103 °F), 3 Danger (103–124 °F),
  /// 4 Extreme Danger (125 °F or higher).
  /// Source: NWS, https://www.weather.gov/ama/heatindex
  int? get heatCategory {
    final celsius = heatIndex ?? temp;
    if (celsius == null) return null;
    final fahrenheit = celsius * 9 / 5 + 32;
    if (fahrenheit < 80) return 0;
    if (fahrenheit < 90) return 1;
    if (fahrenheit < 103) return 2;
    if (fahrenheit < 125) return 3;
    return 4;
  }

  /// Daylight with clear or partly cloudy sky. Heat index values assume shade;
  /// full sun can add up to 15 °F (NWS).
  bool get inDirectSun {
    if (isDay != true) return false;
    final code = conditionCode;
    if (code != null) return code == 1000 || code == 1003;
    return RegExp(r'sunny|clear|partly|cerah').hasMatch(
      condition?.toLowerCase() ?? '',
    );
  }

  /// [heatCategory] raised one level in direct sun, following OSHA's
  /// "Using the Heat Index" advice to take the steps of the next highest risk
  /// level when working in direct sun.
  int? get heatRiskCategory {
    final category = heatCategory;
    if (category == null) return null;
    return inDirectSun ? math.min(category + 1, 4) : category;
  }

  /// Rendah below Extreme Caution, Sedang at Extreme Caution, Tinggi at
  /// Danger and above.
  double? get heatSeverity => switch (heatRiskCategory) {
    null => null,
    0 || 1 => 0,
    2 => 0.5,
    3 => 0.75,
    _ => 1,
  };

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
        1135,
        1147,
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
      if ({1000, 1003, 1006, 1009, 1030}.contains(code)) return 0;
    }
    if (_hasThunder || text.contains('blizzard')) return 1;
    if (RegExp(r'rain|hujan|drizzle|gerimis|sleet|salju|snow').hasMatch(text)) {
      return 0.5;
    }
    if (_hasSmokeOrHaze) return 0.5;
    if (RegExp(r'fog|kabut').hasMatch(text)) return 0.5;
    if (RegExp(r'clear|sunny|cloud|overcast|mist|cerah|berawan').hasMatch(text)) {
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
    return ispu != null && uv != null && temp != null
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

  /// Advice texts, in display order.
  List<String> get recommendations => [for (final a in advice) a.text];

  /// Advice for the current readings, each tagged with the hazard it
  /// addresses so the UI can pick an icon without parsing the text.
  List<Advice> get advice {
    final recs = <Advice>[];
    void add(Hazard hazard, String text) => recs.add(Advice(hazard, text));
    // Advice for "setiap orang" (and sensitive groups at Sedang) from
    // Permen LHK P.14/2020 Lampiran II.
    if (ispu != null) {
      if (ispu! >= 301) {
        add(Hazard.air, 'Hindari semua aktivitas di luar.');
      } else if (ispu! >= 201) {
        add(Hazard.air, 'Hindari aktivitas fisik yang terlalu lama di luar ruangan.');
      } else if (ispu! >= 101) {
        add(Hazard.air, 'Kurangi aktivitas fisik yang terlalu lama di luar ruangan.');
      } else if (ispu! >= 51) {
        add(Hazard.air, 'Kelompok sensitif: kurangi aktivitas fisik yang terlalu lama atau berat.');
      }
    }
    if (uv != null) {
      if (uv! >= 8) {
        add(Hazard.uv, 'Cari tempat teduh; gunakan jaket lengan panjang dan tabir surya.');
      } else if (uv! >= 3) {
        add(Hazard.uv, 'Gunakan jaket lengan panjang dan tabir surya saat berkendara.');
      }
    }
    final heat = heatSeverity;
    if (heat != null) {
      if (heat >= 0.75) {
        add(Hazard.heat, 'Cari tempat teduh, minum cukup, dan kurangi aktivitas berat.');
      } else if (heat >= 0.5) {
        add(Hazard.heat, 'Minum cukup dan beristirahat dari panas.');
      }
    }
    final severity = _conditionSeverity;
    if (_hasThunder) {
      add(Hazard.weather, 'Berlindung di dalam saat ada petir.');
    } else if (_hasSmokeOrHaze) {
      if (ispu == null || ispu! < 51) {
        add(Hazard.smoke, 'Kurangi aktivitas luar dan gunakan masker saat udara berasap.');
      }
    } else if (severity != null && severity >= 0.5) {
      add(Hazard.weather, 'Waspadai cuaca buruk; berhati-hati saat berkendara.');
    }
    return recs;
  }

  static const emptyWeather = Weather();
}
