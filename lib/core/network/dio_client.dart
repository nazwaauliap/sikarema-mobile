import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';

/// Singleton HTTP client used across the app for API communication.
class DioClient {
  DioClient._();

  static final DioClient _instance = DioClient._();

  factory DioClient() => _instance;

  /// Shared Dio instance with default configuration.
  late final Dio _dio = Dio(
    BaseOptions(
      // Base URL utama API yang diambil dari ApiConstants.
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Getter untuk memudahkan pemakaian di service lain.
  Dio get dio => _dio;
}
