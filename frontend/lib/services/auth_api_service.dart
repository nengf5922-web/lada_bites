import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApiService {
  Future<Response> login(String email, String password) async =>
      await apiClient.dio.post('/login', data: {'email': email, 'password': password});

  Future<Response> register(String name, String email, String password) async =>
      await apiClient.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

  Future<Response> logout() async => await apiClient.dio.post('/logout');

  Future<void> simpanToken(String token) async => await apiClient.storage.write(key: 'auth_token', value: token);
  Future<void> hapusToken() async => await apiClient.storage.delete(key: 'auth_token');
}
