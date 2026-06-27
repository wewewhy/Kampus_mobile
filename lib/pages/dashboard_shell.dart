import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import 'active_feature_page.dart';
import 'absensi_page.dart';
import 'event_page.dart';
import 'home_page.dart';
import 'jadwal_page.dart';
import 'KelolaBeritaPage.dart';
import 'nilai_page.dart';
import 'pengajuan_page.dart';
import 'polling_page.dart';
import 'profile_page.dart';
import 'tagihan_page.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _user;

  final List<String> _titles = [
    'Dashboard',
    'Jadwal Kuliah',
    'Jadwal Ujian',
    'Absensi',
    'KRS Aktif',
    'Isi KRS',
    'Nilai Perkuliahan',
    'KHS',
    'Transkrip',
    'Remedial',
    'Semester Pendek',
    'Ujian Susulan',
    'Koreksi Nilai',
    'Tugas Akhir',
    'SK Aktif Kuliah',
    'Polling',
    'Tagihan',
    'Event Kampus',
    'Berita Kampus',
    'Profil Saya',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  bool get _isMahasiswa => _user?['role'] == 'mahasiswa';
  bool get _isAdmin => _user?['role'] == 'admin';

  List<Widget> get _pages => [
        const HomePage(),
        const JadwalPage(),
        ActiveFeaturePage(
          title: 'Jadwal Ujian',
          icon: Icons.event_available_outlined,
          readOnly: _isMahasiswa,
          items: const [
            'Ujian Tengah Semester',
            'Ujian Akhir Semester',
            'Ujian Praktikum'
          ],
        ),
        const AbsensiOverviewPage(),
        ActiveFeaturePage(
          title: 'KRS Aktif',
          icon: Icons.fact_check_outlined,
          readOnly: _isMahasiswa,
          items: const [
            'Pemrograman Mobile',
            'Basis Data Lanjut',
            'Analisis Proses Bisnis'
          ],
        ),
        ActiveFeaturePage(
          title: 'Isi dan Edit KRS',
          icon: Icons.playlist_add_check_outlined,
          readOnly: _isMahasiswa,
          items: const ['Tambah Mata Kuliah', 'Hapus Mata Kuliah', 'Cetak KRS'],
        ),
        const NilaiPage(),
        ActiveFeaturePage(
          title: 'Kartu Hasil Studi',
          icon: Icons.receipt_long_outlined,
          items: const ['KHS Semester 4', 'KHS Semester 5', 'Unduh KHS'],
        ),
        const NilaiPage(transcriptMode: true),
        ActiveFeaturePage(
          title: 'Remedial',
          icon: Icons.refresh_outlined,
          readOnly: _isMahasiswa,
          items: const [
            'Daftar Remedial',
            'Status Pendaftaran',
            'Hasil Remedial'
          ],
        ),
        ActiveFeaturePage(
          title: 'Semester Pendek',
          icon: Icons.sunny,
          readOnly: _isMahasiswa,
          items: const ['Paket Mata Kuliah', 'Pendaftaran', 'Jadwal SP'],
        ),
        const PengajuanPage(initialType: 'Ujian Susulan'),
        const PengajuanPage(initialType: 'Koreksi Nilai'),
        const PengajuanPage(initialType: 'Tugas Akhir'),
        const PengajuanPage(initialType: 'SK Aktif Kuliah'),
        const PollingPage(),
        const TagihanPage(),
        const EventPage(),
        const KelolaBeritaPage(),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    final title =
        _selectedIndex < _titles.length ? _titles[_selectedIndex] : 'Menu';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isAdmin)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.admin_panel_settings_outlined),
            ),
        ],
      ),
      drawer: Sidebar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
      body: _selectedIndex < _pages.length
          ? _pages[_selectedIndex]
          : const Center(child: Text('Halaman tidak ditemukan')),
    );
  }
}
