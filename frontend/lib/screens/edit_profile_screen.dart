import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_api_service.dart';
import 'dart:io' as io;

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserApiService _apiService = UserApiService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.nama ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.noHp ?? '');
  }

  Future<void> _pickImage() async {
    // Menambahkan imageQuality agar ukuran file tidak lebih dari 5MB (Batas Backend)
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres ukuran file menjadi 50%
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return NetworkImage(_selectedImage!.path);
      } else {
        return FileImage(io.File(_selectedImage!.path));
      }
    } else if (widget.user.profilePhoto != null && widget.user.profilePhoto!.isNotEmpty) {
      String imageUrl = widget.user.profilePhoto!;
      // Modifikasi URL agar menggunakan bypass path (sama seperti di AkunScreen)
      if (imageUrl.contains('/storage/')) {
        imageUrl = imageUrl.replaceFirst('/storage/', '/api/image/');
      }
      
      // Tambahkan cache buster
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String finalUrl = imageUrl.contains('?') ? '$imageUrl&t=$timestamp' : '$imageUrl?t=$timestamp';
      
      return NetworkImage(finalUrl);
    }
    return null;
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'no_hp': _phoneController.text,
    };

    if (_newPasswordController.text.isNotEmpty && _currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap masukkan Kata Sandi Saat Ini untuk mengubah sandi', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    if (_newPasswordController.text.isNotEmpty) {
      data['current_password'] = _currentPasswordController.text;
      data['password'] = _newPasswordController.text;
    }

    try {
      final response = await _apiService.updateProfile(data, imageFile: _selectedImage);
      
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!')));
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      debugPrint("Error Update Dio: ${e.response?.data}");
      String errorMessage = 'Gagal memperbarui profil.';
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data['message'] != null) {
           errorMessage = e.response?.data['message'];
        }
        if (e.response?.data['errors'] != null) {
           final errors = e.response?.data['errors'] as Map<String, dynamic>;
           errorMessage = errors.values.first[0].toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      debugPrint("Error Update: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD80309), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _getProfileImage(),
                      child: _selectedImage == null && (widget.user.profilePhoto == null || widget.user.profilePhoto!.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFD80309), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController, 
                decoration: _buildInputDecoration("Nama Lengkap", Icons.person_outline),
                validator: (value) => value == null || value.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController, 
                decoration: _buildInputDecoration("Email", Icons.email_outlined),
                validator: (value) => value == null || value.trim().isEmpty || !value.contains('@') ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController, 
                decoration: _buildInputDecoration("Nomor HP", Icons.phone_outlined),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController, 
                obscureText: _obscurePassword, 
                enableSuggestions: false,
                autocorrect: false,
                autofillHints: const <String>[], // Mencegah browser mengisi otomatis (autofill)
                decoration: _buildInputDecoration("Kata Sandi Saat Ini", Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController, 
                obscureText: _obscureConfirmPassword, 
                enableSuggestions: false,
                autocorrect: false,
                autofillHints: const <String>[], // Mencegah browser mengisi otomatis (autofill)
                decoration: _buildInputDecoration("Kata Sandi Baru (Opsional)", Icons.lock_reset_outlined).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD80309),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _simpanPerubahan,
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}