import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';
import 'package:sikarema_mobile/core/network/dio_client.dart';
import 'package:sikarema_mobile/core/storage/storage_service.dart';
import 'package:sikarema_mobile/features/dashboard/data/models/dashboard_model.dart';

/// Service responsible only for calling the dashboard endpoint.
class DashboardService {
  DashboardService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// Mengambil ringkasan dashboard mahasiswa dari Laravel API.
  /// Menyertakan Bearer Token yang sudah tersimpan sejak proses login,
  /// tanpa perlu mengubah DioClient (dikirim per-request lewat Options).
  Future<DashboardResponse> getDashboard() async {
    final token = await StorageService().getToken();

    final response = await _dio.get(
      ApiConstants.dashboardEndpoint,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          // Melewati halaman peringatan browser bawaan ngrok free-tier,
          // yang tidak menyertakan header CORS sehingga terlihat seperti
          // error CORS di browser padahal Laravel-nya sudah benar.
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return DashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }
}