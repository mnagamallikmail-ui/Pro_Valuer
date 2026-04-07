import 'package:flutter/material.dart';

import 'router.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  // Hook 401 interceptor to trigger GoRouter redirect (authService.notifyListeners already called)
  ApiService.onUnauthorized = () {
    // AuthService.clearSessionOnUnauthorized() is already called in the interceptor.
    // GoRouter listens to AuthService (refreshListenable), so it will auto-redirect to /login.
  };
  runApp(const BwVrApp());
}

class BwVrApp extends StatelessWidget {
  const BwVrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BwVr Report Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
