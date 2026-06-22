import 'package:flutter/material.dart';
import '../services/review_api_service.dart';

class UlasanScreen extends StatefulWidget {
  const UlasanScreen({super.key});

  @override
  State<UlasanScreen> createState() => _UlasanScreenState();
}

class _UlasanScreenState extends State<UlasanScreen> {
  final ReviewApiService _apiService = ReviewApiService();
  List<Map<String, dynamic>> _riwayatUlasan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviewableProducts();
  }

  Future<void> _fetchReviewableProducts() async {
    try {
      final response = await _apiService.getReviewableProducts();
      if (mounted) {
        setState(() {
          _riwayatUlasan = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat daftar ulasan.'), backgroundColor: Colors.red)
        );
      }
    }
  }

  // === FUNGSI MENAMPILKAN FORMULIR ULASAN (BOTTOM SHEET) ===
  void _tampilkanFormUlasan(BuildContext context, int index) {
    int _ratingDipilih = _riwayatUlasan[index]['rating'] ?? 0;
    final TextEditingController _ulasanController = TextEditingController(text: _riwayatUlasan[index]['comment'] ?? '');
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
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
                        child: Container(
                          width: 40, height: 5,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Nilai Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                      const SizedBox(height: 4),
                      Text(_riwayatUlasan[index]['nama'], style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 24),

                      // BINTANG RATING
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (starIndex) {
                            return IconButton(
                              icon: Icon(
                                starIndex < _ratingDipilih ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 40,
                              ),
                              onPressed: () {
                                setStateSheet(() {
                                  _ratingDipilih = starIndex + 1;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Bagaimana kualitas camilan ini?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ulasanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Ceritakan rasa, tekstur, atau kemasannya...',
                          hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD80309))),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TOMBOL KIRIM
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD80309),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isSubmitting ? null : () async {
                            if (_ratingDipilih == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih bintang dulu ya Kak! ⭐'), backgroundColor: Colors.orange));
                              return;
                            }
                            
                            setStateSheet(() => _isSubmitting = true);

                            try {
                              await _apiService.submitReview(
                                _riwayatUlasan[index]['product_id'], 
                                _ratingDipilih, 
                                _ulasanController.text
                              );

                              if (mounted) {
                                setState(() {
                                  _riwayatUlasan[index]['status'] = 'Sudah Diulas';
                                  _riwayatUlasan[index]['rating'] = _ratingDipilih;
                                  _riwayatUlasan[index]['comment'] = _ulasanController.text;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih! Ulasan Kakak berhasil dikirim.'), backgroundColor: Colors.green));
                              }
                            } catch (e) {
                              setStateSheet(() => _isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim ulasan.'), backgroundColor: Colors.red));
                            }
                          },
                          child: _isSubmitting 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('KIRIM ULASAN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD80309), Color(0xFFF73E3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ulasan Saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))
          : _riwayatUlasan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('Belum ada produk yang bisa diulas.', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _riwayatUlasan.length,
                  itemBuilder: (context, index) {
                    final item = _riwayatUlasan[index];
                    final bool isReviewed = item['status'] == "Sudah Diulas";
                    final int ratingData = item['rating'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.image_outlined, color: Colors.black26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF111111))),
                                const SizedBox(height: 4),
                                Text('Dibeli tgl: ${item['tanggal']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 8),
                                
                                isReviewed 
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: List.generate(5, (starIdx) => Icon(
                                            starIdx < ratingData ? Icons.star : Icons.star_border, 
                                            color: Colors.amber, 
                                            size: 16
                                          )),
                                        ),
                                        InkWell(
                                          onTap: () => _tampilkanFormUlasan(context, index),
                                          child: const Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    )
                                  : SizedBox(
                                      height: 30,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFFD80309),
                                          side: const BorderSide(color: Color(0xFFD80309)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _tampilkanFormUlasan(context, index),
                                        child: const Text('Tulis Ulasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}