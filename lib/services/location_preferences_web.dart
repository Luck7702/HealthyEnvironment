import 'dart:js_interop';

const _locationKey = 'lingkungan_sehat.location';

extension type _Storage._(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
}

@JS('localStorage')
external _Storage get _localStorage;

String? readSavedLocation() {
  try {
    final location = _localStorage.getItem(_locationKey)?.trim();
    return location == null || location.isEmpty ? null : location;
  } catch (_) {
    // Storage can be blocked (private mode, disabled site data).
    return null;
  }
}

void saveLocation(String location) {
  try {
    _localStorage.setItem(_locationKey, location);
  } catch (_) {
    // Remembering the location is a convenience; ignore blocked storage.
  }
}
