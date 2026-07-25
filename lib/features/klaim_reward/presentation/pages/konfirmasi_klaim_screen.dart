import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/models/klaim_reward_model.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/services/klaim_reward_master_service.dart';
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
///   karena field ringkasan prestasi (nama, tingkat, kategori, tahun,
///   penyelenggara) persis sama dengan data yang sudah diambil
///   GET /api/v1/prestasi/{id} untuk halaman Detail Prestasi.
/// - Kontrak API POST /klaim-reward SUDAH DIKONFIRMASI (via Postman +
///   pengecekan database oleh pemilik project) mewajibkan 3 field:
///   id_prestasi, id_periode, id_reward. Spesifikasi awal ("tidak ada
///   field lain") ternyata tidak sesuai backend sungguhan, jadi info
///   box "ditentukan otomatis" pada versi sebelumnya DIHAPUS dan
///   diganti 2 dropdown pilihan (Periode & Jenis Reward).
/// - Jenis Reward diambil dari API sungguhan: GET /jenis-reward
///   (via KlaimRewardService.getJenisRewardList()).
/// - Periode Klaim memakai DATA STATIS (KlaimRewardMasterService),
///   karena backend TIDAK punya endpoint API untuk daftar periode
///   (hanya ada route web admin, bukan API mobile) — nilai id & label
///   diambil dari isi tabel `periode_klaims` di database sungguhan,
///   dikonfirmasi oleh pemilik project, bukan tebakan.
/// - Reward yang tingkatnya cocok dengan tingkat prestasi (field
///   `tingkat` pada JenisRewardModel vs `detail.tingkat`) otomatis
///   dipilihkan sebagai default (bisa diganti manual oleh mahasiswa).
///   Periode tidak di-default-kan (tidak ada sinyal data yang relevan
///   untuk menentukan pilihan otomatis), mahasiswa wajib memilih.
/// - Tombol "Ajukan Klaim" disabled selama Periode & Jenis Reward
///   belum dipilih, dan menampilkan loading + disabled saat request
///   POST /klaim-reward sedang berlangsung (mencegah submit ganda).
/// - Navigasi ke halaman Success BELUM diimplementasikan (tahap
///   berikutnya, menunggu review) — hasil sukses/gagal masih lewat
///   SnackBar, konsisten dengan pola error handling DioException yang
///   sudah dipakai di PrestasiService/DetailPrestasiScreen.
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
  final KlaimRewardMasterService _klaimRewardMasterService =
      KlaimRewardMasterService();

  bool _isLoading = true;
  String? _errorMessage;
  DetailPrestasiModel? _detail;

  List<MasterOption> _periodeList = [];
  List<JenisRewardModel> _rewardList = [];

  MasterOption? _selectedPeriode;
  JenisRewardModel? _selectedReward;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _prestasiService.getPrestasiById(widget.idPrestasi),
        _klaimRewardService.getJenisRewardList(),
        _klaimRewardMasterService.getPeriodeList(),
      ]);

      if (!mounted) return;

      final detail =
          (results[0] as DetailPrestasiResponse).data;
      final rewardList = (results[1] as JenisRewardResponse).data;
      final periodeList = results[2] as List<MasterOption>;

      // Default pilih reward yang tingkatnya cocok dengan tingkat
      // prestasi (case-insensitive), jika ada. Mahasiswa tetap bisa
      // mengganti pilihan secara manual.
      JenisRewardModel? defaultReward;
      for (final reward in rewardList) {
        if (reward.tingkat.toLowerCase() == detail.tingkat.toLowerCase()) {
          defaultReward = reward;
          break;
        }
      }

      setState(() {
        _detail = detail;
        _rewardList = rewardList;
        _periodeList = periodeList;
        _selectedReward = defaultReward;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal memuat data.')
          : 'Terjadi kesalahan saat memuat data.';
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
        _isLoading = false;
      });
    }
  }

  /// STEP 2: memanggil POST /klaim-reward via KlaimRewardService, dengan
  /// { id_prestasi, id_periode, id_reward } sesuai kontrak API
  /// sungguhan.
  ///
  /// TODO(klaim_reward): navigasi ke halaman Success belum
  /// diimplementasikan — menunggu review Step 2 sebelum lanjut ke tahap
  /// berikutnya. Untuk sementara hasil ditampilkan lewat SnackBar.
  Future<void> _onAjukanKlaim() async {
    if (_isSubmitting) return;

    final periode = _selectedPeriode;
    final reward = _selectedReward;
    if (periode == null || reward == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Periode Klaim dan Jenis Reward terlebih dahulu.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _klaimRewardService.submitKlaimReward(
        idPrestasi: widget.idPrestasi,
        idPeriode: periode.id,
        idReward: reward.idReward,
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

    final canSubmit = _selectedPeriode != null && _selectedReward != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrestasiSummaryCard(detail: detail),
          const SizedBox(height: 20),
          Text(
            'Periode Klaim',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          _DropdownField<MasterOption>(
            hint: 'Pilih periode klaim',
            value: _selectedPeriode,
            items: _periodeList,
            labelBuilder: (item) => item.label,
            onChanged: (value) => setState(() => _selectedPeriode = value),
          ),
          const SizedBox(height: 16),
          Text(
            'Jenis Reward yang Diajukan',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          _DropdownField<JenisRewardModel>(
            hint: 'Pilih jenis reward',
            value: _selectedReward,
            items: _rewardList,
            labelBuilder: (item) =>
                '${item.namaReward} (${item.nominalFormatted})',
            onChanged: (value) => setState(() => _selectedReward = value),
          ),
          const SizedBox(height: 24),
          _AjukanKlaimButton(
            onTap: _onAjukanKlaim,
            isSubmitting: _isSubmitting,
            isEnabled: canSubmit,
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
              onPressed: _fetchInitialData,
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
/// DROPDOWN FIELD GENERIK (Periode Klaim & Jenis Reward)
/// =====================================================================
/// Styling rounded + border abu-abu tipis, konsisten dengan gaya field
/// input pada LoginScreen (border radius 16, border grey.shade300).
class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    labelBuilder(item),
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// =====================================================================
/// TOMBOL "AJUKAN KLAIM"
/// =====================================================================
/// Gaya gradient mengikuti tombol "Ajukan Klaim Reward" di Detail
/// Prestasi, agar konsisten secara visual antar halaman flow klaim.
/// - isEnabled=false: tombol pudar & tidak bisa ditekan (Periode/Reward
///   belum dipilih).
/// - isSubmitting=true: tombol menampilkan loading spinner & dinon-
///   aktifkan sementara (mencegah submit ganda).
class _AjukanKlaimButton extends StatelessWidget {
  const _AjukanKlaimButton({
    required this.onTap,
    required this.isSubmitting,
    required this.isEnabled,
  });

  final VoidCallback onTap;
  final bool isSubmitting;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isSubmitting || !isEnabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isDisabled ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2563EB).withValues(
                  alpha: isDisabled ? 0.5 : 1,
                ),
                const Color(0xFF0EA5E9).withValues(
                  alpha: isDisabled ? 0.5 : 1,
                ),
                const Color(0xFF10B981).withValues(
                  alpha: isDisabled ? 0.5 : 1,
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