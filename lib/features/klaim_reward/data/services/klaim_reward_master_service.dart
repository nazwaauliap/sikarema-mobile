import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';

/// =====================================================================
/// KLAIM REWARD MASTER SERVICE (Placeholder untuk Periode)
/// =====================================================================
/// Menyediakan data master untuk dropdown "Periode Klaim" pada halaman
/// Konfirmasi Klaim. Data STATIS/HARDCODE karena backend Laravel TIDAK
/// menyediakan endpoint API untuk daftar periode (hanya ada route web
/// admin `admin/periode-klaim`, bukan endpoint API untuk mobile).
///
/// Nilai id & label di bawah diambil langsung dari isi tabel
/// `periode_klaims` di database (dicek oleh pemilik project), BUKAN
/// tebakan/asumsi dari mockup.
///
/// CATATAN PENTING (mengikuti pola PrestasiMasterService):
/// Signature method sengaja dibuat `Future<List<MasterOption>>` (async),
/// persis seperti pola service lain yang memanggil API sungguhan. Ini
/// membuat migrasi ke API nanti sangat mudah — cukup ganti isi method
/// ini dengan panggilan Dio ke endpoint periode begitu backend
/// menyediakannya, tanpa perlu mengubah UI Konfirmasi Klaim sama
/// sekali (UI hanya bergantung pada Future<List<MasterOption>>).
///
/// Contoh migrasi nanti (ilustrasi, belum diimplementasikan):
/// ```dart
/// Future<List<MasterOption>> getPeriodeList() async {
///   final response = await _dio.get('/periode');
///   final data = response.data['data'] as List<dynamic>;
///   return data
///       .map((e) => MasterOption(id: e['id_periode'], label: e['nama']))
///       .toList();
/// }
/// ```
class KlaimRewardMasterService {
  /// Data statis periode klaim, sesuai isi tabel `periode_klaims`.
  /// Sesuaikan/tambahkan di sini begitu ada data periode baru, atau
  /// ganti seluruh isi method ini begitu endpoint API tersedia.
  Future<List<MasterOption>> getPeriodeList() async {
    return const [
      MasterOption(id: 1, label: 'Semester Genap 2025/2026 Periode 1'),
      MasterOption(id: 2, label: 'Semester Ganjil 2025/2026 Periode 1'),
    ];
  }
}