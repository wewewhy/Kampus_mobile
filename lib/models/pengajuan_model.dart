class PengajuanModel {
  final int id;
  final int mahasiswaId;
  final String judul;
  final String? abstrak;
  final String? bidangStudi;
  final int dosenUsulan1Id;
  final int? dosenUsulan2Id;
  final int? dosenPembimbingId;
  final String status;
  final String? keterangan;
  final String? createdAt;

  // Objek Relasi Hasil Eager Loading Laravel
  final Map<String, dynamic>? mahasiswa;
  final Map<String, dynamic>? dosenUsulan1Data;
  final Map<String, dynamic>? dosenPembimbingData;

  PengajuanModel({
    required this.id,
    required this.mahasiswaId,
    required this.judul,
    this.abstrak,
    this.bidangStudi,
    required this.dosenUsulan1Id,
    this.dosenUsulan2Id,
    this.dosenPembimbingId,
    required this.status,
    this.keterangan,
    this.createdAt,
    this.mahasiswa,
    this.dosenUsulan1Data,
    this.dosenPembimbingData,
  });

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    // Antisipasi perubahan tipe data akibat Eager Loading Laravel
    Map<String, dynamic>? dPembimbing;
    if (json['dosen_pembimbing'] is Map) {
      dPembimbing = json['dosen_pembimbing'];
    }

    return PengajuanModel(
      id: json['id'] ?? 0,
      mahasiswaId: json['mahasiswa_id'] ?? 0,
      judul: json['judul'] ?? '',
      abstrak: json['abstrak'],
      bidangStudi: json['bidang_studi'],

      // Ambil ID murni kolom database
      dosenUsulan1Id:
          json['dosen_usulan_1'] is int ? json['dosen_usulan_1'] : 0,
      dosenUsulan2Id: json['dosen_usulan_2'],
      dosenPembimbingId: json['dosen_pembimbing'] is int
          ? json['dosen_pembimbing']
          : dPembimbing?['id'],

      status: json['status'] ?? 'menunggu',
      keterangan: json['keterangan'],
      createdAt: json['created_at'],

      // Mengambil objek relasi Laravel
      mahasiswa: json['mahasiswa'],
      // Relasi dari fungsi dosenUsulan1() diubah Laravel menjadi dosen_usulan1
      dosenUsulan1Data: json['dosen_usulan1'] ?? json['dosen_usulan_1_data'],
      dosenPembimbingData: dPembimbing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'judul': judul,
      'abstrak': abstrak,
      'bidang_studi': bidangStudi,
      'dosen_usulan_1': dosenUsulan1Id,
      'dosen_usulan_2': dosenUsulan2Id,
      'dosen_pembimbing': dosenPembimbingId,
      'status': status,
      'keterangan': keterangan,
    };
  }

  // Getters Helper untuk UI Flutter
  String get namaMahasiswa {
    if (mahasiswa != null && mahasiswa!['user'] != null) {
      return mahasiswa!['user']['nama'] ?? '-';
    }
    return '-';
  }

  String get namaDosenUsulan {
    if (dosenUsulan1Data != null && dosenUsulan1Data!['user'] != null) {
      return dosenUsulan1Data!['user']['nama'] ?? '-';
    }
    return '-';
  }

  String get namaDosenPembimbing {
    if (dosenPembimbingData != null && dosenPembimbingData!['user'] != null) {
      return dosenPembimbingData!['user']['nama'] ?? '-';
    }
    return 'Belum Ditentukan';
  }

  String get statusLabel {
    switch (status) {
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  int get statusColor {
    switch (status) {
      case 'diterima':
        return 0xFF4CAF50; // Hijau
      case 'ditolak':
        return 0xFFF44336; // Merah
      default:
        return 0xFFFF9800; // Jingga
    }
  }

  bool get isMenunggu => status == 'menunggu';
  bool get isDiterima => status == 'diterima';
  bool get isDitolak => status == 'ditolak';
}
