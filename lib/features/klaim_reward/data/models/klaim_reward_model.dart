/// =====================================================================
/// SUBMIT KLAIM REWARD (POST /klaim-reward)
/// =====================================================================
/// Catatan:
/// - Request HANYA mengirim { "id_prestasi": idPrestasi } (lihat Postman
///   Collection). Backend menentukan periode & reward secara otomatis,
///   jadi tidak ada field lain yang perlu dikirim/ditampilkan di sini.
/// - Response sukses maupun gagal (mis. "Prestasi tidak ditemukan.")
///   sama-sama punya struktur { success, message }, jadi cukup 1 model
///   response generik — mengikuti pola response wrapper lain di project
///   (PrestasiResponse, CreatePrestasiResponse), TANPA field `data`
///   karena Postman Collection tidak menunjukkan field tersebut pada
///   response sukses POST /klaim-reward.
/// =====================================================================
class SubmitKlaimRewardResponse {
  SubmitKlaimRewardResponse({required this.success, required this.message});

  factory SubmitKlaimRewardResponse.fromJson(Map<String, dynamic> json) {
    return SubmitKlaimRewardResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
    );
  }

  final bool success;
  final String message;
}