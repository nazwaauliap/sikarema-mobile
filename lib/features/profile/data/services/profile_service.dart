import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';
import 'package:sikarema_mobile/core/network/dio_client.dart';
import 'package:sikarema_mobile/core/storage/storage_service.dart';
import 'package:sikarema_mobile/features/profile/data/models/profile_model.dart';

/// Service responsible only for calling the student profile endpoint.
class ProfileService {
  ProfileService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// Mengambil data profil mahasiswa yang sedang login (GET /profile),
  /// dipakai oleh AkunScreen.
  Future<ProfileResponse> getProfile() async {
    final token = await StorageService().getToken();

    final response = await _dio.get(
      ApiConstants.profileEndpoint,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }
}