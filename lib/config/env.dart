class Env {
  static const environmentApiUrl = String.fromEnvironment(
    'ENVIRONMENT_API_URL',
    defaultValue: '/api/environment',
  );
}
