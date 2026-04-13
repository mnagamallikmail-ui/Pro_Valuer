class AppConfig {
  // Use String.fromEnvironment for build-time configuration (Dart Define)
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://provaluer-production.up.railway.app/api/v1',
  );
  
  static const String apiBaseUrl = baseUrl;

  static const String templatesUrl = '$baseUrl/templates';
  static const String reportsUrl = '$baseUrl/reports';
  static const String filesUrl = '$baseUrl/files';

  static const String swaggerUrl = String.fromEnvironment(
    'SWAGGER_URL',
    defaultValue: 'https://provaluer-production.up.railway.app/swagger-ui.html',
  );
  
  static const String healthUrl = String.fromEnvironment(
    'HEALTH_URL',
    defaultValue: 'https://provaluer-production.up.railway.app/actuator/health',
  );

  static const int defaultPageSize = 20;
  static const int maxFileSizeMb = 50;
}
