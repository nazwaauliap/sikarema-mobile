import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';
import 'package:sikarema_mobile/features/prestasi/data/services/prestasi_service.dart';

/// =====================================================================
/// DETAIL PRESTASI SCREEN
/// =====================================================================
/// Catatan:
/// - Data diambil dari GET /api/v1/prestasi/{id} via
///   PrestasiService.getPrestasiById().
/// - Field Jenis Prestasi, Lokasi, dan Deskripsi ada di mockup namun
///   tidak tersedia di response API saat ini, sehingga tidak
///   ditampilkan (menghindari data dummy/statis).
/// - Section "Dokumen Pendukung" selalu tampil; jika file_sertifikat
///   null, ditampilkan kondisi kosong (bukan card dokumen).
/// - Tombol "Ajukan Klaim Reward" hanya muncul jika status_verifikasi
///   persis "Disetujui", dan masih disabled (placeholder).
/// - Ilustrasi trofi memakai assets/images/prestasi.png, dengan
///   fallback ke Icon jika asset belum tersedia.
/// =====================================================================

class DetailPrestasiScreen extends StatefulWidget {
  const DetailPrestasiScreen({super.key, required this.id});

  final int id;

  @override
  State<DetailPrestasiScreen> createState() => _DetailPrestasiScreenState();
}

class _DetailPrestasiScreenState extends State<DetailPrestasiScreen> {
  final PrestasiService _prestasiService = PrestasiService();

  bool _isLoading = true;
  String? _errorMessage;
  DetailPrestasiModel? _detail;

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
      final response = await _prestasiService.getPrestasiById(widget.id);
      if (!mounted) return;
      setState(() {
        _detail = response.data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal memuat detail prestasi.')
          : 'Terjadi kesalahan saat memuat detail prestasi.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat detail prestasi.';
        _isLoading = false;
      });
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
        title: Text('Detail Prestasi', style: AppTextStyles.titleMedium),
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

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: _fetchDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(detail: detail),
            const SizedBox(height: 20),
            _InformasiCard(detail: detail),
            const SizedBox(height: 20),
            Text(
              'Dokumen Pendukung',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            detail.fileSertifikatName != null
                ? _DokumenCard(fileName: detail.fileSertifikatName!)
                : const _DokumenEmptyState(),
            if (detail.statusVerifikasi == 'Disetujui') ...[
              const SizedBox(height: 24),
              const _AjukanKlaimButton(),
            ],
          ],
        ),
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
/// HEADER: ilustrasi trofi, judul prestasi, badge tingkat
/// =====================================================================
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.detail});

  final DetailPrestasiModel detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D4),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(18),
          child: Image.asset(
            'assets/images/detail-prestasi-icon.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback jika asset belum tersedia / path berbeda.
              return const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.success,
                size: 44,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          detail.namaKegiatan,
          style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
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
      ],
    );
  }
}

/// =====================================================================
/// INFORMASI PRESTASI: layout dua kolom
/// =====================================================================
class _InformasiCard extends StatelessWidget {
  const _InformasiCard({required this.detail});

  final DetailPrestasiModel detail;

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
        children: [
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.apartment_outlined,
                  label: 'Penyelenggara',
                  value: detail.penyelenggara,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.event_outlined,
                  label: 'Tanggal Perolehan',
                  value: detail.tanggalFormatted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.military_tech_outlined,
                  label: 'Juara',
                  value: detail.juara,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.verified_outlined,
                  label: 'Status',
                  value: detail.statusVerifikasi,
                  valueColor: _statusColorFor(detail.statusVerifikasi),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColorFor(String status) {
    switch (status.toLowerCase()) {
      case 'terverifikasi':
      case 'disetujui':
        return AppColors.success;
      case 'ditolak':
        return AppColors.danger;
      case 'menunggu':
        return const Color(0xFFF4B400);
      default:
        return AppColors.black;
    }
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

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
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// DOKUMEN PENDUKUNG CARD
/// =====================================================================
class _DokumenCard extends StatelessWidget {
  const _DokumenCard({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Icon download disabled — fitur download belum diimplementasikan.
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.download_outlined, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// DOKUMEN PENDUKUNG — EMPTY STATE
/// =====================================================================
/// Ditampilkan saat file_sertifikat null (mahasiswa belum upload
/// dokumen sertifikat untuk prestasi ini).
class _DokumenEmptyState extends StatelessWidget {
  const _DokumenEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.grey.withValues(alpha: 0.6),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada dokumen yang diunggah',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// TOMBOL "AJUKAN KLAIM REWARD"
/// =====================================================================
/// Gaya gradient mengikuti warna yang sudah dipakai pada banner
/// Dashboard (bukan warna baru), agar konsisten secara visual.
/// Tombol masih disabled — fitur klaim reward belum diimplementasikan.
class _AjukanKlaimButton extends StatelessWidget {
  const _AjukanKlaimButton();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: IgnorePointer(
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
          child: Center(
            child: Text(
              'Ajukan Klaim Reward',
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