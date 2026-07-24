import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/services/klaim_reward_service.dart';
import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';
import 'package:sikarema_mobile/features/prestasi/data/services/prestasi_service.dart';

/// =====================================================================
/// KONFIRMASI KLAIM SCREEN (STEP 1 & STEP 2 — Flow Klaim Reward dari
/// Detail Prestasi)
/// =====================================================================
/// Catatan:
/// - SENGAJA memakai ulang PrestasiService.getPrestasiById() &
///   DetailPrestasiModel yang sudah ada (bukan service/model baru),
///   karena field yang perlu ditampilkan di sini (nama, tingkat,
///   kategori, tahun, penyelenggara) persis sama dengan data yang
///   sudah diambil GET /api/v1/prestasi/{id} untuk halaman Detail
///   Prestasi.
/// - Backend TIDAK mendukung dropdown periode/reward/upload/rekening
///   pada endpoint klaim (lihat catatan project), jadi field tersebut
///   sengaja tidak ditampilkan di sini — hanya info text yang
///   menjelaskan bahwa periode & reward ditentukan otomatis sistem.
/// - STEP 2: Tombol "Ajukan Klaim" sudah memanggil
///   POST /klaim-reward via KlaimRewardService, dengan body HANYA
///   { "id_prestasi": idPrestasi } sesuai Postman Collection.
/// - Saat request berlangsung, tombol menampilkan loading dan
///   dinonaktifkan (mencegah submit ganda).
/// - Navigasi ke halaman Success BELUM diimplementasikan (itu tahap
///   berikutnya, menunggu review) — untuk sementara hasil sukses/gagal
///   ditampilkan lewat SnackBar, konsisten dengan pola error handling
///   DioException yang sudah dipakai di PrestasiService/DetailPrestasi.
/// =====================================================================

class KonfirmasiKlaimScreen extends StatefulWidget {
  const KonfirmasiKlaimScreen({super.key, required this.idPrestasi});

  final int idPrestasi;

  @override
  State<KonfirmasiKlaimScreen> createState() => _KonfirmasiKlaimScreenState();
}

class _KonfirmasiKlaimScreenState extends State<KonfirmasiKlaimScreen> {
  final PrestasiService _prestasiService = PrestasiService();
  final KlaimRewardService _klaimRewardService = KlaimRewardService();

  bool _isLoading = true;
  String? _errorMessage;
  DetailPrestasiModel? _detail;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _prestasiService.getPrestasiById(
        widget.idPrestasi,
      );
      if (!mounted) return;
      setState(() {
        _detail = response.data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal memuat data prestasi.')
          : 'Terjadi kesalahan saat memuat data prestasi.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data prestasi.';
        _isLoading = false;
      });
    }
  }

  /// STEP 2: memanggil POST /klaim-reward via KlaimRewardService.
  /// Body HANYA { "id_prestasi": idPrestasi }, sesuai Postman Collection
  /// (backend menentukan periode & reward otomatis).
  ///
  /// TODO(klaim_reward): navigasi ke halaman Success belum
  /// diimplementasikan — menunggu review Step 2 sebelum lanjut ke tahap
  /// berikutnya. Untuk sementara hasil ditampilkan lewat SnackBar.
  Future<void> _onAjukanKlaim() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _klaimRewardService.submitKlaimReward(
        idPrestasi: widget.idPrestasi,
      );
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Klaim reward berhasil diajukan.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Gagal mengajukan klaim reward.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal mengajukan klaim reward.')
          : 'Terjadi kesalahan saat mengajukan klaim reward.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengajukan klaim reward.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Konfirmasi Klaim', style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final detail = _detail;
    if (detail == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrestasiSummaryCard(detail: detail),
          const SizedBox(height: 16),
          const _AutoInfoBox(),
          const SizedBox(height: 24),
          _AjukanKlaimButton(
            onTap: _onAjukanKlaim,
            isSubmitting: _isSubmitting,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.grey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Data prestasi tidak ditemukan.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
              onPressed: _fetchDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================================================================
/// CARD RINGKASAN PRESTASI: Nama, Tingkat, Kategori, Tahun, Penyelenggara
/// =====================================================================
class _PrestasiSummaryCard extends StatelessWidget {
  const _PrestasiSummaryCard({required this.detail});

  final DetailPrestasiModel detail;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prestasi',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 11,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.namaKegiatan,
            style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tingkat ${detail.tingkat}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.category_outlined,
                  label: 'Kategori',
                  value: detail.kategori,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tahun',
                  value: detail.tahun,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoItem(
            icon: Icons.apartment_outlined,
            label: 'Penyelenggara',
            value: detail.penyelenggara,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// INFO BOX: Periode & Reward ditentukan otomatis sistem
/// =====================================================================
class _AutoInfoBox extends StatelessWidget {
  const _AutoInfoBox();

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
            child: Text(
              'Periode dan Reward akan ditentukan otomatis oleh sistem '
              'setelah klaim diproses.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.5,
                color: AppColors.primaryBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// TOMBOL "AJUKAN KLAIM"
/// =====================================================================
/// Gaya gradient mengikuti tombol "Ajukan Klaim Reward" di Detail
/// Prestasi, agar konsisten secara visual antar halaman flow klaim.
/// Menampilkan loading spinner & dinonaktifkan saat request sedang
/// berlangsung (mencegah submit ganda).
class _AjukanKlaimButton extends StatelessWidget {
  const _AjukanKlaimButton({
    required this.onTap,
    required this.isSubmitting,
  });

  final VoidCallback onTap;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isSubmitting ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2563EB).withValues(
                  alpha: isSubmitting ? 0.6 : 1,
                ),
                const Color(0xFF0EA5E9).withValues(
                  alpha: isSubmitting ? 0.6 : 1,
                ),
                const Color(0xFF10B981).withValues(
                  alpha: isSubmitting ? 0.6 : 1,
                ),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Text(
                    'Ajukan Klaim',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}