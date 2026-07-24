import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';
import 'package:sikarema_mobile/features/prestasi/data/services/prestasi_service.dart';

/// =====================================================================
/// STEP 1 — PILIH PRESTASI (Klaim Reward)
/// =====================================================================
/// Catatan:
/// - Sengaja MEMAKAI ULANG PrestasiService & PrestasiModel yang sudah ada
///   (bukan membuat service/model baru), karena datanya persis sama
///   dengan GET /api/v1/prestasi yang sudah dipakai fitur Prestasi.
/// - Endpoint /prestasi TIDAK memfilter status di backend, jadi filter
///   "hanya yang sudah disetujui" dilakukan di sini, memakai NILAI ASLI
///   yang dikembalikan API (field `status`, nilai "Terverifikasi" sesuai
///   enum status_verifikasi backend & contoh response Postman Anda),
///   bukan asumsi dari mockup.
/// - Setelah memilih 1 prestasi, tombol "Lanjut" aktif. Navigasi ke
///   Step 2 (Konfirmasi) belum didaftarkan (menunggu Step tersebut
///   diimplementasikan), jadi untuk sementara ditandai TODO — konsisten
///   dengan pola TODO yang sudah ada di PrestasiScreen untuk tab
///   Klaim/Riwayat yang belum diimplementasikan.
/// =====================================================================

class PilihPrestasiKlaimScreen extends StatefulWidget {
  const PilihPrestasiKlaimScreen({super.key});

  @override
  State<PilihPrestasiKlaimScreen> createState() =>
      _PilihPrestasiKlaimScreenState();
}

class _PilihPrestasiKlaimScreenState extends State<PilihPrestasiKlaimScreen> {
  final PrestasiService _prestasiService = PrestasiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<PrestasiModel> _prestasiList = [];

  PrestasiModel? _selectedPrestasi;

  /// Nilai status yang dianggap "sudah disetujui", persis sesuai nilai
  /// enum status_verifikasi di backend (bukan tebakan/hardcode desain).
  static const String _statusDisetujui = 'Terverifikasi';

  @override
  void initState() {
    super.initState();
    _fetchPrestasi();
  }

  Future<void> _fetchPrestasi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _prestasiService.getPrestasi();
      if (!mounted) return;
      setState(() {
        _prestasiList = response.data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal memuat data prestasi.')
          : 'Terjadi kesalahan saat memuat prestasi.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat prestasi.';
        _isLoading = false;
      });
    }
  }

  /// Hanya prestasi dengan status sesuai nilai asli API yang boleh
  /// diajukan klaim (menghindari klaim atas prestasi yang belum/tidak
  /// diverifikasi).
  List<PrestasiModel> get _eligibleList {
    return _prestasiList
        .where((item) => item.status == _statusDisetujui)
        .toList();
  }

  void _onLanjut() {
    if (_selectedPrestasi == null) return;

    // TODO(klaim_reward): navigasi ke Step 2 (Konfirmasi Klaim) belum
    // didaftarkan karena screen tersebut akan diimplementasikan pada
    // step berikutnya. Sementara tampilkan snackbar sebagai penanda
    // bahwa selection sudah berfungsi dengan benar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Prestasi "${_selectedPrestasi!.namaKegiatan}" dipilih. '
          'Step Konfirmasi menyusul.',
        ),
      ),
    );
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
        title: Text('Ajukan Klaim Reward', style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Langkah 1 dari 2 · Pilih Prestasi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pilih prestasi yang sudah disetujui untuk diajukan klaim.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(child: _buildBody()),
            _buildBottomBar(),
          ],
        ),
      ),
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

    final list = _eligibleList;
    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: _fetchPrestasi,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          final isSelected = _selectedPrestasi?.id == item.id;
          return _PilihPrestasiItem(
            item: item,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedPrestasi = item),
          );
        },
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
              Icons.emoji_events_outlined,
              color: AppColors.grey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada prestasi yang disetujui untuk diklaim.',
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
              onPressed: _fetchPrestasi,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _selectedPrestasi == null ? null : _onLanjut,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Lanjut',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================================================================
/// ITEM PRESTASI YANG BISA DIPILIH
/// =====================================================================
class _PilihPrestasiItem extends StatelessWidget {
  const _PilihPrestasiItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final PrestasiModel item;
  final bool isSelected;
  final VoidCallback onTap;

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
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.grey.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaKegiatan,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tingkat ${item.tingkat}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryBlue : AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}