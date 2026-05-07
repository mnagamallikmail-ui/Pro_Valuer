import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/template_model.dart';
import '../models/report_model.dart';
import 'auth_service.dart';

class ApiService {
  late final Dio _dio;

  // Callback set by main.dart so 401 can trigger navigation without BuildContext
  static void Function()? onUnauthorized;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 600,
    ));

    // Attach JWT token to every request automatically
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthService().token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
      logPrint: (o) => debugPrint('[API] $o'),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode != null &&
            response.statusCode! >= 400 &&
            response.statusCode! < 600) {
          if (response.statusCode == 401 || response.statusCode == 403) {
            // Session expired or unauthorized — clear session and redirect to login
            AuthService().clearSessionOnUnauthorized();
            final callback = ApiService.onUnauthorized;
            if (callback != null) callback();
            return handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'Session expired. Please login again.',
            ));
          }

          String msg = 'Request failed (Error ${response.statusCode})';
          if (response.data is Map) {
            msg = response.data['message'] ?? response.data['error'] ?? msg;
          } else if (response.data is String &&
              response.data.toString().isNotEmpty) {
            msg = response.data.toString();
          }
          return handler.reject(DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: msg,
          ));
        }
        handler.next(response);
      },
    ));
  }

  // ── Connectivity helper ─────────────────────────────────────────────────────

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ── Retry helper ────────────────────────────────────────────────────────────
  // Retries [fn] up to [maxAttempts] times on 5xx or network errors.
  // Backoff: 1 s, 2 s, 4 s …
  Future<Response<T>> _withRetry<T>(
    Future<Response<T>> Function() fn, {
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final response = await fn();
        if (response.statusCode != null && response.statusCode! >= 500) {
          final body = response.data?.toString() ?? '';
          debugPrint('[API] Server error ${response.statusCode} on attempt $attempt: $body');
          if (attempt >= maxAttempts) {
            throw Exception(_serverErrorMessage(response.statusCode!, body));
          }
          // Exponential backoff before next attempt
          await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
          continue;
        }
        return response;
      } on DioException catch (e) {
        debugPrint('[API] DioException on attempt $attempt: ${e.type} – ${e.message}');
        if (attempt >= maxAttempts) {
          throw Exception(_dioErrorMessage(e));
        }
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
          continue;
        }
        // Non-retryable Dio error (e.g. bad URL, cancelled)
        throw Exception(_dioErrorMessage(e));
      }
    }
  }

  String _serverErrorMessage(int statusCode, String body) {
    if (statusCode == 500) return 'Server error — please try again shortly';
    if (statusCode == 502 || statusCode == 503 || statusCode == 504)
      return 'Server is temporarily unavailable — please try again';
    return 'Unexpected server response ($statusCode)';
  }

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out — check your network';
      case DioExceptionType.connectionError:
        return 'Could not reach server — check your connection';
      default:
        final msg = e.response?.data?['message']?.toString() ??
                    e.response?.data?['error']?.toString() ??
                    e.message ??
                    'Unknown network error';
        return msg;
    }
  }


  // ── Template Endpoints ──────────────────────────────────────────────────────

  Future<ParsedTemplateResponse> uploadTemplate({
    required Uint8List fileBytes,
    required String fileName,
    required String bankName,
    required String templateName,
    String uploadedBy = 'SYSTEM',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'bankName': bankName,
        'templateName': templateName,
        'uploadedBy': uploadedBy,
      });

      final response = await _dio.post('templates/upload',
          data: formData, options: Options(contentType: 'multipart/form-data'));
          
      if (response.statusCode != null && response.statusCode! >= 400) {
        final msg = response.data?['message'] ?? 'Upload failed (Error ${response.statusCode})';
        throw Exception(msg);
      }
      
      return ParsedTemplateResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> getTemplates(
      {String? bankName, int page = 0, int size = 20}) async {
    final response = await _dio.get('templates', queryParameters: {
      if (bankName != null && bankName.isNotEmpty) 'bankName': bankName,
      'page': page,
      'size': size,
    });
    return response.data['data'];
  }

  Future<List<TemplateModel>> getTemplateList({String? bankName}) async {
    final data = await getTemplates(bankName: bankName);
    final content = data['content'] as List? ?? [];
    return content.map((t) => TemplateModel.fromJson(t)).toList();
  }

  Future<TemplateModel> getTemplate(int templateId) async {
    final response = await _dio.get('templates/$templateId');
    return TemplateModel.fromJson(response.data['data']);
  }

  Future<List<PlaceholderModel>> getPlaceholders(int templateId) async {
    final response = await _dio.get('templates/$templateId/placeholders');
    final list = response.data['data'] as List? ?? [];
    return list.map((p) => PlaceholderModel.fromJson(p)).toList();
  }

  Future<void> confirmPlaceholders(
      int templateId, List<Map<String, dynamic>> placeholders,
      {String confirmedBy = 'SYSTEM'}) async {
    await _dio.post('templates/$templateId/confirm-placeholders', data: {
      'placeholders': placeholders,
      'confirmedBy': confirmedBy,
    });
  }

  Future<void> deleteTemplate(int templateId,
      {String deletedBy = 'SYSTEM'}) async {
    await _dio.delete('templates/$templateId',
        queryParameters: {'deletedBy': deletedBy});
  }

  Future<void> archiveTemplate(int templateId,
      {String archivedBy = 'SYSTEM'}) async {
    await _dio.patch('templates/$templateId/archive',
        queryParameters: {'archivedBy': archivedBy});
  }

  Future<List<String>> getBankNames() async {
    final response = await _dio.get('templates/banks');
    return List<String>.from(response.data['data'] ?? []);
  }

  // ── Report Endpoints ────────────────────────────────────────────────────────

  Future<ReportModel> createReport({
    required int templateId,
    required String reportTitle,
    String? vendorName,
    String? location,
    String? createdBy,
  }) async {
    // Use the authenticated user's username, not a hardcoded 'SYSTEM'
    final username = createdBy ?? AuthService().session?.username ?? 'SYSTEM';
    try {
      final response = await _dio.post('reports', data: {
        'templateId': templateId,
        'reportTitle': reportTitle,
        'vendorName': vendorName,
        'location': location,
        'createdBy': username,
      });
      return ReportModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      // Extract the backend's specific message (e.g. REPORT_CREATION_ERROR)
      final serverData = e.response?.data;
      String msg = 'Failed to create report. Please try again.';
      if (serverData is Map) {
        msg = serverData['message']?.toString() ??
              serverData['error']?.toString() ?? msg;
      } else if (e.error != null) {
        msg = e.error.toString();
      }
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> searchReports(
      {String? search,
      String? vendorName,
      String? location,
      String? bankName,
      String? status,
      int page = 0,
      int size = 20}) async {
    final response = await _dio.get('reports', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (vendorName != null && vendorName.isNotEmpty) 'vendorName': vendorName,
      if (location != null && location.isNotEmpty) 'location': location,
      if (bankName != null && bankName.isNotEmpty) 'bankName': bankName,
      if (status != null && status.isNotEmpty) 'status': status,
      'page': page,
      'size': size,
    });
    return response.data['data'];
  }

  Future<List<ReportModel>> getReportList({String? search}) async {
    final data = await searchReports(search: search);
    final content = data['content'] as List? ?? [];
    return content.map((r) => ReportModel.fromJson(r)).toList();
  }

  Future<ReportDetailModel> getReport(int reportId) async {
    final response = await _dio.get('reports/$reportId');
    return ReportDetailModel.fromJson(response.data['data']);
  }

  Future<ReportDetailModel> getReportByRef(String referenceNumber) async {
    final response = await _dio.get('reports/ref/$referenceNumber');
    return ReportDetailModel.fromJson(response.data['data']);
  }

  Future<ReportModel> updateReport(int reportId,
      {String? reportTitle,
      String? vendorName,
      String? location,
      String? status,
      String updatedBy = 'SYSTEM'}) async {
    final response = await _dio.put('reports/$reportId', data: {
      if (reportTitle != null) 'reportTitle': reportTitle,
      if (vendorName != null) 'vendorName': vendorName,
      if (location != null) 'location': location,
      if (status != null) 'reportStatus': status,
      'updatedBy': updatedBy,
    });
    return ReportModel.fromJson(response.data['data']);
  }

<<<<<<< HEAD
=======
  Future<ReportModel> submitReport(int reportId) async {
    final response = await _dio.post('reports/$reportId/submit');
    return ReportModel.fromJson(response.data['data']);
  }

  Future<ReportModel> reviewReport(int reportId) async {
    final response = await _dio.post('reports/$reportId/review');
    return ReportModel.fromJson(response.data['data']);
  }

  Future<ReportModel> approveReport(int reportId) async {
    final response = await _dio.post('reports/$reportId/approve');
    return ReportModel.fromJson(response.data['data']);
  }

>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
  Future<void> saveReportValues(int reportId, List<Map<String, dynamic>> values,
      {String updatedBy = 'SYSTEM'}) async {
    await _dio.post('reports/$reportId/values', data: {
      'values': values,
      'updatedBy': updatedBy,
    });
  }

  Future<String> generateReport(int reportId) async {
    final response = await _dio.post('reports/$reportId/generate');
    return response.data['data'] ?? '';
  }

  String getDownloadUrl(int reportId) {
    // Remove trailing slash from apiBaseUrl if it exists to avoid double slashes
    String baseUrl = AppConfig.apiBaseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    
<<<<<<< HEAD
=======
    if (baseUrl.startsWith('/')) {
      baseUrl = Uri.base.origin + baseUrl;
    }

>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
    final url = '$baseUrl/reports/$reportId/download';
    final token = AuthService().token;
    return (token != null && token.isNotEmpty) ? '$url?token=$token' : url;
  }

  Future<void> deleteReport(int reportId, {String deletedBy = 'SYSTEM'}) async {
    await _dio.delete('reports/$reportId',
        queryParameters: {'deletedBy': deletedBy});
  }

  Future<DashboardStats> getDashboardStats() async {
    final response = await _dio.get('reports/dashboard/stats');
    return DashboardStats.fromJson(response.data['data']);
  }

  // ── File Endpoints (Legacy Filesystem) ──────────────────────────────────────

  Future<Map<String, String?>> uploadImage({
    required Uint8List fileBytes,
    required String fileName,
    required int reportId,
    required String placeholderKey,
  }) async {
    if (!await _isOnline()) throw Exception('No internet connection');

    if (fileName.trim().isEmpty) {
      fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    final response = await _withRetry(() {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'reportId': reportId,
        'placeholderKey': placeholderKey,
      });
      return _dio.post('files/upload-image',
          data: formData,
          options: Options(contentType: 'multipart/form-data'));
    });

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return {
      'filePath': data['filePath']?.toString(),
      'imageUrl': data['imageUrl']?.toString(),
      'originalName': data['originalName']?.toString() ?? fileName,
    };
  }


  String getBlobImageUrl(int reportId, String placeholderKey) {
<<<<<<< HEAD
    final url = '${AppConfig.apiBaseUrl}/report-images/$reportId/$placeholderKey';
=======
    String baseUrl = AppConfig.apiBaseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    if (baseUrl.startsWith('/')) {
      baseUrl = Uri.base.origin + baseUrl;
    }
    final url = '$baseUrl/report-images/$reportId/$placeholderKey';
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
    final token = AuthService().token;
    return (token != null && token.isNotEmpty) ? '$url?token=$token' : url;
  }

  // ── Admin User Management ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final response = await _withRetry(() => _dio.get('admin/users'));
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    final response =
        await _withRetry(() => _dio.get('admin/users/pending'));
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> approveUser(int userId) async {
    await _withRetry(() => _dio.post('admin/users/$userId/approve'));
  }

  Future<void> rejectUser(int userId) async {
    await _withRetry(() => _dio.post('admin/users/$userId/reject'));
  }

  Future<void> addAdminUser({required String email, required String fullName, required String password, String role = 'USER'}) async {
    await _withRetry(() => _dio.post('admin/users', data: {
      'username': email,
      'fullName': fullName,
      'password': password,
      'role': role,
    }));
  }

  Future<void> deleteUser(int userId) async {
    await _withRetry(() => _dio.delete('admin/users/$userId'));
  }

  Future<void> updateUserRole(int userId, String role) async {
    await _withRetry(() => _dio.patch('admin/users/$userId/role', queryParameters: {'role': role}));
  }

<<<<<<< HEAD
=======
  Future<void> updateUserValidator(int userId, String validatorUsername) async {
    await _withRetry(() => _dio.patch('admin/users/$userId/validator', queryParameters: {'validatorUsername': validatorUsername}));
  }

>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
  Future<void> updateUserPassword(int userId, String newPassword) async {
    await _withRetry(() => _dio.patch('admin/users/$userId/password', queryParameters: {'newPassword': newPassword}));
  }
}
