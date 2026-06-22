import 'package:dio/dio.dart';
import 'api_client.dart';

class ReviewApiService {
  final ApiClient apiClient = ApiClient();

  // Mengambil daftar produk yang bisa diulas oleh user (Status pesanan 'Selesai')
  Future<Response> getReviewableProducts() async {
    return await apiClient.dio.get('/user/reviewable-products');
  }

  // Menyimpan atau mengupdate ulasan
  Future<Response> submitReview(int productId, int rating, String comment) async {
    return await apiClient.dio.post('/reviews', data: {
      'product_id': productId,
      'rating': rating,
      'comment': comment,
    });
  }

  // Mengambil daftar ulasan untuk suatu produk tertentu
  Future<Response> getProductReviews(int productId) async {
    return await apiClient.dio.get('/products/$productId/reviews');
  }
}
