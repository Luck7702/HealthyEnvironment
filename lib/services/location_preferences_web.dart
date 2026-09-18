// ignore_for_file: avoid_web_libraries_in_flutter

// ignore: deprecated_member_use
import 'dart:html' as html;

const _locationKey = 'lingkungan_sehat.location';

String? readSavedLocation() {
  final location = html.window.localStorage[_locationKey]?.trim();
  return location == null || location.isEmpty ? null : location;
}

void saveLocation(String location) {
  html.window.localStorage[_locationKey] = location;
}
