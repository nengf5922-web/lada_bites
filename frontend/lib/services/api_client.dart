import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String baseUrl = kIsWeb
      ? 'http://localhost:8000/api'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000/api'
          : 'http://localhost:8000/api');

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  FlutterSecureStorage get storage => _storage;
}

// Singleton instance
final apiClient = ApiClient();
