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
}