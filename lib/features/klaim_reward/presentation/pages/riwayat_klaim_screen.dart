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
/// UI REFRESH (tanpa mengubah data/logic):
/// Redesign tampilan supaya lebih compact & konsisten dengan card
/// Prestasi (radius 16, shadow black alpha 0.04 blur 8, icon lingkaran
/// 40px, badge pill radius 6, chevron_right) dan header Landing Klaim.
/// TIDAK ada perubahan pada: service (KlaimRewardService), model
/// (RiwayatKlaimModel/JenisRewardModel), cara fetch data (tetap
/// Future.wait ke GET /klaim-reward + GET /jenis-reward untuk mapping
/// nominal), routing, maupun BottomNavigationBar (tetap 5 item & index
/// yang sama).
///
/// CATATAN LOKASI FILE: instruksi awal meminta path
/// lib/features/klaim/presentation/pages/riwayat_klaim_screen.dart,
/// tapi project ini tidak punya folder fitur "klaim" — semua yang
/// berhubungan klaim reward sudah konsisten hidup di folder fitur
/// "klaim_reward", jadi file ini tetap di lokasi tersebut.
///
/// SUMBER DATA (tidak berubah):
/// - GET /klaim-reward (KlaimRewardService.getRiwayatKlaim()).
/// - GET /jenis-reward (KlaimRewardService.getJenisRewardList()) —
///   dipakai untuk mencocokkan nominal Rupiah, karena response
///   GET /klaim-reward tidak menyertakan nominal. Kalau nama reward
///   tidak match ke data master, nominal tidak ditampilkan (bukan
///   ditebak) — fallback menampilkan nama reward apa adanya.
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

  /// Lookup nominal Rupiah berdasarkan nama reward, dari data master
  /// GET /jenis-reward (bukan tebakan — hasil pencocokan nama persis).
  Map<String, String> _nominalByRewardName = {};

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
      final results = await Future.wait([
        _klaimRewardService.getRiwayatKlaim(),
        _klaimRewardService.getJenisRewardList(),
      ]);

      if (!mounted) return;

      final riwayatResponse = results[0] as RiwayatKlaimResponse;
      final jenisRewardResponse = results[1] as JenisRewardResponse;

      final nominalMap = <String, String>{
        for (final reward in jenisRewardResponse.data)
          reward.namaReward: reward.nominalFormatted,
      };

      setState(() {
        _riwayatList = riwayatResponse.data;
        _nominalByRewardName = nominalMap;
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
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: _RiwayatHeader(),
            ),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: _riwayatList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _riwayatList[index];
        return _RiwayatCard(
          item: item,
          nominalFormatted: _nominalByRewardName[item.reward],
        );
      },
    );
  }
}

/// =====================================================================
/// HEADER
/// =====================================================================
/// Typography & padding disamakan dengan pola judul halaman lain
/// (mis. AppBar "Prestasi Saya" pakai AppTextStyles.titleMedium),
/// dibuat sedikit lebih besar & bold karena berfungsi sebagai judul
/// halaman (tidak ada AppBar), namun spacing dipadatkan supaya tidak
/// menyisakan ruang kosong berlebih di atas card pertama.
class _RiwayatHeader extends StatelessWidget {
  const _RiwayatHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
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
      color: AppColors.warning,
      icon: Icons.hourglass_top_rounded,
      label: statusKlaim.isEmpty ? 'Diproses' : statusKlaim,
    );
  }
}

/// =====================================================================
/// CARD RIWAYAT KLAIM
/// =====================================================================
/// Mengikuti pola card item Prestasi persis: InkWell + Container
/// radius 16, shadow black alpha 0.04 blur 8 offset (0,2), icon
/// lingkaran, badge pill radius 6, chevron_right di kanan judul.
/// Card dibuat lebih compact (padding & spacing internal dipadatkan)
/// dibanding versi sebelumnya.
class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.item, required this.nominalFormatted});

  final RiwayatKlaimModel item;
  final String? nominalFormatted;

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(status.icon, color: status.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.prestasi,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusBadge(status: status),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          nominalFormatted ?? item.reward,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: nominalFormatted != null
                                ? AppColors.primaryBlue
                                : AppColors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(width: 140, height: 13),
                const SizedBox(height: 8),
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