import 'package:dio/dio.dart';
import 'package:sikarema_mobile/app/constants/api_constants.dart';
import 'package:sikarema_mobile/core/network/dio_client.dart';

/// User model matching the Laravel API user payload.
class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  final int id;
  final String name;
  final String email;
  final String role;
}

/// Payload wrapper for login data returned by Laravel.
class LoginData {
  LoginData({required this.token, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String token;
  final UserModel user;
}

/// Login response model matching the Laravel API structure.
class LoginResponse {
  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  final bool success;
  final String message;
  final LoginData data;
}

/// Service responsible only for calling the authentication endpoint.
class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// Sends login request to the Laravel Sanctum endpoint.
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.loginEndpoint,
      data: {'email': email, 'password': password},
    );

    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
