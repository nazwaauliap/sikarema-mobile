import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/welcome_screen.dart';
import 'package:sikarema_mobile/features/dashboard/presentation/pages/dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) {
          return SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (BuildContext context, GoRouterState state) {
          return WelcomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          return LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (BuildContext context, GoRouterState state) {
          return DashboardScreen();
        },
      ),
    ],
  );
}
