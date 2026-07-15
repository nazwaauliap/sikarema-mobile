import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikarema_mobile/app/routes/app_routes.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';
import 'package:sikarema_mobile/features/prestasi/data/services/prestasi_service.dart';

/// =====================================================================
/// PRESTASI SCREEN ("Prestasi Saya")
/// =====================================================================
/// Catatan:
/// - Data diambil dari GET /api/v1/prestasi via PrestasiService.
/// - Filter kategori & pencarian dilakukan di sisi client terhadap data
///   yang sudah diambil dari API (bukan fitur terpisah, murni bagian
///   dari tampilan List Prestasi sesuai mockup).
/// - Tap pada kartu HANYA menyiapkan navigasi ke DetailPrestasiScreen
///   (belum diimplementasikan, lihat TODO di _PrestasiListItem).
/// - Bottom navigation bar ditambahkan agar konsisten dengan Dashboard;
///   tab "Prestasi" aktif karena user sedang berada di halaman ini.
/// =====================================================================

class PrestasiScreen extends StatefulWidget {
  const PrestasiScreen({super.key});

  @override
  State<PrestasiScreen> createState() => _PrestasiScreenState();
}

class _PrestasiScreenState extends State<PrestasiScreen> {
  final PrestasiService _prestasiService = PrestasiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<PrestasiModel> _prestasiList = [];

  String _searchQuery = '';
  String _selectedKategori = 'Semua';

  final List<String> _kategoriTabs = const [
    'Semua',
    'Akademik',
    'Non Akademik',
    'Organisasi',
  ];

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

  List<PrestasiModel> get _filteredList {
    return _prestasiList.where((item) {
      final matchKategori = _selectedKategori == 'Semua'
          ? true
          : item.kategori.toLowerCase() == _selectedKategori.toLowerCase();
      final matchSearch = _searchQuery.isEmpty
          ? true
          : item.namaKegiatan.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      return matchKategori && matchSearch;
    }).toList();
  }

  /// Handle tap pada bottom navigation bar.
  /// Index 0 (Beranda) -> kembali ke DashboardScreen (halaman ini dibuka
  /// dengan push di atas Dashboard, jadi cukup pop).
  /// Index 1 (Prestasi) -> sudah di halaman ini, tidak melakukan apa-apa.
  /// Index 2-4 (Klaim/Riwayat/Akun) -> belum ada halamannya, placeholder.
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.maybePop(context);
        break;
      case 1:
        // Sudah berada di halaman Prestasi.
        break;
      default:
        // TODO(prestasi): Klaim/Riwayat/Akun belum diimplementasikan,
        // di luar scope fitur List Prestasi saat ini.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Prestasi Saya', style: AppTextStyles.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryBlue),
            onPressed: () {
              // TODO(prestasi): Tambah Prestasi belum diimplementasikan
              // pada tahap ini (di luar scope List Prestasi).
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  _SearchField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 12),
                  _KategoriTabs(
                    tabs: _kategoriTabs,
                    selected: _selectedKategori,
                    onSelected: (value) =>
                        setState(() => _selectedKategori = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        onTap: _onBottomNavTap,
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final list = _filteredList;
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
        itemBuilder: (context, index) =>
            _PrestasiListItem(item: list[index]),
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
              'Belum ada prestasi yang ditemukan.',
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
}

/// =====================================================================
/// SEARCH FIELD
/// =====================================================================
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Cari prestasi...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
        prefixIcon: const Icon(Icons.search, color: AppColors.grey),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}

/// =====================================================================
/// KATEGORI TABS
/// =====================================================================
class _KategoriTabs extends StatelessWidget {
  const _KategoriTabs({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tabs;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab == selected;
          return GestureDetector(
            onTap: () => onSelected(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: isSelected ? AppColors.white : AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// =====================================================================
/// PRESTASI LIST ITEM (CARD)
/// =====================================================================
class _PrestasiListItem extends StatelessWidget {
  const _PrestasiListItem({required this.item});

  final PrestasiModel item;

  ({IconData icon, Color background, Color color}) get _kategoriVisual {
    switch (item.kategori.toLowerCase()) {
      case 'akademik':
        return (
          icon: Icons.emoji_events_rounded,
          background: const Color(0xFFFFF3D4),
          color: const Color(0xFFF4B400),
        );
      case 'non akademik':
        return (
          icon: Icons.military_tech_rounded,
          background: AppColors.primaryBlue.withValues(alpha: 0.12),
          color: AppColors.primaryBlue,
        );
      case 'organisasi':
        return (
          icon: Icons.groups_rounded,
          background: AppColors.success.withValues(alpha: 0.15),
          color: AppColors.success,
        );
      default:
        return (
          icon: Icons.workspace_premium_rounded,
          background: AppColors.grey.withValues(alpha: 0.15),
          color: AppColors.grey,
        );
    }
  }

  Color get _statusColor {
    switch (item.status.toLowerCase()) {
      case 'terverifikasi':
      case 'disetujui':
        return AppColors.success;
      case 'ditolak':
        return AppColors.danger;
      case 'menunggu':
        return const Color(0xFFF4B400);
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visual = _kategoriVisual;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.push(AppRoutes.prestasiDetailPath(item.id));
      },
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visual.background,
                shape: BoxShape.circle,
              ),
              child: Icon(visual.icon, size: 20, color: visual.color),
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
                          item.namaKegiatan,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tingkat ${item.tingkat}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 11,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategori',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.kategori,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Tahun',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.tahun,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Status',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.status,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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