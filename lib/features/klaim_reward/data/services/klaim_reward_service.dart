import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';
import 'package:sikarema_mobile/core/network/dio_client.dart';
import 'package:sikarema_mobile/core/storage/storage_service.dart';
import 'package:sikarema_mobile/features/klaim_reward/data/models/klaim_reward_model.dart';

/// Service responsible only for calling the klaim-reward endpoints.
class KlaimRewardService {
  KlaimRewardService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// Mengajukan klaim reward untuk satu prestasi ke Laravel API.
  /// Body request HANYA { "id_prestasi": idPrestasi } — tidak ada field
  /// lain (tidak ada upload, rekening, periode, atau reward), karena
  /// backend menentukan semuanya secara otomatis.
  Future<SubmitKlaimRewardResponse> submitKlaimReward({
    required int idPrestasi,
  }) async {
    final token = await StorageService().getToken();

    final response = await _dio.post(
      ApiConstants.klaimRewardEndpoint,
      data: {'id_prestasi': idPrestasi},
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