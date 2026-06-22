class UserModel {
  final int id;
  final String nama;
  final String email;
  final String? noHp; // <--- Tambahkan field nomor hp
  final String? profilePhoto; // <--- Tambahkan field foto profil ini

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.noHp,
    this.profilePhoto, // <--- Tambahkan di konstruktor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['name'] ?? json['nama'] ?? 'Pengguna Lada Bits',
      email: json['email'] ?? 'Email tidak tersedia',
      noHp: json['phone'] ?? json['no_hp'], // <--- Tangkap dari kolom 'phone' atau 'no_hp'
      profilePhoto: json['profile_photo'], // <--- Tangkap data url foto dari Laravel
    );
  }
}