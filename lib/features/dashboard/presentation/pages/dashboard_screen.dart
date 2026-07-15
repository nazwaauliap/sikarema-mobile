import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/dashboard/data/models/dashboard_model.dart';
import 'package:sikarema_mobile/features/dashboard/data/services/dashboard_service.dart';

/// =====================================================================
/// DASHBOARD SCREEN
/// =====================================================================
/// Catatan:
/// - Data diambil dari GET /api/v1/dashboard via DashboardService.
/// - Pengumuman Terbaru masih dummy karena belum tersedia di endpoint ini.
/// - Tidak ada perubahan pada widget/layout/warna/typografi dashboard.
/// =====================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true;
  String? _errorMessage;
  DashboardModel? _dashboardData;

  final String _userRole = 'Mahasiswa';

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dashboardService.getDashboard();
      if (!mounted) return;
      setState(() {
        _dashboardData = response.data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal memuat data dashboard.')
          : 'Terjadi kesalahan saat memuat dashboard.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat dashboard.';
        _isLoading = false;
      });
    }
  }

  /// Nama dari API dikembalikan huruf kapital semua (mis. "NAZWA AULIA
  /// PUTRI"), diformat ulang menjadi Title Case agar tampilannya konsisten
  /// dengan desain awal ("Nazwa Aulia Putri"). Ini murni format teks,
  /// bukan perubahan desain.
  String get _userName {
    final nama = _dashboardData?.nama.trim() ?? '';
    if (nama.isEmpty) return 'Pengguna';
    return nama
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  // ---------------------------------------------------------------------
  // RINGKASAN: dipetakan dari DashboardModel (data API)
  // ---------------------------------------------------------------------
  List<_SummaryItem> _buildSummary() {
    final data = _dashboardData;
    return [
      _SummaryItem(
        title: 'Prestasi Saya',
        value: '${data?.totalPrestasi ?? 0}',
        subtitle: 'Total Prestasi',
        icon: Icons.emoji_events_rounded,
        iconBackground: const Color(0xFFFFF3D4),
        iconColor: const Color(0xFFF4B400),
      ),
      _SummaryItem(
        title: 'Klaim Saya',
        value: '${data?.menunggu ?? 0}',
        subtitle: 'Dalam Proses',
        icon: Icons.description_outlined,
        iconBackground: AppColors.primaryBlue.withValues(alpha: 0.12),
        iconColor: AppColors.primaryBlue,
      ),
      _SummaryItem(
        title: 'Disetujui',
        value: '${data?.terverifikasi ?? 0}',
        subtitle: 'Reward Disetujui',
        icon: Icons.check_circle,
        iconBackground: AppColors.success.withValues(alpha: 0.15),
        iconColor: AppColors.success,
        valueColor: AppColors.black,
      ),
      _SummaryItem(
        title: 'Ditolak',
        value: '${data?.ditolak ?? 0}',
        subtitle: 'Klaim Ditolak',
        icon: Icons.cancel,
        iconBackground: AppColors.danger.withValues(alpha: 0.12),
        iconColor: AppColors.danger,
        titleColor: AppColors.danger,
        valueColor: AppColors.danger,
      ),
    ];
  }

  // ---------------------------------------------------------------------
  // PENGUMUMAN: masih dummy, belum ada di endpoint /api/v1/dashboard
  // ---------------------------------------------------------------------
  List<_AnnouncementItem> _dummyAnnouncements() {
    return [
      _AnnouncementItem(
        title: 'Periode Klaim Reward',
        description:
            'Periode klaim reward periode Genop 2024/2025 telah dibuka.',
        date: '20 Mei 2025',
      ),
    ];
  }

  // ---------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : _errorMessage != null
            ? _buildErrorState()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSection(userName: _userName, userRole: _userRole),
                    const SizedBox(height: 20),
                    const _BannerSection(),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Ringkasan', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    _SummaryGrid(items: _buildSummary()),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Pengumuman Terbaru',
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 12),
                    ..._dummyAnnouncements().map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnnouncementCard(item: item, onTap: () {}),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        onTap: (index) {
          if (index == 1) {
            // Navigasi ke halaman Prestasi Saya. Index bottom nav
            // sengaja tidak diubah (tetap di Beranda) supaya saat
            // kembali dari Prestasi, tampilan Dashboard tidak berubah.
            context.push(AppRoutes.prestasi);
            return;
          }
          setState(() => _selectedIndex = index);
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

  /// State error minimal, hanya tampil saat fetch gagal (mis. token
  /// kedaluwarsa / tidak ada koneksi). Bukan bagian dari desain final,
  /// murni kebutuhan fungsional integrasi API.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDashboard,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================================================================
/// HEADER SECTION
/// =====================================================================
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.userName, required this.userRole});

  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Halo,', style: AppTextStyles.bodyMedium),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: AppTextStyles.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                userRole,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
              color: AppColors.primaryBlue,
              iconSize: 26,
            ),
          ],
        ),
        const SizedBox(width: 4),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryBlue,
            size: 26,
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// BANNER SECTION
/// =====================================================================
class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0EA5E9), Color(0xFF10B981)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Yuk, Terus Berprestasi, Raih Reward Terbaikmu!',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Klaim reward-mu sekarang dan\ndapatkan apresiasi terbaik!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 68, maxHeight: 68),
            child: Image.asset(
              'assets/images/dashboard.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.emoji_events,
                  color: AppColors.white,
                  size: 60,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// SECTION HEADER (dipakai untuk "Ringkasan" & "Pengumuman Terbaru")
/// =====================================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Lihat Semua',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// SUMMARY GRID + CARD
/// =====================================================================
class _SummaryItem {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.titleColor,
    this.valueColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color? titleColor;
  final Color? valueColor;
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.items});

  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SummaryCard(item: items[0])),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(item: items[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SummaryCard(item: items[2])),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(item: items[3])),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryItem item;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  color: item.titleColor ?? AppColors.black,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 16, color: item.iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.value,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28,
              color: item.valueColor ?? AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// ANNOUNCEMENT CARD
/// =====================================================================
class _AnnouncementItem {
  const _AnnouncementItem({
    required this.title,
    required this.description,
    required this.date,
  });

  final String title;
  final String description;
  final String date;
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item, this.onTap});

  final _AnnouncementItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              child: const Icon(
                Icons.campaign_outlined,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.date,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}