/// Data ringkasan dashboard mahasiswa, sesuai payload `data` pada
/// response GET /api/v1/dashboard.
class DashboardModel {
  DashboardModel({
    required this.nama,
    required this.totalPrestasi,
    required this.menunggu,
    required this.terverifikasi,
    required this.ditolak,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      nama: json['nama']?.toString() ?? '',
      totalPrestasi: (json['total_prestasi'] as num?)?.toInt() ?? 0,
      menunggu: (json['menunggu'] as num?)?.toInt() ?? 0,
      terverifikasi: (json['terverifikasi'] as num?)?.toInt() ?? 0,
      ditolak: (json['ditolak'] as num?)?.toInt() ?? 0,
    );
  }

  final String nama;
  final int totalPrestasi;
  final int menunggu;
  final int terverifikasi;
  final int ditolak;
}

/// Response wrapper untuk endpoint GET /api/v1/dashboard,
/// mengikuti pola LoginResponse pada AuthService.
class DashboardResponse {
  DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: DashboardModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  final bool success;
  final String message;
  final DashboardModel data;
}