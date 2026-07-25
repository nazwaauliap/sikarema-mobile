import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';
import 'package:sikarema_mobile/core/network/dio_client.dart';
import 'package:sikarema_mobile/core/storage/storage_service.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/models/klaim_reward_model.dart';

/// Service responsible only for calling the klaim-reward endpoints.
class KlaimRewardService {
  KlaimRewardService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// Mengambil daftar jenis reward (Master Data) dari Laravel API,
  /// dipakai untuk dropdown "Jenis Reward" pada Konfirmasi Klaim.
  Future<JenisRewardResponse> getJenisRewardList() async {
    final token = await StorageService().getToken();

    final response = await _dio.get(
      ApiConstants.jenisRewardEndpoint,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return JenisRewardResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Mengajukan klaim reward untuk satu prestasi ke Laravel API.
  /// Body request { "id_prestasi", "id_periode", "id_reward" } sesuai
  /// kontrak API sungguhan (dikonfirmasi lewat Postman + pengecekan
  /// database oleh pemilik project).
  Future<SubmitKlaimRewardResponse> submitKlaimReward({
    required int idPrestasi,
    required int idPeriode,
    required int idReward,
  }) async {
    final token = await StorageService().getToken();

    final response = await _dio.post(
      ApiConstants.klaimRewardEndpoint,
      data: {
        'id_prestasi': idPrestasi,
        'id_periode': idPeriode,
        'id_reward': idReward,
      },
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return SubmitKlaimRewardResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}