import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';
import 'package:sikarema_mobile/core/network/dio_client.dart';
import 'package:sikarema_mobile/core/storage/storage_service.dart';
import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';

/// Service responsible only for calling the prestasi endpoints.
class PrestasiService {
  PrestasiService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// Mengambil daftar prestasi mahasiswa dari Laravel API.
  Future<PrestasiResponse> getPrestasi() async {
    final token = await StorageService().getToken();

    final response = await _dio.get(
      ApiConstants.prestasiEndpoint,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return PrestasiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mengambil detail satu prestasi berdasarkan id dari Laravel API.
  Future<DetailPrestasiResponse> getPrestasiById(int id) async {
    final token = await StorageService().getToken();

    final response = await _dio.get(
      '${ApiConstants.prestasiEndpoint}/$id',
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return DetailPrestasiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}