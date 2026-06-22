import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class OrderApiService {
  Future<Response> getOrders() async => await apiClient.dio.get('/orders');
  
  Future<Response> createOrder(Map<String, dynamic> data) async => 
      await apiClient.dio.post('/orders', data: data);

  Future<Response> uploadBuktiPembayaran(int orderId, File imageFile) async {
    FormData formData = FormData.fromMap({
      "bukti_pembayaran": await MultipartFile.fromFile(imageFile.path, filename: "bukti_$orderId.jpg"),
    });

    return await apiClient.dio.post(
      '/orders/$orderId/upload-bukti',
      data: formData,
    );
  }

  Future<Response> updateOrderStatus(int orderId, String status) async {
    return await apiClient.dio.patch(
      '/orders/$orderId/status',
      data: {'status': status},
    );
  }
}
