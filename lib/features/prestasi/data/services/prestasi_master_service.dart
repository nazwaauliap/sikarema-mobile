import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';

/// =====================================================================
/// PRESTASI MASTER SERVICE (Placeholder)
/// =====================================================================
/// Menyediakan data master untuk dropdown Kategori & Tingkat pada form
/// Tambah Prestasi. Saat ini masih berupa data statis karena endpoint
/// master API belum tersedia.
///
/// CATATAN PENTING:
/// Signature method sengaja dibuat `Future<List<MasterOption>>` (async),
/// persis seperti pola service lain (PrestasiService) yang memanggil
/// API sungguhan. Ini membuat perpindahan ke API nanti sangat mudah:
/// cukup ganti isi method di bawah dengan panggilan Dio, tanpa perlu
/// mengubah TambahPrestasiScreen (UI) sama sekali, karena UI hanya
/// bergantung pada Future<List<MasterOption>> yang dikembalikan.
///
/// Contoh migrasi nanti (ilustrasi, belum diimplementasikan):
/// ```dart
/// Future<List<MasterOption>> getKategoriList() async {
///   final response = await _dio.get('/master/kategori');
///   final data = response.data['data'] as List<dynamic>;
///   return data
///       .map((e) => MasterOption(id: e['id'], label: e['nama']))
///       .toList();
/// }
/// ```
class PrestasiMasterService {
  /// Data placeholder kategori prestasi. Sesuaikan id dengan data master
  /// sungguhan begitu API tersedia.
  Future<List<MasterOption>> getKategoriList() async {
    return const [
      MasterOption(id: 1, label: 'Akademik'),
      MasterOption(id: 2, label: 'Non Akademik'),
      MasterOption(id: 3, label: 'Organisasi'),
    ];
  }

  /// Data placeholder tingkat prestasi. Sesuaikan id dengan data master
  /// sungguhan begitu API tersedia.
  Future<List<MasterOption>> getTingkatList() async {
    return const [
      MasterOption(id: 1, label: 'Kampus'),
      MasterOption(id: 2, label: 'Kota/Kabupaten'),
      MasterOption(id: 3, label: 'Provinsi'),
      MasterOption(id: 4, label: 'Nasional'),
      MasterOption(id: 5, label: 'Internasional'),
    ];
  }
}