class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String nomorInduk;
  final String? avatar;
  final Map<String, dynamic>? mahasiswa;
  final Map<String, dynamic>? dosen;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    required this.nomorInduk,
    this.avatar,
    this.mahasiswa,
    this.dosen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      nomorInduk: json['nomor_induk'] ?? '',
      avatar: json['avatar'],
      mahasiswa: json['mahasiswa'],
      dosen: json['dosen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'nomor_induk': nomorInduk,
      'avatar': avatar,
      'mahasiswa': mahasiswa,
      'dosen': dosen,
    };
  }
}
