import 'package:flutter/material.dart';
import '../services/user_api_service.dart';
class AlamatPengirimanScreen extends StatefulWidget {
  const AlamatPengirimanScreen({super.key});

  @override
  State<AlamatPengirimanScreen> createState() => _AlamatPengirimanScreenState();
}

class _AlamatPengirimanScreenState extends State<AlamatPengirimanScreen> {
  final UserApiService _userApiService = UserApiService();
  List<Map<String, dynamic>> _daftarAlamat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlamatDariProfil();
  }

  Future<void> _fetchAlamatDariProfil() async {
    try {
      final response = await _userApiService.getUserProfile();
      if (mounted) {
        setState(() {
          final data = response.data['data'] ?? response.data;
          
          // Membuat satu alamat utama dari data profil
          _daftarAlamat = [
            {
              "label": "Utama",
              "icon": Icons.home,
              "isUtama": true,
              "nama": data['name'] ?? 'Penerima',
              "noHp": data['phone'] ?? '-',
              "alamat": data['address'] ?? 'Alamat belum diatur',
            }
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // === FUNGSI MUNCULKAN FORM UBAH ALAMAT ===
  void _tampilkanFormUbahAlamat(int index) {
    final alamatTerpilih = _daftarAlamat[index];

    final labelController = TextEditingController(text: alamatTerpilih['label']);
    final namaController = TextEditingController(text: alamatTerpilih['nama']);
    final noHpController = TextEditingController(text: alamatTerpilih['noHp']);
    final alamatController = TextEditingController(text: alamatTerpilih['alamat']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24, right: 24, top: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                Text('Ubah Alamat ${alamatTerpilih['label']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                const SizedBox(height: 24),

                const Text('Label Alamat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: labelController, decoration: _buildInputDecoration('Contoh: Rumah, Kantor, Kosan')),
                const SizedBox(height: 16),

                const Text('Nama Penerima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: namaController, decoration: _buildInputDecoration('Contoh: Budi Santoso')),
                const SizedBox(height: 16),

                const Text('Nomor Handphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: noHpController, keyboardType: TextInputType.phone, decoration: _buildInputDecoration('Contoh: 081234567890')),
                const SizedBox(height: 16),

                const Text('Alamat Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: alamatController, maxLines: 3, decoration: _buildInputDecoration('Jalan, RT/RW, Kecamatan, Kota...')),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD80309),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (namaController.text.isEmpty || noHpController.text.isEmpty || alamatController.text.isEmpty || labelController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom alamat ya!'), backgroundColor: Colors.red));
                        return;
                      }

                      setState(() {
                        _daftarAlamat[index]['label'] = labelController.text;
                        _daftarAlamat[index]['nama'] = namaController.text;
                        _daftarAlamat[index]['noHp'] = noHpController.text;
                        _daftarAlamat[index]['alamat'] = alamatController.text;
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat berhasil diperbarui! 📍'), backgroundColor: Colors.green));
                    },
                    child: const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // === FUNGSI MUNCULKAN FORM TAMBAH ALAMAT BARU (FITUR BARU) ===
  void _tampilkanFormTambahAlamat() {
    // Siapkan controller KOSONG
    final labelController = TextEditingController();
    final namaController = TextEditingController();
    final noHpController = TextEditingController();
    final alamatController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24, right: 24, top: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                const Text('Tambah Alamat Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                const SizedBox(height: 24),

                const Text('Label Alamat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: labelController, decoration: _buildInputDecoration('Contoh: Rumah, Kantor, Kosan')),
                const SizedBox(height: 16),

                const Text('Nama Penerima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: namaController, decoration: _buildInputDecoration('Contoh: Budi Santoso')),
                const SizedBox(height: 16),

                const Text('Nomor Handphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: noHpController, keyboardType: TextInputType.phone, decoration: _buildInputDecoration('Contoh: 081234567890')),
                const SizedBox(height: 16),

                const Text('Alamat Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: alamatController, maxLines: 3, decoration: _buildInputDecoration('Jalan, RT/RW, Kecamatan, Kota...')),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD80309),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (namaController.text.isEmpty || noHpController.text.isEmpty || alamatController.text.isEmpty || labelController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom alamat ya!'), backgroundColor: Colors.red));
                        return;
                      }

                      // === MENAMBAHKAN DATA BARU KE DALAM DAFTAR ALAMAT ===
                      setState(() {
                        _daftarAlamat.add({
                          "label": labelController.text,
                          "icon": Icons.location_on, // Ikon default untuk alamat baru
                          "isUtama": false, // Default bukan alamat utama
                          "nama": namaController.text,
                          "noHp": noHpController.text,
                          "alamat": alamatController.text,
                        });
                      });

                      Navigator.pop(context); // Tutup panel
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat baru berhasil ditambahkan! 🎉'), backgroundColor: Colors.green));
                    },
                    child: const Text('SIMPAN ALAMAT BARU', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD80309))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD80309),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alamat Pengiriman',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _daftarAlamat.length,
        itemBuilder: (context, index) {
          final alamat = _daftarAlamat[index];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: alamat['isUtama'] ? Border.all(color: const Color(0xFFD80309), width: 1.5) : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(alamat['icon'], size: 20, color: const Color(0xFF111111)),
                        const SizedBox(width: 8),
                        Text(alamat['label'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ],
                    ),
                    if (alamat['isUtama'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          border: Border.all(color: const Color(0xFFD80309)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Utama', style: TextStyle(color: Color(0xFFD80309), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const Divider(height: 24, color: Colors.black12),
                Text(alamat['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111111))),
                const SizedBox(height: 4),
                Text(alamat['noHp'], style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 12),
                Text(alamat['alamat'], style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _tampilkanFormUbahAlamat(index), 
                    child: const Text('Ubah Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      
      // === TOMBOL TAMBAH ALAMAT BARU SUDAH BISA DIKLIK ===
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD80309),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('TAMBAH ALAMAT BARU', style: TextStyle(fontWeight: FontWeight.w900)),
              onPressed: _tampilkanFormTambahAlamat, // <--- Memanggil form kosong
            ),
          ),
        ),
      ),
    );
  }
}