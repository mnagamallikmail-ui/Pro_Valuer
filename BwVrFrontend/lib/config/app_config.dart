class AppConfig {
<<<<<<< HEAD
  /// Base API URL for the backend.
  /// Override at build time with: --dart-define=API_BASE_URL=https://your-backend.com/api/v1/
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1/',
  );

  static const String apiBaseUrl = baseUrl;

  static const String templatesUrl = '/templates';
  static const String reportsUrl = '/reports';
  static const String filesUrl = '/files';

  /// Swagger UI URL for the backend.
  /// Override at build time with: --dart-define=SWAGGER_URL=https://your-backend.com/swagger-ui.html
  static const String swaggerUrl = String.fromEnvironment(
    'SWAGGER_URL',
    defaultValue: 'http://localhost:8080/swagger-ui.html',
  );

  /// Actuator health check URL.
  /// Override at build time with: --dart-define=HEALTH_URL=https://your-backend.com/actuator/health
  static const String healthUrl = String.fromEnvironment(
    'HEALTH_URL',
    defaultValue: 'http://localhost:8080/actuator/health',
  );

  static const int defaultPageSize = 20;
  static const int maxFileSizeMb = 50;
}
=======
  static const String baseUrl =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '/api/v1',
      );

  static const String apiBaseUrl = baseUrl;
}
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
