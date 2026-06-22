import 'package:dio/dio.dart';
import 'api_client.dart';

class ShippingApiService {
  Future<Response> getShippingRates() async {
    try {
      return await apiClient.dio.get('/shipping-rates');
    } catch (e) {
      rethrow;
    }
  }
}
