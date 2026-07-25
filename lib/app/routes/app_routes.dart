class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const prestasi = '/prestasi';

  /// Route Tambah Prestasi. Didaftarkan SEBELUM pattern prestasiDetail
  /// di app_router.dart, supaya path ini tidak tertangkap oleh
  /// pattern '/prestasi/:id'.
  static const tambahPrestasi = '/prestasi/tambah';

  /// Pattern route untuk Detail Prestasi, didaftarkan di GoRouter.
  static const prestasiDetail = '/prestasi/:id';

  /// Helper untuk membangun path detail prestasi dengan id sungguhan,
  /// dipakai saat navigasi dari PrestasiScreen.
  static String prestasiDetailPath(int id) => '/prestasi/$id';

  /// Landing Page Menu Klaim (diakses dari Bottom Navigation "Klaim").
  /// Berisi penjelasan alur klaim + tombol menuju Step 1 (Pilih
  /// Prestasi). TIDAK mengubah flow klaim yang sudah ada, hanya jadi
  /// halaman perantara sebelum masuk ke pilihPrestasiKlaim.
  static const klaimLanding = '/klaim-reward';

  /// Flow Klaim Reward dari Detail Prestasi: Konfirmasi Klaim.
  /// Pattern route, didaftarkan di GoRouter.
  static const konfirmasiKlaim = '/klaim-reward/konfirmasi/:id';

  /// Helper untuk membangun path Konfirmasi Klaim dengan id prestasi
  /// sungguhan, dipakai saat navigasi dari DetailPrestasiScreen.
  static String konfirmasiKlaimPath(int idPrestasi) =>
      '/klaim-reward/konfirmasi/$idPrestasi';
}