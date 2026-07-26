import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/core/helpers/format_helper.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/models/klaim_reward_model.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/services/klaim_reward_service.dart';

/// =====================================================================
/// RIWAYAT KLAIM SCREEN (tab "Riwayat" pada Bottom Navigation)
/// =====================================================================
/// UI FINAL v3 (mengikuti mockup terbaru — source of truth: instruksi
/// user, mockup hanya referensi visual):
/// - Header: judul + subtitle + placeholder logo 80x80 di kanan
///   (Container rounded, siap diganti Image.asset(fit: BoxFit.contain)
///   oleh user nanti).
/// - Search bar: UI SAJA, tidak ada logic filter/pencarian data, tidak
///   ada perubahan ke API.
/// - 4 pill filter status (Semua/Diproses/Disetujui/Ditolak): UI SAJA,
///   toggle warna aktif/tidak aktif murni state tampilan lokal, TIDAK
///   memfilter/menyembunyikan data list (list tetap menampilkan semua
///   item dari API, sesuai instruksi "belum perlu logika filtering").
/// - Info reward: kembali menampilkan `item.reward` APA ADANYA dari
///   API (bukan hasil pencocokan nominal seperti versi sebelumnya).
///   Konsekuensinya, pemanggilan KlaimRewardService.getJenisRewardList()
///   DIHAPUS dari layar ini (sudah tidak dipakai lagi di sini) — method
///   itu sendiri TETAP ada & tidak diubah di service (masih dipakai
///   KonfirmasiKlaimScreen). Sekarang cukup 1 panggilan API:
///   getRiwayatKlaim().
/// - Icon kiri card: kotak rounded (bukan lingkaran) sesuai mockup.
/// - Badge status: baris tersendiri di atas judul (bukan sejajar
///   kanan atas), sesuai mockup.
///
/// Model, service (selain pemanggilan yang disebut di atas), routing,
/// dan BottomNavigationBar TIDAK diubah.
/// =====================================================================
class RiwayatKlaimScreen extends StatefulWidget {
  const RiwayatKlaimScreen({super.key});

  @override
  State<RiwayatKlaimScreen> createState() => _RiwayatKlaimScreenState();
}

class _RiwayatKlaimScreenState extends State<RiwayatKlaimScreen> {
  final KlaimRewardService _klaimRewardService = KlaimRewardService();

  bool _isLoading = true;
  String? _errorMessage;
  List<RiwayatKlaimModel> _riwayatList = [];

  /// State UI murni untuk pill filter status yang aktif secara visual.
  /// TIDAK memengaruhi data yang ditampilkan (belum ada logika
  /// filtering, sesuai instruksi).
  int _selectedFilterIndex = 0;

  static const _filterLabels = ['Semua', 'Diproses', 'Disetujui', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _klaimRewardService.getRiwayatKlaim();
      if (!mounted) return;
      setState(() {
        _riwayatList = response.data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Tidak dapat memuat data riwayat klaim.')
          : 'Tidak dapat memuat data riwayat klaim.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Tidak dapat memuat data riwayat klaim.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: _RiwayatHeader(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SearchBar(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filterLabels.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isActive = index == _selectedFilterIndex;
                  return _FilterPill(
                    label: _filterLabels[index],
                    isActive: isActive,
                    onTap: () => setState(() => _selectedFilterIndex = index),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
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
              // Sudah berada di halaman Riwayat.
              break;
            default:
              // TODO(klaim_reward): Akun belum diimplementasikan, di
              // luar scope Riwayat Klaim saat ini.
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
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const _RiwayatSkeletonCard(),
      );
    }

    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _fetchData);
    }

    if (_riwayatList.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _riwayatList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _RiwayatCard(item: _riwayatList[index]),
    );
  }
}

/// =====================================================================
/// HEADER (judul + subtitle + placeholder logo kanan)
/// =====================================================================
class _RiwayatHeader extends StatelessWidget {
  const _RiwayatHeader();

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
                'Riwayat Klaim',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lihat seluruh pengajuan reward yang pernah Anda ajukan.',
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
        // Placeholder logo/ilustrasi (80x80). User akan mengganti
        // dengan Image.asset(..., fit: BoxFit.contain) sendiri nanti.
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.image_outlined,
            color: AppColors.primaryBlue.withValues(alpha: 0.4),
            size: 28,
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// SEARCH BAR (UI SAJA — tidak ada logic pencarian)
/// =====================================================================
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 126, 124, 124).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.5),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cari berdasarkan prestasi...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.5,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 22,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Icon(
            Icons.tune_rounded,
            size: 20,
            color: AppColors.primaryBlue.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// PILL FILTER STATUS (UI SAJA — tidak memfilter data)
/// =====================================================================
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.white : AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

/// =====================================================================
/// STATUS HELPER (warna, icon, label badge)
/// =====================================================================
class _StatusStyle {
  const _StatusStyle({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  static _StatusStyle fromStatus(String statusKlaim) {
    final lower = statusKlaim.toLowerCase();
    if (lower.contains('setuju')) {
      return _StatusStyle(
        color: AppColors.success,
        icon: Icons.emoji_events_rounded,
        label: statusKlaim.isEmpty ? 'Disetujui' : statusKlaim,
      );
    }
    if (lower.contains('tolak')) {
      return _StatusStyle(
        color: AppColors.danger,
        icon: Icons.cancel_rounded,
        label: statusKlaim.isEmpty ? 'Ditolak' : statusKlaim,
      );
    }
    // Fallback: Diproses/Menunggu/status lain yang belum tercakup.
    return _StatusStyle(
      color: AppColors.primaryBlue,
      icon: Icons.hourglass_top_rounded,
      label: statusKlaim.isEmpty ? 'Diproses' : statusKlaim,
    );
  }
}

/// =====================================================================
/// CARD RIWAYAT KLAIM
/// =====================================================================
class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.item});

  final RiwayatKlaimModel item;

  @override
  Widget build(BuildContext context) {
    final status = _StatusStyle.fromStatus(item.statusKlaim);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(status.icon, color: status.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(status: status),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.prestasi,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Info reward apa adanya dari API, tanpa label
                  // "Reward" dan tanpa pencocokan nominal.
                  Text(
                    item.reward,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.5,
                      color: AppColors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          FormatHelper.tanggalIndo(item.tanggalPengajuan),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            color: AppColors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.folder_outlined,
                        size: 12,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.periode,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
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
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _StatusStyle status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// LOADING (skeleton card, bukan fullscreen spinner)
/// =====================================================================
class _RiwayatSkeletonCard extends StatelessWidget {
  const _RiwayatSkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget bar({double width = double.infinity, double height = 10}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(width: 70, height: 12),
                const SizedBox(height: 8),
                bar(width: 150, height: 13),
                const SizedBox(height: 6),
                bar(width: 90, height: 10),
                const SizedBox(height: 10),
                bar(width: 170, height: 9),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// EMPTY STATE
/// =====================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat klaim.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Riwayat pengajuan reward akan muncul di halaman ini.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push(AppRoutes.prestasi),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                    child: Center(
                      child: Text(
                        'Ajukan Klaim',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
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