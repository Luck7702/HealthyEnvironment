class Env {
  static const openWeatherKey = String.fromEnvironment('OPENWEATHER_KEY',defaultValue:"b33649d0e72446adb6d184516252407" );

  static const backupKey = String.fromEnvironment('BACKUP_KEY',defaultValue: "test");

  static const debug = bool.fromEnvironment('DEBUG', defaultValue: false);

  static const debugLocation = String.fromEnvironment('LOCATION',defaultValue: "Singapore");
}

