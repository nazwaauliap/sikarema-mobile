import 'dart:io';

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

  /// Mengajukan prestasi baru ke Laravel API.
  /// Menggunakan multipart/form-data karena menyertakan upload file
  /// sertifikat. Nama field WAJIB persis sesuai spesifikasi API:
  /// id_kategori, id_tingkat, nama_kegiatan, penyelenggara,
  /// tanggal_kegiatan (YYYY-MM-DD), juara, file_sertifikat.
  Future<CreatePrestasiResponse> createPrestasi({
    required int idKategori,
    required int idTingkat,
    required String namaKegiatan,
    required String penyelenggara,
    required String tanggalKegiatan,
    required String juara,
    required File fileSertifikat,
  }) async {
    final token = await StorageService().getToken();

    final formData = FormData.fromMap({
      'id_kategori': idKategori.toString(),
      'id_tingkat': idTingkat.toString(),
      'nama_kegiatan': namaKegiatan,
      'penyelenggara': penyelenggara,
      'tanggal_kegiatan': tanggalKegiatan,
      'juara': juara,
      'file_sertifikat': await MultipartFile.fromFile(
        fileSertifikat.path,
        filename: fileSertifikat.path.split('/').last,
      ),
    });

    final response = await _dio.post(
      ApiConstants.prestasiEndpoint,
      data: formData,
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        // Dio otomatis mengganti Content-Type menjadi
        // 'multipart/form-data; boundary=...' saat data berupa FormData,
        // menimpa header default 'application/json' dari DioClient.
      ),
    );

    return CreatePrestasiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}