import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

class OrderApiService {
  Future<Response> getOrders() async => await apiClient.dio.get('/orders');
  
  Future<Response> createOrder(Map<String, dynamic> data) async => 
      await apiClient.dio.post('/orders', data: data);

  Future<Response> uploadBuktiPembayaran(int orderId, XFile imageFile) async {
    MultipartFile file;
    if (kIsWeb) {
      file = MultipartFile.fromBytes(await imageFile.readAsBytes(), filename: imageFile.name.isEmpty ? "bukti_$orderId.jpg" : imageFile.name);
    } else {
      file = await MultipartFile.fromFile(imageFile.path, filename: imageFile.name.isEmpty ? "bukti_$orderId.jpg" : imageFile.name);
    }

    FormData formData = FormData.fromMap({
      "bukti_pembayaran": file,
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
