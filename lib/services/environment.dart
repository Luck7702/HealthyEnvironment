import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

  EnvData({
    required this.location,
    this.localTime = '',
    required this.weather,
    required this.status,
  });

  static EnvData get preview {
    return EnvData(
      location: 'Ciledug 1',
      localTime: '14:40',
      weather: Weather(
        aqi: 134,
        uv: 6.1,
        temp: 32.9,
        humidity: 68,
        condition: 'Light rain',
      ),
      status: 'Preview',
    );
  }
}

Future<EnvData> loadEnvironment({String? query}) async {
  query ??= '';

  if (query.isEmpty) {
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      return EnvData(
        location: '',
        weather: Weather.emptyWeather,
        status: 'Location unavailable',
      );
    }
    query = '${position.latitude},${position.longitude}';
  }

  final data = await EnvironmentService.fetchEnvironment(query);

  if (data == null) {
    return EnvData(
      location: '',
      weather: Weather.emptyWeather,
      status: 'Data is Empty',
    );
  }

  if (data['status'] == 'Failed to Connect') {
    return EnvData(
      status: 'Failed to Connect',
      location: '',
      weather: Weather.emptyWeather,
    );
  }

  final localTime = data['localtime'].toString();
  return EnvData(
    status: 'Success',
    location: data['location'] as String,
    localTime: localTime.substring(localTime.length - 5),
    weather: Weather(
      aqi: data['aqi'] as int,
      uv: (data['uv'] as num).toDouble(),
      temp: (data['temp'] as num).toDouble(),
      humidity: (data['humidity'] as num).toDouble(),
      condition: data['condition'] as String,
    ),
  );
}

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

class EnvironmentService {
  static Future<Map<String, dynamic>?> fetchEnvironment(String query) async {
    try {
      final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json'
        '?key=${Env.openWeatherKey}&q=$query&aqi=yes',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('WeatherAPI error: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>;
      final location = data['location'] as Map<String, dynamic>;
      final airQuality = current['air_quality'] as Map<String, dynamic>;

      return {
        'status': 'Success',
        'location': location['name'],
        'localtime': location['localtime'],
        'condition': (current['condition'] as Map<String, dynamic>)['text'],
        'temp': (current['temp_c'] as num).toDouble(),
        'humidity': (current['humidity'] as num).toDouble(),
        'uv': (current['uv'] as num).toDouble(),
        'aqi': AirQuality(
          pm2_5: (airQuality['pm2_5'] as num).toDouble(),
          pm10: (airQuality['pm10'] as num).toDouble(),
        ).aqi,
      };
    } catch (error) {
      debugPrint('WeatherAPI exception: $error');
      if (error is SocketException) {
        return {'status': 'Failed to Connect'};
      }
      return null;
    }
  }
}
