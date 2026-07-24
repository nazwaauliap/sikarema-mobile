import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:sikarema_mobile/features/auth/presentation/pages/welcome_screen.dart';
import 'package:sikarema_mobile/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sikarema_mobile/features/klaim_reward/presentation/pages/konfirmasi_klaim_screen.dart';
import 'package:sikarema_mobile/features/klaim_reward/presentation/pages/pilih_prestasi_klaim_screen.dart';
import 'package:sikarema_mobile/features/prestasi/presentation/pages/detail_prestasi_screen.dart';
import 'package:sikarema_mobile/features/prestasi/presentation/pages/prestasi_screen.dart';
import 'package:sikarema_mobile/features/prestasi/presentation/pages/tambah_prestasi_screen.dart';

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
      // PENTING: route statis '/prestasi/tambah' didaftarkan SEBELUM
      // pattern dinamis '/prestasi/:id' agar tidak salah tertangkap
      // sebagai id (mis. dianggap id = "tambah").
      GoRoute(
        path: AppRoutes.tambahPrestasi,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const TambahPrestasiScreen(),
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
      // Step 1 flow Klaim Reward: Pilih Prestasi.
      GoRoute(
        path: AppRoutes.pilihPrestasiKlaim,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const PilihPrestasiKlaimScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
      // Flow Klaim Reward dari Detail Prestasi: Konfirmasi Klaim.
      GoRoute(
        path: AppRoutes.konfirmasiKlaim,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final idParam = state.pathParameters['id'];
          final idPrestasi = int.tryParse(idParam ?? '') ?? 0;
          return CustomTransitionPage(
            key: state.pageKey,
            child: KonfirmasiKlaimScreen(idPrestasi: idPrestasi),
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