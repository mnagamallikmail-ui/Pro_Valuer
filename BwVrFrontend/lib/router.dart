import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/templates/template_list_screen.dart';
import 'screens/templates/template_upload_screen.dart';
import 'screens/templates/template_confirm_screen.dart';
import 'screens/reports/report_list_screen.dart';
import 'screens/reports/report_create_screen.dart';
import 'screens/reports/report_detail_screen.dart';
import 'screens/reports/report_edit_screen.dart';
import 'screens/admin/admin_users_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = AuthService().isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/change-password';

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }
    if (isLoggedIn && state.matchedLocation == '/login') {
      return '/';
    }
    return null;
  },
  refreshListenable: AuthService(),
  routes: [
    // ── Auth ──────────────────────────────────────────────────────────────────
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordScreen()),

    // ── App ───────────────────────────────────────────────────────────────────
    GoRoute(
        name: 'home', path: '/', builder: (_, __) => const DashboardScreen()),

    // Templates
    GoRoute(path: '/templates', builder: (_, __) => const TemplateListScreen()),
    GoRoute(
        path: '/templates/upload',
        builder: (_, __) => const TemplateUploadScreen()),
    GoRoute(
        path: '/templates/:id/confirm',
        builder: (_, state) => TemplateConfirmScreen(
            templateId: int.parse(state.pathParameters['id']!))),

    // Reports
    GoRoute(path: '/reports', builder: (_, __) => const ReportListScreen()),
    GoRoute(
        path: '/reports/new', builder: (_, __) => const ReportCreateScreen()),
    GoRoute(
        path: '/reports/:id',
        builder: (_, state) => ReportDetailScreen(
            reportId: int.parse(state.pathParameters['id']!))),
    GoRoute(
        path: '/reports/:id/edit',
        builder: (_, state) =>
            ReportEditScreen(reportId: int.parse(state.pathParameters['id']!))),

    // Admin
    GoRoute(
        path: '/admin/users',
        builder: (_, __) => const AdminUsersScreen()),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, size: 64, color: Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => state.namedLocation('home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
