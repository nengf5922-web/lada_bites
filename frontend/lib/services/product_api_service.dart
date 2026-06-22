import 'package:dio/dio.dart';
import 'api_client.dart';

class ProductApiService {
  Future<Response> getProducts() async => await apiClient.dio.get('/products');
  Future<Response> getCategories() async => await apiClient.dio.get('/categories');
  Future<Response> getBanners() async => await apiClient.dio.get('/banners');
}
