import 'package:flutter/material.dart';
import 'package:sikarema_mobile/app/routes/app_router.dart';
import 'package:sikarema_mobile/app/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SIKAREMA',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
