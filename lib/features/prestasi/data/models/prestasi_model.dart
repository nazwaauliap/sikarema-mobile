/// Data satu item prestasi, sesuai payload item pada
/// response GET /api/v1/prestasi.
class PrestasiModel {
  PrestasiModel({
    required this.id,
    required this.namaKegiatan,
    required this.kategori,
    required this.tingkat,
    required this.penyelenggara,
    required this.tanggal,
    required this.juara,
    required this.status,
    required this.sertifikat,
  });

  factory PrestasiModel.fromJson(Map<String, dynamic> json) {
    return PrestasiModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      namaKegiatan: json['nama_kegiatan']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      tingkat: json['tingkat']?.toString() ?? '',
      penyelenggara: json['penyelenggara']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      juara: json['juara']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      sertifikat: json['sertifikat']?.toString(),
    );
  }

  final int id;
  final String namaKegiatan;
  final String kategori;
  final String tingkat;
  final String penyelenggara;
  final String tanggal;
  final String juara;
  final String status;
  final String? sertifikat;

  /// Mengambil tahun saja dari format "2026-04-15" untuk ditampilkan
  /// pada kartu (sesuai mockup: hanya menampilkan tahun di kartu list).
  String get tahun {
    if (tanggal.length < 4) return '-';
    return tanggal.substring(0, 4);
  }
}

/// Response wrapper untuk endpoint GET /api/v1/prestasi,
/// mengikuti pola DashboardResponse pada DashboardService.
class PrestasiResponse {
  PrestasiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PrestasiResponse.fromJson(Map<String, dynamic> json) {
    return PrestasiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => PrestasiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final bool success;
  final String message;
  final List<PrestasiModel> data;

}

/// =====================================================================
/// DETAIL PRESTASI
/// =====================================================================
/// Model terpisah dari PrestasiModel karena struktur field response
/// GET /api/v1/prestasi/{id} berbeda dari GET /api/v1/prestasi
/// (mis. `id_prestasi` bukan `id`, `tanggal_kegiatan` bukan `tanggal`,
/// `status_verifikasi` bukan `status`).
class DetailPrestasiModel {
  DetailPrestasiModel({
    required this.idPrestasi,
    required this.mahasiswa,
    required this.nim,
    required this.namaKegiatan,
    required this.kategori,
    required this.tingkat,
    required this.penyelenggara,
    required this.tanggalKegiatan,
    required this.juara,
    required this.statusVerifikasi,
    required this.fileSertifikat,
  });

  factory DetailPrestasiModel.fromJson(Map<String, dynamic> json) {
    return DetailPrestasiModel(
      idPrestasi: (json['id_prestasi'] as num?)?.toInt() ?? 0,
      mahasiswa: json['mahasiswa']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      namaKegiatan: json['nama_kegiatan']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      tingkat: json['tingkat']?.toString() ?? '',
      penyelenggara: json['penyelenggara']?.toString() ?? '',
      tanggalKegiatan: json['tanggal_kegiatan']?.toString() ?? '',
      juara: json['juara']?.toString() ?? '',
      statusVerifikasi: json['status_verifikasi']?.toString() ?? '',
      fileSertifikat: json['file_sertifikat']?.toString(),
    );
  }

  final int idPrestasi;
  final String mahasiswa;
  final String nim;
  final String namaKegiatan;
  final String kategori;
  final String tingkat;
  final String penyelenggara;
  final String tanggalKegiatan;
  final String juara;
  final String statusVerifikasi;
  final String? fileSertifikat;

  /// Mengambil tahun saja dari format "2026-04-15".
  String get tahun {
    if (tanggalKegiatan.length < 4) return '-';
    return tanggalKegiatan.substring(0, 4);
  }

  /// Format tanggal "2026-04-15" menjadi "15 April 2026" untuk tampilan.
  String get tanggalFormatted {
    const bulanIndonesia = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final parts = tanggalKegiatan.split('-');
    if (parts.length != 3) return tanggalKegiatan;
    final day = int.tryParse(parts[2]);
    final month = int.tryParse(parts[1]);
    final year = parts[0];
    if (day == null || month == null || month < 1 || month > 12) {
      return tanggalKegiatan;
    }
    return '$day ${bulanIndonesia[month]} $year';
  }

  /// Nama file diambil dari path URL file_sertifikat, jika ada.
  String? get fileSertifikatName {
    if (fileSertifikat == null || fileSertifikat!.isEmpty) return null;
    return fileSertifikat!.split('/').last;
  }
}

/// Response wrapper untuk endpoint GET /api/v1/prestasi/{id}.
class DetailPrestasiResponse {
  DetailPrestasiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DetailPrestasiResponse.fromJson(Map<String, dynamic> json) {
    return DetailPrestasiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: DetailPrestasiModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }

  final bool success;
  final String message;
  final DetailPrestasiModel data;
}

/// =====================================================================
/// MASTER OPTION (untuk dropdown Kategori & Tingkat)
/// =====================================================================
/// Model generik dipakai untuk kedua dropdown karena strukturnya sama
/// (id + label), baik untuk data statis placeholder maupun nanti API.
class MasterOption {
  const MasterOption({required this.id, required this.label});

  final int id;
  final String label;
}

/// =====================================================================
/// CREATE PRESTASI (POST /api/v1/prestasi)
/// =====================================================================
class CreatePrestasiModel {
  CreatePrestasiModel({
    required this.idPrestasi,
    required this.namaKegiatan,
    required this.statusVerifikasi,
  });

  factory CreatePrestasiModel.fromJson(Map<String, dynamic> json) {
    return CreatePrestasiModel(
      idPrestasi: (json['id_prestasi'] as num?)?.toInt() ?? 0,
      namaKegiatan: json['nama_kegiatan']?.toString() ?? '',
      statusVerifikasi: json['status_verifikasi']?.toString() ?? '',
    );
  }

  final int idPrestasi;
  final String namaKegiatan;
  final String statusVerifikasi;
}

/// Response wrapper untuk endpoint POST /api/v1/prestasi.
class CreatePrestasiResponse {
  CreatePrestasiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatePrestasiResponse.fromJson(Map<String, dynamic> json) {
    return CreatePrestasiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: CreatePrestasiModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }

  final bool success;
  final String message;
  final CreatePrestasiModel data;
}