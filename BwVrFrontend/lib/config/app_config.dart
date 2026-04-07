class AppConfig {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String apiBaseUrl = baseUrl;

  static const String templatesUrl = '$baseUrl/templates';
  static const String reportsUrl = '$baseUrl/reports';
  static const String filesUrl = '$baseUrl/files';

  static const String swaggerUrl = 'http://localhost:8080/swagger-ui.html';
  static const String healthUrl = 'http://localhost:8080/actuator/health';

  static const int defaultPageSize = 20;
  static const int maxFileSizeMb = 50;
}
