import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/core/storage/storage_service.dart';
import 'package:sikarema_mobile/features/auth/data/services/auth_service.dart';
import 'package:sikarema_mobile/features/profile/data/models/profile_model.dart';
import 'package:sikarema_mobile/features/profile/data/services/profile_service.dart';

/// =====================================================================
/// AKUN SCREEN (tab "Akun" pada Bottom Navigation)
/// =====================================================================
/// Halaman TAMPILAN SAJA (read-only) — tidak ada edit profil, upload
/// foto, atau ubah password.
///
/// SUMBER DATA: ProfileService.getProfile() (GET /profile). Field pada
/// StudentProfileModel BELUM DIKONFIRMASI dari response asli backend
/// (lihat catatan di profile_model.dart) — akan tampil kosong kalau
/// nama field meleset, bukan crash.
///
/// LOGOUT: memakai StorageService.removeToken() + removeUser() yang
/// SUDAH ADA sebelumnya (tidak ada method logout() lain di project
/// ini untuk di-reuse), lalu navigasi ke AppRoutes.welcome (route yang
/// sudah ada). Tidak ada business logic baru yang dibuat.
///
/// ROUTING: layar ini BELUM didaftarkan ke app_router.dart / belum
/// disambungkan dari tab Akun di Dashboard/Prestasi/Klaim/Riwayat,
/// karena keempat file + routing itu ada di daftar "jangan diubah".
/// Untuk navigasi KELUAR dari layar ini (ke tab lain), dipakai route
/// yang SUDAH ADA (AppRoutes.prestasi/klaimLanding/riwayatKlaim).
/// =====================================================================
class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;
  StudentProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _profileService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = response.data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Tidak dapat memuat data akun.')
          : 'Tidak dapat memuat data akun.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Tidak dapat memuat data akun.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onLogoutConfirmed() async {
    // Panggil POST /logout dulu (best-effort). Kalau gagal (mis. token
    // sudah expired / tidak ada koneksi), tetap lanjut hapus data lokal
    // supaya user tidak terjebak tidak bisa logout dari device-nya.
    final token = await StorageService().getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _authService.logout(token);
      } catch (_) {
        // Sengaja diabaikan — logout lokal tetap harus jalan.
      }
    }

    await StorageService().removeToken();
    await StorageService().removeUser();
    if (!mounted) return;
    context.go(AppRoutes.welcome);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Keluar dari aplikasi?',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _onLogoutConfirmed();
              },
              child: Text(
                'Keluar',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: _AkunHeader(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.maybePop(context);
              break;
            case 1:
              context.push(AppRoutes.prestasi);
              break;
            case 2:
              context.push(AppRoutes.klaimLanding);
              break;
            case 3:
              context.push(AppRoutes.riwayatKlaim);
              break;
            case 4:
              // Sudah berada di halaman Akun.
              break;
          }
        },
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

  Widget _buildBody() {
    if (_isLoading) {
      return const _AkunSkeleton();
    }

    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _fetchProfile);
    }

    final profile = _profile;
    if (profile == null) {
      return _ErrorState(
        message: 'Tidak dapat memuat data akun.',
        onRetry: _fetchProfile,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _ProfileCard(profile: profile),
        const SizedBox(height: 14),
        _InfoMahasiswaCard(profile: profile),
        const SizedBox(height: 14),
        const _TentangAplikasiCard(),
        const SizedBox(height: 20),
        _LogoutButton(onTap: _showLogoutDialog),
      ],
    );
  }
}

/// =====================================================================
/// HEADER (judul + subtitle + logo kanan via Image.asset)
/// =====================================================================
class _AkunHeader extends StatelessWidget {
  const _AkunHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Informasi akun Anda yang terdaftar di SIKAREMA.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // User akan mengganti file PNG ini sendiri di
        // assets/images/profile_header.png (folder assets/images/
        // sudah terdaftar di pubspec.yaml).
        SizedBox(
          width: 75,
          height: 75,
          child: Image.asset(
            'assets/images/profile_header.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// CARD PROFIL (avatar + nama + NIM)
/// =====================================================================
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final StudentProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: const Icon(
              Icons.person,
              color: AppColors.primaryBlue,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nama.isEmpty ? '-' : profile.nama,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'NIM',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        profile.nim.isEmpty ? '-' : profile.nim,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12.5,
                          color: AppColors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
/// CARD INFORMASI MAHASISWA
/// =====================================================================
class _InfoMahasiswaCard extends StatelessWidget {
  const _InfoMahasiswaCard({required this.profile});

  final StudentProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.email_outlined, label: 'Email', value: profile.email),
      (
        icon: Icons.school_outlined,
        label: 'Program Studi',
        value: profile.programStudi,
      ),
      (
        icon: Icons.account_balance_outlined,
        label: 'Fakultas',
        value: profile.fakultas,
      ),
      (
        icon: Icons.menu_book_outlined,
        label: 'Semester',
        value: profile.semester,
      ),
      (icon: Icons.groups_outlined, label: 'Kelas', value: profile.kelas),
      (
        icon: Icons.assignment_ind_outlined,
        label: 'Status Mahasiswa',
        value: profile.statusMahasiswa,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Mahasiswa',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            _InfoRow(
              icon: items[i].icon,
              label: items[i].label,
              value: items[i].value.isEmpty ? '-' : items[i].value,
            ),
            if (i != items.length - 1)
              Divider(height: 20, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.5,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// CARD TENTANG APLIKASI (info saja, belum ada navigasi)
/// =====================================================================
class _TentangAplikasiCard extends StatelessWidget {
  const _TentangAplikasiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryBlue,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang Aplikasi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versi 1.0.0',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
        ],
      ),
    );
  }
}

/// =====================================================================
/// TOMBOL LOGOUT
/// =====================================================================
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          'Keluar',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.danger,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// =====================================================================
/// LOADING (skeleton, bukan fullscreen spinner)
/// =====================================================================
class _AkunSkeleton extends StatelessWidget {
  const _AkunSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double width = double.infinity, double height = 12}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    Widget cardShell({required Widget child}) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: child,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        cardShell(
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(width: 140, height: 15),
                    const SizedBox(height: 10),
                    bar(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        cardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(width: 130, height: 14),
              const SizedBox(height: 16),
              for (var i = 0; i < 4; i++) ...[
                bar(height: 12),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// ERROR STATE
/// =====================================================================
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              'Terjadi kesalahan.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}