import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UserApiService {
  Future<Response> getUserProfile() async => await apiClient.dio.get('/user-profile');

  Future<Response> updateProfile(Map<String, dynamic> data, {XFile? imageFile}) async {
    FormData formData = FormData.fromMap(data);

    if (imageFile != null) {
      String fileName = imageFile.name.isNotEmpty && imageFile.name.contains('.') 
          ? imageFile.name 
          : 'profile.jpg';
      formData.files.add(MapEntry(
        "image",
        MultipartFile.fromBytes(await imageFile.readAsBytes(), filename: fileName),
      ));
    }

    return await apiClient.dio.post(
      '/user-profile/update',
      data: formData,
    );
  }
}
