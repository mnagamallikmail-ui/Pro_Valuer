class AppConfig {
  static const String baseUrl =
      'https://provaluer-production.up.railway.app/api/v1';

  static const String apiBaseUrl = baseUrl;

  static const String templatesUrl = '/templates';
  static const String reportsUrl = '/reports';
  static const String filesUrl = '/files';

  static const String swaggerUrl =
      'https://provaluer-production.up.railway.app/swagger-ui.html';

  static const String healthUrl =
      'https://provaluer-production.up.railway.app/actuator/health';

  static const int defaultPageSize = 20;
  static const int maxFileSizeMb = 50;
}
