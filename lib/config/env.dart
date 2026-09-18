class Env {
  static const environmentApiUrl = String.fromEnvironment(
    'ENVIRONMENT_API_URL',
    defaultValue: '/api/environment',
  );

  static const debug = bool.fromEnvironment('DEBUG', defaultValue: false);

  static const debugLocation = String.fromEnvironment(
    'LOCATION',
    defaultValue: "Jakarta",
  );
}
