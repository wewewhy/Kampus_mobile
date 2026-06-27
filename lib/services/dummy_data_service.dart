import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DummyDataService {
  static const String dummyToken = 'dummy-session-token';

  static final List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'nama': 'Admin Kampus',
      'email': 'admin@kampus.test',
      'password': 'password',
      'role': 'admin',
      'nomor_induk': 'ADM001',
      'jurusan': 'Akademik',
    },
    {
      'id': 2,
      'nama': 'Dr. Budi Santoso',
      'email': 'dosen.ti@kampus.test',
      'password': 'password',
      'role': 'dosen',
      'nomor_induk': 'DSN-TI-001',
      'jurusan': 'Teknik Informatika',
      'dosen': {
        'id': 1,
        'bidang_keahlian': 'Mobile Development',
        'matkul_ids': [1, 2],
      },
    },
    {
      'id': 3,
      'nama': 'Dra. Sari Lestari',
      'email': 'dosen.si@kampus.test',
      'password': 'password',
      'role': 'dosen',
      'nomor_induk': 'DSN-SI-001',
      'jurusan': 'Sistem Informasi',
      'dosen': {
        'id': 2,
        'bidang_keahlian': 'Sistem Enterprise',
        'matkul_ids': [3],
      },
    },
    {
      'id': 4,
      'nama': 'Andi Pratama',
      'email': 'andi@kampus.test',
      'password': 'password',
      'role': 'mahasiswa',
      'nomor_induk': 'TI2024001',
      'kelas': 'TI-5A',
      'jurusan': 'Teknik Informatika',
      'semester': 5,
      'ipk': 3.72,
      'sks': 98,
      'mahasiswa': {
        'id': 1,
        'kelas': 'TI-5A',
        'jurusan': 'Teknik Informatika',
        'semester': 5,
      },
    },
    {
      'id': 5,
      'nama': 'Maya Putri',
      'email': 'maya@kampus.test',
      'password': 'password',
      'role': 'mahasiswa',
      'nomor_induk': 'TI2024002',
      'kelas': 'TI-5A',
      'jurusan': 'Teknik Informatika',
      'semester': 5,
      'ipk': 3.64,
      'sks': 96,
      'mahasiswa': {
        'id': 2,
        'kelas': 'TI-5A',
        'jurusan': 'Teknik Informatika',
        'semester': 5,
      },
    },
    {
      'id': 6,
      'nama': 'Rina Amelia',
      'email': 'rina@kampus.test',
      'password': 'password',
      'role': 'mahasiswa',
      'nomor_induk': 'SI2024001',
      'kelas': 'SI-4B',
      'jurusan': 'Sistem Informasi',
      'semester': 4,
      'ipk': 3.81,
      'sks': 82,
      'mahasiswa': {
        'id': 3,
        'kelas': 'SI-4B',
        'jurusan': 'Sistem Informasi',
        'semester': 4,
      },
    },
  ];

  static final List<Map<String, dynamic>> matkul = [
    {
      'id': 1,
      'nama': 'Pemrograman Mobile',
      'jurusan': 'Teknik Informatika',
      'sks': 3
    },
    {
      'id': 2,
      'nama': 'Basis Data Lanjut',
      'jurusan': 'Teknik Informatika',
      'sks': 3
    },
    {
      'id': 3,
      'nama': 'Analisis Proses Bisnis',
      'jurusan': 'Sistem Informasi',
      'sks': 3
    },
  ];

  static final List<Map<String, dynamic>> jadwals = [
    {
      'id': 1,
      'matkul_id': 1,
      'dosen_id': 1,
      'hari': 'Senin',
      'jam_mulai': '08:00',
      'jam_selesai': '10:30',
      'ruangan': 'Lab Mobile',
      'kelas': 'TI-5A',
      'semester': 5,
    },
    {
      'id': 2,
      'matkul_id': 2,
      'dosen_id': 1,
      'hari': 'Rabu',
      'jam_mulai': '10:00',
      'jam_selesai': '12:00',
      'ruangan': 'R.204',
      'kelas': 'TI-5A',
      'semester': 5,
    },
    {
      'id': 3,
      'matkul_id': 3,
      'dosen_id': 2,
      'hari': 'Selasa',
      'jam_mulai': '13:00',
      'jam_selesai': '15:00',
      'ruangan': 'R.301',
      'kelas': 'SI-4B',
      'semester': 4,
    },
  ];

  static final List<Map<String, dynamic>> krs = [
    {'mahasiswa_id': 1, 'jadwal_id': 1},
    {'mahasiswa_id': 1, 'jadwal_id': 2},
    {'mahasiswa_id': 2, 'jadwal_id': 1},
    {'mahasiswa_id': 2, 'jadwal_id': 2},
    {'mahasiswa_id': 3, 'jadwal_id': 3},
  ];

  static final List<Map<String, dynamic>> nilais = [
    {
      'id': 1,
      'mahasiswa_id': 1,
      'matkul_id': 1,
      'semester': 5,
      'nilai_akhir': 88,
      'grade': 'A'
    },
    {
      'id': 2,
      'mahasiswa_id': 1,
      'matkul_id': 2,
      'semester': 5,
      'nilai_akhir': 82,
      'grade': 'B+'
    },
    {
      'id': 3,
      'mahasiswa_id': 2,
      'matkul_id': 1,
      'semester': 5,
      'nilai_akhir': 79,
      'grade': 'B+'
    },
    {
      'id': 4,
      'mahasiswa_id': 2,
      'matkul_id': 2,
      'semester': 5,
      'nilai_akhir': 85,
      'grade': 'A-'
    },
    {
      'id': 5,
      'mahasiswa_id': 3,
      'matkul_id': 3,
      'semester': 4,
      'nilai_akhir': 91,
      'grade': 'A'
    },
  ];

  static final List<Map<String, dynamic>> absensis = [
    {
      'jadwal_id': 1,
      'mahasiswa_id': 1,
      'pertemuan_ke': 1,
      'status': 'hadir',
      'tanggal': '2026-06-01'
    },
    {
      'jadwal_id': 1,
      'mahasiswa_id': 2,
      'pertemuan_ke': 1,
      'status': 'izin',
      'tanggal': '2026-06-01'
    },
    {
      'jadwal_id': 2,
      'mahasiswa_id': 1,
      'pertemuan_ke': 1,
      'status': 'hadir',
      'tanggal': '2026-06-03'
    },
    {
      'jadwal_id': 3,
      'mahasiswa_id': 3,
      'pertemuan_ke': 1,
      'status': 'hadir',
      'tanggal': '2026-06-02'
    },
  ];

  static final List<Map<String, dynamic>> pengajuans = [
    {
      'id': 1,
      'judul': 'Aplikasi Presensi Berbasis Mobile',
      'abstrak': 'Pengajuan dummy yang langsung masuk ke admin.',
      'status': 'menunggu',
      'mahasiswa_id': 1,
      'dosen_usulan_1': 1,
      'nama_dosen_usulan': 'Dr. Budi Santoso',
      'nama_dosen_pembimbing': null,
      'created_at': '2026-06-07T09:00:00',
    },
  ];

  static final List<Map<String, dynamic>> events = [
    {
      'id': 1,
      'judul': 'Workshop Flutter Mobile',
      'deskripsi': 'Pelatihan membuat aplikasi kampus dengan Flutter dan API.',
      'tipe': 'gratis',
      'harga': 0,
      'tanggal_event': '2026-06-20',
      'lokasi': 'Lab Mobile',
      'poster_url': '',
      'status': 'aktif',
    },
    {
      'id': 2,
      'judul': 'Seminar Karier Digital',
      'deskripsi': 'Sesi persiapan karier bersama praktisi industri digital.',
      'tipe': 'berbayar',
      'harga': 50000,
      'tanggal_event': '2026-06-26',
      'lokasi': 'Aula Kampus',
      'poster_url': '',
      'status': 'aktif',
    },
  ];

  static final List<Map<String, dynamic>> eventPesertas = [];

  static final List<Map<String, dynamic>> beritas = [
    {
      'id': 1,
      'judul': 'Pendaftaran KRS Semester Ganjil Dibuka',
      'tag': 'Akademik',
      'tanggal': '2026-06-09'
    },
    {
      'id': 2,
      'judul': 'Jadwal UAS Sudah Tersedia di Aplikasi',
      'tag': 'Ujian',
      'tanggal': '2026-06-08'
    },
  ];

  static final List<Map<String, dynamic>> tagihans = [
    {
      'id': 1,
      'nama_tagihan': 'UKT Semester Ganjil',
      'jumlah': 3500000,
      'status': 'belum_lunas',
      'mahasiswa_id': 1,
      'jenis': 'akademik',
    },
    {
      'id': 2,
      'nama_tagihan': 'Praktikum Mobile',
      'jumlah': 250000,
      'status': 'lunas',
      'mahasiswa_id': 1,
      'jenis': 'akademik',
      'metode_pembayaran': 'Bank Transfer',
    },
  ];

  static final List<Map<String, dynamic>> pollings = [
    {
      'id': 1,
      'judul': 'Fasilitas kampus yang paling perlu ditingkatkan',
      'deskripsi': 'Bantu kampus menentukan prioritas layanan semester ini.',
      'options': [
        {'label': 'WiFi kampus', 'votes': 18},
        {'label': 'Ruang belajar', 'votes': 12},
        {'label': 'Kantin', 'votes': 7},
      ],
      'voters': <int>[],
      'status': 'aktif',
      'created_at': '2026-06-10',
    },
    {
      'id': 2,
      'judul': 'Topik seminar berikutnya',
      'deskripsi': 'Pilih topik yang paling menarik untuk event bulan depan.',
      'options': [
        {'label': 'AI untuk mahasiswa', 'votes': 21},
        {'label': 'UI/UX portfolio', 'votes': 10},
        {'label': 'Cyber security', 'votes': 14},
      ],
      'voters': <int>[],
      'status': 'aktif',
      'created_at': '2026-06-12',
    },
  ];

  static Map<String, dynamic>? findUser(String email, String password) {
    try {
      final user = users.firstWhere(
        (u) => u['email'] == email.trim() && u['password'] == password.trim(),
      );
      return cleanUser(user);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> cleanUser(Map<String, dynamic> user) {
    final clean = Map<String, dynamic>.from(user);
    clean.remove('password');
    return clean;
  }

  static Future<Map<String, dynamic>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('dummy_email');
    if (email == null) return null;
    return cleanUser(users.firstWhere((u) => u['email'] == email));
  }

  static Future<void> saveDummySession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dummy_email', user['email']);
  }

  static Future<void> clearDummySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dummy_email');
  }

  static Map<String, dynamic>? matkulById(int id) {
    return matkul
        .cast<Map<String, dynamic>?>()
        .firstWhere((m) => m?['id'] == id, orElse: () => null);
  }

  static Map<String, dynamic>? dosenById(int id) {
    return users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u?['role'] == 'dosen' && u?['dosen']?['id'] == id,
          orElse: () => null,
        );
  }

  static Map<String, dynamic>? mahasiswaById(int id) {
    return users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u?['role'] == 'mahasiswa' && u?['mahasiswa']?['id'] == id,
          orElse: () => null,
        );
  }

  static Future<Map<String, dynamic>?> updateCurrentUserProfile(
      Map<String, dynamic> data) async {
    final current = await currentUser();
    if (current == null) return null;

    final index = users.indexWhere((u) => u['id'] == current['id']);
    if (index < 0) return null;

    final mahasiswa = Map<String, dynamic>.from(users[index]['mahasiswa'] ?? {});
    if (data.containsKey('kelas')) mahasiswa['kelas'] = data['kelas'];
    if (data.containsKey('jurusan')) mahasiswa['jurusan'] = data['jurusan'];

    users[index] = {
      ...users[index],
      if (data.containsKey('nama')) 'nama': data['nama'],
      if (data.containsKey('nomor_induk')) 'nomor_induk': data['nomor_induk'],
      if (data.containsKey('kelas')) 'kelas': data['kelas'],
      if (data.containsKey('jurusan')) 'jurusan': data['jurusan'],
      if (data.containsKey('avatar')) 'avatar': data['avatar'],
      'mahasiswa': mahasiswa,
    };

    return cleanUser(users[index]);
  }

  static List<Map<String, dynamic>> getMahasiswaUsers() {
    return users
        .where((u) => u['role'] == 'mahasiswa')
        .map((u) => cleanUser(u))
        .toList();
  }

  static Future<Map<String, dynamic>?> updateUserProfileById(
      int userId, Map<String, dynamic> data) async {
    final index = users.indexWhere((u) => u['id'] == userId);
    if (index < 0) return null;

    final mahasiswa = Map<String, dynamic>.from(users[index]['mahasiswa'] ?? {});
    if (data.containsKey('kelas')) mahasiswa['kelas'] = data['kelas'];
    if (data.containsKey('jurusan')) mahasiswa['jurusan'] = data['jurusan'];

    users[index] = {
      ...users[index],
      if (data.containsKey('nama')) 'nama': data['nama'],
      if (data.containsKey('nomor_induk')) 'nomor_induk': data['nomor_induk'],
      if (data.containsKey('kelas')) 'kelas': data['kelas'],
      if (data.containsKey('jurusan')) 'jurusan': data['jurusan'],
      if (data.containsKey('avatar')) 'avatar': data['avatar'],
      if (users[index]['role'] == 'mahasiswa') 'mahasiswa': mahasiswa,
    };

    return cleanUser(users[index]);
  }

  static List<Map<String, dynamic>> getEventPesertas(int eventId) {
    return eventPesertas.where((p) => p['event_id'] == eventId).toList();
  }

  static bool isRegisteredToEvent(int eventId, int? mahasiswaId) {
    if (mahasiswaId == null) return false;
    return eventPesertas.any(
      (p) => p['event_id'] == eventId && p['mahasiswa_id'] == mahasiswaId,
    );
  }

  static Future<Map<String, dynamic>> registerEvent(
      Map<String, dynamic> event, Map<String, dynamic>? user) async {
    final mahasiswaId = user?['mahasiswa']?['id'];
    if (mahasiswaId == null) {
      return {'success': false, 'message': 'Hanya mahasiswa yang dapat mendaftar'};
    }

    final eventId = event['id'];
    final existingIndex = eventPesertas.indexWhere(
      (p) => p['event_id'] == eventId && p['mahasiswa_id'] == mahasiswaId,
    );
    if (existingIndex >= 0) {
      return {
        'success': true,
        'message': 'Anda sudah terdaftar pada event ini',
        'peserta': eventPesertas[existingIndex],
      };
    }

    final peserta = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'event_id': eventId,
      'mahasiswa_id': mahasiswaId,
      'nama': user?['nama'] ?? '-',
      'nim': user?['nomor_induk'] ?? '-',
      'kelas': user?['kelas'] ?? user?['mahasiswa']?['kelas'] ?? '-',
      'jurusan': user?['jurusan'] ?? user?['mahasiswa']?['jurusan'] ?? '-',
      'status_pembayaran': event['tipe'] == 'berbayar' ? 'belum_lunas' : 'gratis',
      'created_at': DateTime.now().toIso8601String(),
    };
    eventPesertas.add(peserta);

    if (event['tipe'] == 'berbayar') {
      final hasBill = tagihans.any(
        (t) => t['event_id'] == eventId && t['mahasiswa_id'] == mahasiswaId,
      );
      if (!hasBill) {
        tagihans.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'nama_tagihan': 'Event ${event['judul']}',
          'jumlah': event['harga'] ?? 0,
          'status': 'belum_lunas',
          'mahasiswa_id': mahasiswaId,
          'event_id': eventId,
          'jenis': 'event',
          'event': event,
          'metode_pembayaran': null,
        });
      }
    }

    return {
      'success': true,
      'message': event['tipe'] == 'berbayar'
          ? 'Pendaftaran berhasil. Tagihan event sudah dibuat.'
          : 'Pendaftaran event gratis berhasil.',
      'peserta': peserta,
    };
  }

  static List<Map<String, dynamic>> getTagihanForUser(Map<String, dynamic>? user) {
    if (user?['role'] == 'admin') return tagihans;
    final mahasiswaId = user?['mahasiswa']?['id'];
    return tagihans.where((t) {
      return t['mahasiswa_id'] == null || t['mahasiswa_id'] == mahasiswaId;
    }).toList();
  }

  static Future<bool> payTagihan(int id, String metode) async {
    final index = tagihans.indexWhere((t) => t['id'] == id);
    if (index < 0) return false;

    tagihans[index]['status'] = 'lunas';
    tagihans[index]['metode_pembayaran'] = metode;
    tagihans[index]['tanggal_bayar'] =
        DateTime.now().toIso8601String().split('T').first;

    final eventId = tagihans[index]['event_id'];
    final mahasiswaId = tagihans[index]['mahasiswa_id'];
    if (eventId != null && mahasiswaId != null) {
      final pesertaIndex = eventPesertas.indexWhere(
        (p) => p['event_id'] == eventId && p['mahasiswa_id'] == mahasiswaId,
      );
      if (pesertaIndex >= 0) {
        eventPesertas[pesertaIndex]['status_pembayaran'] = 'lunas';
      }
    }

    return true;
  }

  static List<Map<String, dynamic>> getJadwalForUser(
      Map<String, dynamic>? user) {
    final role = user?['role'];
    final rows = jadwals
        .where((j) {
          if (role == 'admin') return true;
          if (role == 'dosen') return j['dosen_id'] == user?['dosen']?['id'];
          if (role == 'mahasiswa') {
            final mahasiswaId = user?['mahasiswa']?['id'];
            return krs.any((item) =>
                item['mahasiswa_id'] == mahasiswaId &&
                item['jadwal_id'] == j['id']);
          }
          return false;
        })
        .map(_hydrateJadwal)
        .toList();
    return rows;
  }

  static Map<String, dynamic> _hydrateJadwal(Map<String, dynamic> jadwal) {
    return {
      ...jadwal,
      'matkul': matkulById(jadwal['matkul_id']),
      'dosen': {'user': cleanUser(dosenById(jadwal['dosen_id']) ?? {})},
    };
  }

  static List<Map<String, dynamic>> getPesertaJadwal(int jadwalId) {
    return krs.where((item) => item['jadwal_id'] == jadwalId).map((item) {
      final user = mahasiswaById(item['mahasiswa_id']) ?? {};
      return {
        'id': item['mahasiswa_id'],
        'jurusan': user['jurusan'],
        'user': cleanUser(user),
      };
    }).toList();
  }

  static List<Map<String, dynamic>> getNilaiForUser(
      Map<String, dynamic>? user) {
    final role = user?['role'];
    final allowedJadwal = getJadwalForUser(user);
    final allowedMatkulIds = allowedJadwal.map((j) => j['matkul_id']).toSet();
    final allowedMahasiswaIds = allowedJadwal
        .expand((j) => krs
            .where((item) => item['jadwal_id'] == j['id'])
            .map((item) => item['mahasiswa_id']))
        .toSet();

    return nilais.where((n) {
      if (role == 'admin') return true;
      if (role == 'mahasiswa')
        return n['mahasiswa_id'] == user?['mahasiswa']?['id'];
      if (role == 'dosen')
        return allowedMatkulIds.contains(n['matkul_id']) &&
            allowedMahasiswaIds.contains(n['mahasiswa_id']);
      return false;
    }).map((n) {
      return {
        ...n,
        'matkul': matkulById(n['matkul_id']),
        'mahasiswa': {
          'user': cleanUser(mahasiswaById(n['mahasiswa_id']) ?? {})
        },
      };
    }).toList();
  }

  static Map<String, dynamic> getGrafikNilai(int mahasiswaId) {
    final rows = nilais.where((n) => n['mahasiswa_id'] == mahasiswaId).toList();
    final average = rows.isEmpty
        ? 0.0
        : rows
                .map((n) => (n['nilai_akhir'] as num).toDouble())
                .reduce((a, b) => a + b) /
            rows.length;
    return {
      'per_semester': [
        {
          'semester': rows.isEmpty ? 1 : rows.first['semester'],
          'rata_rata': average.round()
        },
      ],
      'per_tahun': [
        {'tahun': '2025/2026', 'rata_rata': average.round()},
      ],
    };
  }

  static Future<void> addAbsensi(Map<String, dynamic> data) async {
    absensis.removeWhere((a) =>
        a['jadwal_id'] == data['jadwal_id'] &&
        a['mahasiswa_id'] == data['mahasiswa_id'] &&
        a['pertemuan_ke'] == data['pertemuan_ke']);
    absensis.add({...data});
  }

  static Future<void> updateNilai(int id, int nilaiAkhir) async {
    final index = nilais.indexWhere((n) => n['id'] == id);
    if (index < 0) return;
    nilais[index]['nilai_akhir'] = nilaiAkhir;
    nilais[index]['grade'] = gradeFromScore(nilaiAkhir);
  }

  static String gradeFromScore(int score) {
    if (score >= 90) return 'A';
    if (score >= 85) return 'A-';
    if (score >= 78) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }

  static Future<void> addPengajuan(
      Map<String, dynamic> data, Map<String, dynamic>? user) async {
    final dosen = dosenById(data['dosen_usulan_1'] ?? 1);
    pengajuans.insert(0, {
      'id': Random().nextInt(9000) + 100,
      'judul': data['judul'],
      'abstrak': data['abstrak'] ?? '',
      'jenis': data['jenis'],
      'bidang_studi': data['bidang_studi'],
      'status': 'menunggu',
      'mahasiswa_id': user?['mahasiswa']?['id'],
      'dosen_usulan_1': data['dosen_usulan_1'],
      'nama_dosen_usulan': dosen?['nama'] ?? 'Dosen',
      'nama_dosen_pembimbing': null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static void addPolling(Map<String, dynamic> data) {
    final rawOptions = (data['options'] as List)
        .where((item) => '$item'.trim().isNotEmpty)
        .toList();
    pollings.insert(0, {
      'id': Random().nextInt(9000) + 100,
      'judul': data['judul'],
      'deskripsi': data['deskripsi'] ?? '',
      'options':
          rawOptions.map((label) => {'label': '$label', 'votes': 0}).toList(),
      'voters': <int>[],
      'status': 'aktif',
      'created_at': DateTime.now().toIso8601String().split('T').first,
    });
  }

  static bool votePolling(int pollingId, int optionIndex, int? userId) {
    final index = pollings.indexWhere((p) => p['id'] == pollingId);
    if (index < 0 || userId == null) return false;
    final voters = pollings[index]['voters'] as List<int>;
    if (voters.contains(userId)) return false;
    final options = pollings[index]['options'] as List<dynamic>;
    if (optionIndex < 0 || optionIndex >= options.length) return false;
    options[optionIndex]['votes'] = (options[optionIndex]['votes'] ?? 0) + 1;
    voters.add(userId);
    return true;
  }

  static List<Map<String, dynamic>> getPengajuanForUser(
      Map<String, dynamic>? user) {
    final rows = pengajuans.map((p) {
      return {
        ...p,
        'mahasiswa': {
          'user': cleanUser(mahasiswaById(p['mahasiswa_id'] ?? 0) ?? {})
        },
      };
    }).toList();
    if (user?['role'] == 'admin') return rows;
    if (user?['role'] == 'mahasiswa') {
      return rows
          .where((p) => p['mahasiswa_id'] == user?['mahasiswa']?['id'])
          .toList();
    }
    return rows;
  }

  static List<Map<String, dynamic>> getDosenList() {
    return users.where((u) => u['role'] == 'dosen').map((u) {
      return {
        'id': u['dosen']['id'],
        'nama': u['nama'],
        'bidang_keahlian': u['dosen']['bidang_keahlian'],
        'sisa_kuota': 4,
      };
    }).toList();
  }
}
