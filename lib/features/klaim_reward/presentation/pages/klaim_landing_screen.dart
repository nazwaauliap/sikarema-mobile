import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';

/// =====================================================================
/// KLAIM LANDING SCREEN (Menu "Klaim" pada Bottom Navigation)
/// =====================================================================
/// Halaman perantara sebelum masuk ke flow klaim reward yang SUDAH ADA
/// (Detail Prestasi -> tombol "Ajukan Klaim Reward" -> Konfirmasi ->
/// Submit -> Success). Halaman ini TIDAK membuat ulang atau mengubah
/// flow tersebut sama sekali.
///
/// Tombol "Ajukan Klaim Sekarang" mengarah ke AppRoutes.prestasi
/// (halaman Prestasi Saya yang sudah ada), sesuai flow yang diinginkan:
/// Klaim -> Landing Page -> Ajukan Klaim Sekarang -> Prestasi ->
/// Detail Prestasi -> Ajukan Klaim Reward.
///
/// Punya bottomNavigationBar sendiri (BUKAN hasil push tanpa bottom
/// nav) — mengikuti pola yang sudah dipakai PrestasiScreen: setiap
/// halaman top-level di project ini punya BottomNavigationBar sendiri
/// (bukan shared shell/IndexedStack), jadi ini konsisten dengan
/// arsitektur yang sudah ada, bukan pola baru.
///
/// Styling body reuse pola yang sudah dipakai di KonfirmasiKlaimScreen
/// (Scaffold backgroundColor #F5F6F8, card putih rounded 16 + shadow tipis,
/// info box primaryBlue alpha 0.08
/// rounded 14, tombol gradient primaryBlue -> secondaryGreen rounded
/// 14) supaya konsisten secara visual dengan halaman lain di fitur
/// Klaim Reward.
/// =====================================================================
class KlaimLandingScreen extends StatelessWidget {
  const KlaimLandingScreen({super.key});

  static const _steps = [
    _StepData(
      icon: Icons.checklist_rounded,
      title: 'Pilih Prestasi',
      description:
          'Pilih prestasi yang sudah disetujui untuk diajukan klaim reward.',
    ),
    _StepData(
      icon: Icons.fact_check_outlined,
      title: 'Konfirmasi',
      description:
          'Periksa kembali detail prestasi dan reward yang akan diajukan.',
    ),
    _StepData(
      icon: Icons.send_outlined,
      title: 'Ajukan Klaim',
      description: 'Klaim akan diproses oleh admin untuk diverifikasi.',
    ),
    _StepData(
      icon: Icons.check_circle_outline,
      title: 'Selesai',
      description:
          'Klaim berhasil diajukan. Anda dapat memantau status melalui riwayat.',
    ),
  ];

  /// Handle tap pada bottom navigation bar.
  /// Index 0 (Beranda) -> DashboardScreen.
  /// Index 1 (Prestasi) -> push ke halaman Prestasi Saya.
  /// Index 2 (Klaim) -> sudah di halaman ini, tidak melakukan apa-apa.
  /// Index 3-4 (Riwayat/Akun) -> belum ada halamannya, placeholder.
  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.prestasi);
        break;
      case 2:
        // Sudah berada di halaman Klaim.
        break;
      default:
        // TODO(klaim_reward): Riwayat/Akun belum diimplementasikan, di
        // luar scope Landing Page Klaim saat ini.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajukan Klaim Reward',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ikuti langkah berikut untuk mengajukan\nklaim reward Anda.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              _StepsCard(steps: _steps),
              const SizedBox(height: 16),
              const _CatatanPentingBox(),
              const SizedBox(height: 28),
              _AjukanKlaimSekarangButton(
                onTap: () => context.push(AppRoutes.prestasi),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        onTap: (index) => _onBottomNavTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Prestasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Klaim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// =====================================================================
/// CARD 4 LANGKAH
/// =====================================================================
class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps});

  final List<_StepData> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              stepNumber: i + 1,
              data: steps[i],
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.stepNumber,
    required this.data,
    required this.isLast,
  });

  final int stepNumber;
  final _StepData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box + connector line + nomor step (badge)
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        data.icon,
                        color: AppColors.primaryBlue,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$stepNumber',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.5,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// CATATAN PENTING
/// =====================================================================
/// Styling reuse persis dari _AutoInfoBox di KonfirmasiKlaimScreen.
class _CatatanPentingBox extends StatelessWidget {
  const _CatatanPentingBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Penting',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan data prestasi yang Anda pilih sudah benar '
                  'sebelum mengajukan klaim. Klaim yang sudah diajukan '
                  'tidak dapat dibatalkan.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.5,
                    color: AppColors.primaryBlue,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// TOMBOL "AJUKAN KLAIM SEKARANG"
/// =====================================================================
/// Gaya gradient mengikuti tombol lain pada fitur Klaim Reward (Detail
/// Prestasi & Konfirmasi Klaim), agar konsisten secara visual.
class _AjukanKlaimSekarangButton extends StatelessWidget {
  const _AjukanKlaimSekarangButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF0EA5E9),
                Color(0xFF10B981),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ajukan Klaim Sekarang',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
