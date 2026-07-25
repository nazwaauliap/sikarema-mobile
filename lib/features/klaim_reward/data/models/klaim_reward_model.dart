import 'package:sikarema_mobile/core/helpers/format_helper.dart';

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
  String get nominalFormatted => FormatHelper.rupiah(nominal);
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

/// =====================================================================
/// RIWAYAT KLAIM (GET /klaim-reward)
/// =====================================================================
/// Field mengikuti persis response Postman Collection:
/// { id_klaim, prestasi, reward, periode, tanggal_pengajuan,
///   status_klaim, catatan }.
///
/// CATATAN soal nominal reward: response GET /klaim-reward TIDAK
/// menyertakan nominal (hanya nama reward berupa String, mis.
/// "Reward Tingkat Nasional"). Nominal untuk tampilan "Rp750.000"
/// SENGAJA tidak ditaruh di model ini (tidak "mengarang" field) —
/// RiwayatKlaimScreen mencocokkan `reward` di sini dengan `namaReward`
/// dari GET /jenis-reward (endpoint sungguhan yang sudah ada) untuk
/// mendapatkan nominal aslinya. Jika nama reward tidak cocok dengan
/// data master, nominal cukup tidak ditampilkan (bukan ditebak).
class RiwayatKlaimModel {
  RiwayatKlaimModel({
    required this.idKlaim,
    required this.prestasi,
    required this.reward,
    required this.periode,
    required this.tanggalPengajuan,
    required this.statusKlaim,
    required this.catatan,
  });

  factory RiwayatKlaimModel.fromJson(Map<String, dynamic> json) {
    return RiwayatKlaimModel(
      idKlaim: (json['id_klaim'] as num?)?.toInt() ?? 0,
      prestasi: json['prestasi']?.toString() ?? '',
      reward: json['reward']?.toString() ?? '',
      periode: json['periode']?.toString() ?? '',
      tanggalPengajuan: json['tanggal_pengajuan']?.toString() ?? '',
      statusKlaim: json['status_klaim']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
    );
  }

  final int idKlaim;
  final String prestasi;
  final String reward;
  final String periode;
  final String tanggalPengajuan;
  final String statusKlaim;
  final String catatan;
}

/// Response wrapper untuk endpoint GET /klaim-reward.
class RiwayatKlaimResponse {
  RiwayatKlaimResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RiwayatKlaimResponse.fromJson(Map<String, dynamic> json) {
    return RiwayatKlaimResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => RiwayatKlaimModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final bool success;
  final String message;
  final List<RiwayatKlaimModel> data;
}