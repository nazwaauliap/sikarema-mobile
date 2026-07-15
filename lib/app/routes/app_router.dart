import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/welcome_screen.dart';
import 'package:sikarema_mobile/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sikarema_mobile/features/prestasi/presentation/pages/detail_prestasi_screen.dart';
import 'package:sikarema_mobile/features/prestasi/presentation/pages/prestasi_screen.dart';

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
      GoRoute(
        path: AppRoutes.prestasi,
        pageBuilder: (BuildContext context, GoRouterState state) {
          // Tanpa animasi transisi, supaya perpindahan dari Dashboard
          // terasa seperti berganti tab, bukan berpindah halaman.
          return CustomTransitionPage(
            key: state.pageKey,
            child: const PrestasiScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.prestasiDetail,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final idParam = state.pathParameters['id'];
          final id = int.tryParse(idParam ?? '') ?? 0;
          return CustomTransitionPage(
            key: state.pageKey,
            child: DetailPrestasiScreen(id: id),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
    ],
  );
}