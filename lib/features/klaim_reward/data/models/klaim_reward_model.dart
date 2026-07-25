/// =====================================================================
/// JENIS REWARD (GET /jenis-reward)
/// =====================================================================
/// Data master untuk dropdown "Jenis Reward" pada Konfirmasi Klaim.
/// Field mengikuti persis response Postman Collection (nominal dikirim
/// backend sebagai string, mis. "500000.00", jadi disimpan sebagai
/// String apa adanya — parsing ke angka dilakukan di UI saat
/// dibutuhkan untuk format tampilan, bukan di model).
class JenisRewardModel {
  JenisRewardModel({
    required this.idReward,
    required this.namaReward,
    required this.nominal,
    required this.keterangan,
    required this.tingkat,
  });

  factory JenisRewardModel.fromJson(Map<String, dynamic> json) {
    return JenisRewardModel(
      idReward: (json['id_reward'] as num?)?.toInt() ?? 0,
      namaReward: json['nama_reward']?.toString() ?? '',
      nominal: json['nominal']?.toString() ?? '0',
      keterangan: json['keterangan']?.toString() ?? '',
      tingkat: json['tingkat']?.toString() ?? '',
    );
  }

  final int idReward;
  final String namaReward;
  final String nominal;
  final String keterangan;
  final String tingkat;

  /// Format nominal ("500000.00") menjadi "Rp500.000" untuk tampilan.
  String get nominalFormatted {
    final value = double.tryParse(nominal) ?? 0;
    final intValue = value.round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }
}

/// Response wrapper untuk endpoint GET /jenis-reward.
class JenisRewardResponse {
  JenisRewardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory JenisRewardResponse.fromJson(Map<String, dynamic> json) {
    return JenisRewardResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => JenisRewardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final bool success;
  final String message;
  final List<JenisRewardModel> data;
}

/// =====================================================================
/// SUBMIT KLAIM REWARD (POST /klaim-reward)
/// =====================================================================
/// Catatan:
/// - Request mengirim { "id_prestasi", "id_periode", "id_reward" }
///   sesuai kontrak API sungguhan (dikonfirmasi lewat Postman + hasil
///   cek database oleh pemilik project — endpoint semula terlihat
///   hanya butuh id_prestasi, ternyata backend juga mewajibkan
///   id_periode & id_reward).
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