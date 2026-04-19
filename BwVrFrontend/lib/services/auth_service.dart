import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AuthSession {
  final String token;
  final String username;
  final String? fullName;
  final List<String> roles;
  final bool mustChangePassword;

  const AuthSession({
    required this.token,
    required this.username,
    this.fullName,
    required this.roles,
    required this.mustChangePassword,
  });

  bool get isAdmin => roles.contains('ROLE_ADMIN');

  String get displayName => (fullName != null && fullName!.isNotEmpty) ? fullName! : username;
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AuthSession? _session;
  AuthSession? get session => _session;
  bool get isLoggedIn => _session != null;

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── Login ───────────────────────────────────────────────────────────────────

  Future<AuthSession> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode != 200) {
        final msg = response.data?['message'] ?? 'Login failed';
        throw Exception(msg);
      }

      final data = response.data['data'] as Map<String, dynamic>;
      final session = AuthSession(
        token: data['token'] ?? '',
        username: data['username'] ?? username,
        fullName: data['fullName'],
        roles: List<String>.from(data['roles'] ?? []),
        mustChangePassword: data['mustChangePassword'] ?? false,
      );

      _session = session;
      notifyListeners();
      return session;
    } on DioException catch (e) {
      final serverData = e.response?.data;
      String msg = 'Login failed. Check your credentials.';
      if (serverData is Map) {
        msg = serverData['message'] ?? msg;
      }
      throw Exception(msg);
    }
  }

  // ── Signup ──────────────────────────────────────────────────────────────────

  Future<String> signup({
    required String username,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': username,
        'fullName': fullName,
        'password': password,
      });

      final data = response.data;
      if (response.statusCode != 200) {
        final msg = data?['message'] ?? 'Signup failed';
        throw Exception(msg);
      }
      return data['message'] ?? 'Signup request submitted. Awaiting admin approval.';
    } on DioException catch (e) {
      final serverData = e.response?.data;
      String msg = 'Signup failed. Please try again.';
      if (serverData is Map) {
        msg = serverData['message'] ?? msg;
      }
      throw Exception(msg);
    }
  }

  // ── Logout / Session clear ──────────────────────────────────────────────────

  void logout() {
    _session = null;
    notifyListeners();
  }

  /// Called automatically by the auth interceptor on 401 responses.
  void clearSessionOnUnauthorized() {
    if (_session != null) {
      _session = null;
      notifyListeners();
    }
  }

  String? get token => _session?.token;

  /// Creates a Dio instance pre-configured with the current JWT Bearer token.
  Dio createAuthenticatedDio() {
    return Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
  }
}
