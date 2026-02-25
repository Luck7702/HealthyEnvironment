import 'dart:io';
import 'package:LingkunganSehat/config/env.dart';
import 'package:LingkunganSehat/models/airquality.dart';
import 'package:LingkunganSehat/models/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class EnvData {
  final String location;
  final Weather weather;
  final String status;

  EnvData({
    required this.location,
    required this.weather,
    required this.status,
  });
}

Future<EnvData> loadEnvironment({String? query, Function? response}) async {
  query ??= "";

  if (query.isEmpty) {
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      if (response != null) {
        response.call();
      }
    }
    query = "${position?.latitude},${position?.longitude}";
  }

  final data = await EnvironmentService.fetchEnvironment(query);

  if (data == null) {
    return EnvData(
      location: "",
      weather: emptyWeather(),
      status: "Data is Empty",
    );
  }

  if (data["Status"] == "Failed to Connect") {
    return EnvData(
      status: "Failed to Connect",
      location: '',
      weather: emptyWeather(),
    );
  } else {
    const space = "                                          ";
    return EnvData(
      status: "Success",
      location:
          "${data["location"]}$space${data["localtime"].toString().substring(data["localtime"].toString().length - 5)}",
      weather: Weather(
        aqi: data["aqi"],
        uv: data["uv"],
        temp: data["temp"],
        humidity: data["humidity"],
      ),
    );
  }
}

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

class EnvironmentService {
  static Future<Map<String, dynamic>?> fetchEnvironment(String query) async {
    try {
      final url =
          "https://api.weatherapi.com/v1/current.json"
          "?key=${Env.openWeatherKey}"
          "&q=$query"
          "&aqi=yes";

      debugPrint(url);
      debugPrint(query);

      final response = await http.get(Uri.parse(url));

      debugPrint("${response.statusCode}");

      debugPrint(response.body);

      if (response.statusCode != 200) {
        debugPrint("WeatherAPI error: ${response.body}");
        return null;
      }

      final data = jsonDecode(response.body);

      return {
        "status": "Success",
        "location": data["location"]["name"],
        "localtime": data["location"]["localtime"],
        "region": data["location"]["region"],
        "country": data["location"]["country"],
        "temp": data["current"]["temp_c"].round(),
        "humidity": data["current"]["humidity"].round(),
        "uv": data["current"]["uv"].round(),
        "aqi": AirQuality(
          pm2_5: data["current"]["air_quality"]["pm2_5"],
          pm10: data["current"]["air_quality"]["pm10"],
        ).aqi,
      };
    } catch (e) {
      debugPrint("WeatherAPI exception: $e");

      if (e is SocketException) {
        return {"Status": "Failed to Connect"};
      }

      return null;
    }
  }
}
