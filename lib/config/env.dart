class Env {
  static const openWeatherKey = String.fromEnvironment(
    'OPENWEATHER_KEY',defaultValue: ""
  );

  static const debug = bool.fromEnvironment('DEBUG', defaultValue: false);

  static const debugLocation = String.fromEnvironment(
    'LOCATION',
    defaultValue: "Jakarta",
  );
}
