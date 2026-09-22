import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:lingkungan_sehat/config/env.dart';
import 'package:lingkungan_sehat/models/airquality.dart';
import 'package:lingkungan_sehat/models/weather.dart';

class EnvData {
  final String location;
  final String localTime;
  final Weather weather;
  final String status;

  const EnvData({
    required this.location,
    this.localTime = '',
    required this.weather,
    required this.status,
  });
}

abstract final class EnvironmentStatus {
  static const success = 'Success';
  static const locationUnavailable = 'Location unavailable';
  static const networkError = 'Network error';
  static const invalidQuery = 'Invalid query';
  static const locationNotFound = 'Location not found';
  static const rateLimited = 'Rate limited';
  static const upstreamTimeout = 'Upstream timeout';
  static const upstreamUnavailable = 'Upstream unavailable';
  static const serverMisconfigured = 'Server misconfigured';
  static const invalidResponse = 'Invalid response';
  static const empty = 'Data is Empty';
}

String environmentErrorMessage(String status) {
  switch (status) {
    case EnvironmentStatus.locationUnavailable:
      return 'Lokasi tidak tersedia. Aktifkan layanan lokasi atau masukkan lokasi manual.';
    case EnvironmentStatus.networkError:
      return 'Koneksi gagal. Periksa internet lalu coba lagi.';
    case EnvironmentStatus.invalidQuery:
      return 'Lokasi tidak valid. Masukkan nama kota atau koordinat yang benar.';
    case EnvironmentStatus.locationNotFound:
      return 'Lokasi tidak ditemukan. Periksa ejaan lalu coba lagi.';
    case EnvironmentStatus.rateLimited:
      return 'Permintaan terlalu banyak. Tunggu sebentar lalu coba lagi.';
    case EnvironmentStatus.upstreamTimeout:
      return 'Layanan cuaca terlalu lama merespons. Coba lagi.';
    case EnvironmentStatus.upstreamUnavailable:
      return 'Layanan cuaca sedang tidak tersedia. Coba lagi nanti.';
    case EnvironmentStatus.serverMisconfigured:
      return 'Konfigurasi layanan bermasalah. Hubungi administrator.';
    case EnvironmentStatus.empty:
      return 'Data lingkungan tidak tersedia untuk lokasi ini.';
    default:
      return 'Data lingkungan gagal dimuat. Coba lagi.';
  }
}

bool environmentErrorIsRetryable(String status) => switch (status) {
  EnvironmentStatus.serverMisconfigured ||
  EnvironmentStatus.invalidQuery ||
  EnvironmentStatus.locationNotFound ||
  EnvironmentStatus.locationUnavailable => false,
  _ => true,
};

bool environmentErrorNeedsLocationChoice(String status) => switch (status) {
  EnvironmentStatus.invalidQuery ||
  EnvironmentStatus.locationNotFound ||
  EnvironmentStatus.locationUnavailable => true,
  _ => false,
};

typedef EnvironmentLocationResolver = Future<Position?> Function();
typedef EnvironmentFetcher =
    Future<Map<String, dynamic>?> Function(String query);
typedef EnvironmentHttpGet = Future<http.Response> Function(Uri uri);
typedef EnvironmentLoader = Future<EnvData> Function({String? query});

Future<http.Response> _defaultEnvironmentHttpGet(Uri uri) => http.get(uri);

Future<EnvData> loadEnvironment({
  String? query,
  EnvironmentLocationResolver? locationResolver,
  EnvironmentFetcher? fetcher,
}) async {
  final requestedQuery = query?.trim() ?? '';

  if (requestedQuery.isEmpty) {
    final position =
        await (locationResolver ?? LocationService.getCurrentLocation)();
    if (position == null) {
      return const EnvData(
        location: '',
        weather: Weather.emptyWeather,
        status: EnvironmentStatus.locationUnavailable,
      );
    }
    query = '${position.latitude},${position.longitude}';
  } else {
    query = requestedQuery;
  }

  final data = await (fetcher ?? EnvironmentService.fetchEnvironment)(query);
  if (data == null) {
    return EnvData(
      location: requestedQuery,
      weather: Weather.emptyWeather,
      status: EnvironmentStatus.empty,
    );
  }

  final status = data['status'];
  if (status != EnvironmentStatus.success) {
    return EnvData(
      status: status is String ? status : EnvironmentStatus.invalidResponse,
      location: requestedQuery,
      weather: Weather.emptyWeather,
    );
  }

  final localtime = data['localtime'] as String?;
  final time = localtime != null && localtime.length >= 5
      ? localtime.substring(localtime.length - 5)
      : '';
  return EnvData(
    status: EnvironmentStatus.success,
    location: '${data['location']}',
    localTime: time,
    weather: Weather(
      aqi: (data['aqi'] as num?)?.toInt(),
      uv: (data['uv'] as num?)?.toDouble(),
      temp: (data['temp'] as num?)?.toDouble(),
      humidity: (data['humidity'] as num?)?.toDouble(),
      condition: data['condition'] as String?,
      conditionCode: (data['conditionCode'] as num?)?.toInt(),
    ),
  );
}

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
  }
}

class EnvironmentService {
  static Map<String, dynamic> parseEnvironmentPayload(dynamic data) {
    if (data is! Map) return {'status': EnvironmentStatus.invalidResponse};
    final current = data['current'];
    final location = data['location'];
    final condition = current is Map ? current['condition'] : null;
    if (current is! Map ||
        location is! Map ||
        condition is! Map ||
        location['name'] is! String ||
        location['localtime'] is! String ||
        (condition['text'] != null && condition['text'] is! String)) {
      return {'status': EnvironmentStatus.invalidResponse};
    }

    final airQuality = current['air_quality'];
    final pm25 = airQuality is Map ? airQuality['pm2_5'] : null;
    final pm10 = airQuality is Map ? airQuality['pm10'] : null;
    double? finite(dynamic value) {
      return value is num && value.isFinite ? value.toDouble() : null;
    }

    final temp = finite(current['temp_c']);
    final humidity = finite(current['humidity']);
    final uv = finite(current['uv']);
    final pm25Value = finite(pm25);
    final pm10Value = finite(pm10);
    final conditionText = condition['text'] is String
        ? condition['text'] as String
        : null;
    final conditionCode = condition['code'] is num
        ? (condition['code'] as num).toInt()
        : null;
    if (temp == null &&
        humidity == null &&
        uv == null &&
        pm25Value == null &&
        pm10Value == null &&
        conditionText == null &&
        conditionCode == null) {
      return {'status': EnvironmentStatus.invalidResponse};
    }

    final result = <String, dynamic>{
      'status': EnvironmentStatus.success,
      'location': location['name'],
      'localtime': location['localtime'],
      'aqi': AirQuality(pm2_5: pm25Value, pm10: pm10Value).aqi,
    };
    if (conditionText != null) result['condition'] = conditionText;
    if (conditionCode != null) result['conditionCode'] = conditionCode;
    if (temp != null) result['temp'] = temp;
    if (humidity != null) result['humidity'] = humidity;
    if (uv != null) result['uv'] = uv;
    return result;
  }

  static Future<Map<String, dynamic>?> fetchEnvironment(
    String query, {
    EnvironmentHttpGet httpGet = _defaultEnvironmentHttpGet,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final baseUri = Uri.parse(Env.environmentApiUrl);
      final url = baseUri.replace(
        queryParameters: {...baseUri.queryParameters, 'q': query},
      );
      final response = await httpGet(url).timeout(timeout);

      if (response.statusCode != 200) return _parseProxyError(response);
      return parseEnvironmentPayload(jsonDecode(response.body));
    } catch (error) {
      if (error is SocketException || error is TimeoutException) {
        return {'status': EnvironmentStatus.networkError};
      }
      if (error is FormatException || error is TypeError) {
        return {'status': EnvironmentStatus.invalidResponse};
      }
      return {'status': EnvironmentStatus.networkError};
    }
  }

  static Map<String, dynamic> _parseProxyError(http.Response response) {
    String? code;
    try {
      final decoded = jsonDecode(response.body);
      final error = decoded is Map ? decoded['error'] : null;
      code = error is Map && error['code'] is String
          ? error['code'] as String
          : null;
    } catch (_) {
      code = null;
    }

    final status = switch (code) {
      'invalid_query' => EnvironmentStatus.invalidQuery,
      'location_not_found' => EnvironmentStatus.locationNotFound,
      'rate_limited' => EnvironmentStatus.rateLimited,
      'upstream_timeout' => EnvironmentStatus.upstreamTimeout,
      'upstream_unavailable' => EnvironmentStatus.upstreamUnavailable,
      'invalid_response' => EnvironmentStatus.invalidResponse,
      'server_misconfigured' => EnvironmentStatus.serverMisconfigured,
      _ => _statusForHttpCode(response.statusCode),
    };
    return {'status': status};
  }

  static String _statusForHttpCode(int statusCode) {
    return switch (statusCode) {
      400 => EnvironmentStatus.invalidQuery,
      404 => EnvironmentStatus.locationNotFound,
      429 => EnvironmentStatus.rateLimited,
      504 => EnvironmentStatus.upstreamTimeout,
      502 || 503 => EnvironmentStatus.upstreamUnavailable,
      500 => EnvironmentStatus.serverMisconfigured,
      _ => EnvironmentStatus.invalidResponse,
    };
  }
}
