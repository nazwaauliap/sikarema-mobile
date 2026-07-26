/// =====================================================================
/// STUDENT PROFILE (GET /profile)
/// =====================================================================
/// Field DIKONFIRMASI dari response asli backend:
/// {
///   "success": true, "message": "...",
///   "data": {
///     "id": 5, "name": "...", "email": "...", "role": "Mahasiswa",
///     "mahasiswa": {
///       "nim": "...", "nama": "...", "program_studi": "...",
///       "fakultas": "...", "angkatan": "...", "semester": 4,
///       "kelas": "...", "status": "Aktif"
///     },
///     "dosen": null
///   }
/// }
///
/// CATATAN: tidak ada field nomor HP sama sekali di response ini,
/// jadi TIDAK ditampung di model (lihat AkunScreen — baris "Nomor HP"
/// dihapus dari UI, bukan ditebak/dikosongkan).
///
/// `mahasiswa` bisa null (mis. untuk akun dengan role lain seperti
/// "dosen"), jadi seluruh field turunan dari situ punya fallback ''.
/// `semester` dikirim sebagai number (4), diparse via toString() jadi
/// aman untuk int maupun string.
/// =====================================================================
class StudentProfileModel {
  StudentProfileModel({
    required this.nama,
    required this.email,
    required this.nim,
    required this.programStudi,
    required this.fakultas,
    required this.semester,
    required this.kelas,
    required this.statusMahasiswa,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['mahasiswa'] as Map<String, dynamic>?;

    return StudentProfileModel(
      nama: mahasiswa?['nama']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nim: mahasiswa?['nim']?.toString() ?? '',
      programStudi: mahasiswa?['program_studi']?.toString() ?? '',
      fakultas: mahasiswa?['fakultas']?.toString() ?? '',
      semester: mahasiswa?['semester']?.toString() ?? '',
      kelas: mahasiswa?['kelas']?.toString() ?? '',
      statusMahasiswa: mahasiswa?['status']?.toString() ?? '',
    );
  }

  final String nama;
  final String email;
  final String nim;
  final String programStudi;
  final String fakultas;
  final String semester;
  final String kelas;
  final String statusMahasiswa;
}

/// Response wrapper untuk endpoint GET /profile.
class ProfileResponse {
  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: StudentProfileModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  final bool success;
  final String message;
  final StudentProfileModel data;
}