/// Central place for API-related constants.
class ApiConstants {
  ApiConstants._();

  /// Base URL API sementara untuk integrasi login.
  static const String baseUrl =
      'https://lubricate-cardboard-carwash.ngrok-free.dev/api/v1';

  /// Endpoint login Sanctum.
  static const String loginEndpoint = '/login';

  /// Endpoint dashboard mahasiswa.
  static const String dashboardEndpoint = '/dashboard';

  /// Endpoint daftar prestasi mahasiswa.
  static const String prestasiEndpoint = '/prestasi';
}