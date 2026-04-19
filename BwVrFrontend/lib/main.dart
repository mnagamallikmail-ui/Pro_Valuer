import 'package:flutter/material.dart';

import 'router.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hook 401 interceptor
  ApiService.onUnauthorized = () {
    // AuthService.clearSessionOnUnauthorized() is already called in the interceptor.
  };

  // Initialize Real-time synchronization service
  NotificationService().init();

  runApp(const BwVrApp());
}


class BwVrApp extends StatelessWidget {
  const BwVrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pro Valuer Report Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
