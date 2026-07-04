import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/constants/app_constants.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenHeight < 600;

          final logoSize = math.min(screenWidth * 0.28, 110.0);
          final trophySize = math.min(screenWidth * 0.75, 340.0);

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.secondaryGreen],
              ),
            ),
            child: Stack(
              children: [
                // Decorative translucent circles (top-left & bottom-right)
                Positioned(
                  top: -screenWidth * 0.25,
                  left: -screenWidth * 0.25,
                  child: _buildDecorCircle(screenWidth * 0.6, 0.10),
                ),
                Positioned(
                  bottom: -screenWidth * 0.3,
                  right: -screenWidth * 0.3,
                  child: _buildDecorCircle(screenWidth * 0.7, 0.10),
                ),
                Positioned(
                  top: screenHeight * 0.12,
                  right: -screenWidth * 0.15,
                  child: _buildDecorCircle(screenWidth * 0.35, 0.08),
                ),

                // Simple confetti dots scattered around the illustration
                ..._buildConfetti(screenWidth, screenHeight),

                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              screenHeight -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.07,
                              vertical: isSmallScreen ? 16 : 28,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top Section: Logo
                                SizedBox(
                                  height: screenHeight * 0.14,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/logo/mini-sikarema.png',
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                // Middle Section: Title, Subtitle, Illustration
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title
                                      Text(
                                        AppConstants.appName,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.headlineLarge
                                            .copyWith(
                                              color: AppColors.white,
                                              fontSize: math.min(
                                                screenWidth * 0.09,
                                                36,
                                              ),
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                            ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 0 : 2),

                                      // Subtitle
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          'Sistem Klaim Reward\nPrestasi Mahasiswa',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.92),
                                                fontSize: math.min(
                                                  screenWidth * 0.045,
                                                  18,
                                                ),
                                                height: 1.5,
                                              ),
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 20 : 32),

                                      // Illustration Section
                                      SizedBox(
                                        height: screenHeight * 0.32,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/trophy.png',
                                            width: trophySize,
                                            height: trophySize,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Bottom Section: Buttons
                                Column(
                                  children: [
                                    // Primary Button - Masuk
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.go(AppRoutes.login);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.white,
                                          foregroundColor:
                                              Colors.black87,
                                          elevation: 4,
                                          shadowColor: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Masuk',
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 10 : 14),

                                    // Secondary Button - Belum punya akun
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Silakan hubungi Admin Prestasi.',
                                              ),
                                              backgroundColor:
                                                  AppColors.secondaryGreen,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.white,
                                          backgroundColor: AppColors.white
                                              .withValues(alpha: 0.08),
                                          side: BorderSide(
                                            color: AppColors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Belum punya akun?',
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                                color: AppColors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Decorative translucent circle used in corners of the background.
  Widget _buildDecorCircle(double diameter, double opacity) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: opacity),
      ),
    );
  }

  /// Simple confetti made of small translucent dots scattered near the
  /// illustration area, built purely with Positioned + Container (no
  /// external asset required).
  List<Widget> _buildConfetti(double screenWidth, double screenHeight) {
    final dots = <_ConfettiDot>[
      _ConfettiDot(topFactor: 0.30, leftFactor: 0.12, size: 10, opacity: 0.7),
      _ConfettiDot(topFactor: 0.34, leftFactor: 0.82, size: 8, opacity: 0.6),
      _ConfettiDot(topFactor: 0.50, leftFactor: 0.20, size: 6, opacity: 0.5),
      _ConfettiDot(topFactor: 0.55, leftFactor: 0.88, size: 12, opacity: 0.6),
      _ConfettiDot(topFactor: 0.62, leftFactor: 0.08, size: 7, opacity: 0.55),
      _ConfettiDot(topFactor: 0.40, leftFactor: 0.55, size: 5, opacity: 0.4),
    ];

    return dots
        .map(
          (dot) => Positioned(
            top: screenHeight * dot.topFactor,
            left: screenWidth * dot.leftFactor,
            child: Container(
              width: dot.size,
              height: dot.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: dot.opacity),
              ),
            ),
          ),
        )
        .toList();
  }
}

class _ConfettiDot {
  final double topFactor;
  final double leftFactor;
  final double size;
  final double opacity;

  const _ConfettiDot({
    required this.topFactor,
    required this.leftFactor,
    required this.size,
    required this.opacity,
  });
}
