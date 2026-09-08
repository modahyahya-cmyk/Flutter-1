import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

/// Thin HTTP wrapper over Dio. The [Dio] instance passed in is expected to
/// already be configured (baseUrl + interceptors) by the DI container, so
/// this class does not touch `dio.options` or `dio.interceptors` itself.
class ApiClient {
  ApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Failed to read data from the server");
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Failed to send the submitted data");
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Failed to update the data");
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Failed to update the data");
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Failed to delete the data");
    }
  }
}
