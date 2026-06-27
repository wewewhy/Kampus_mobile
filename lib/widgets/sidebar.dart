import 'dart:io';

import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import '../services/api_service.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final nama = user?['nama'] ?? 'User';
        final role = user?['role'] ?? '';
        final nomorInduk = user?['nomor_induk'] ?? '';
        final jurusan = user?['jurusan'] ?? '-';
        final avatar = user?['avatar'];

        return Drawer(
          backgroundColor: const Color(0xFFF8FAFC),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          avatar != null && '$avatar'.isNotEmpty
                              ? FileImage(File(avatar))
                              : null,
                      child: avatar != null && '$avatar'.isNotEmpty
                          ? null
                          : const Icon(Icons.person,
                              size: 30, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nama,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${role.toUpperCase()} - $nomorInduk',
                      style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12),
                    ),
                    Text(
                      jurusan,
                      style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12),
                    ),
                  ],
                ),
              ),
              _menu(Icons.home_outlined, 'Dashboard', 0),
              _section('Akademik'),
              _expand(Icons.calendar_today_outlined, 'Jadwal', [
                _sub('Jadwal Kuliah', 1),
                _sub('Jadwal Ujian', 2),
              ]),
              _menu(Icons.check_circle_outline, 'Absensi', 3),
              _expand(Icons.book_outlined, 'Kartu Rencana Studi', [
                _sub('Lihat / Cetak', 4),
                if (role != 'dosen') _sub(role == 'mahasiswa' ? 'Isi / Edit (lihat)' : 'Isi / Edit', 5),
              ]),
              _expand(Icons.bar_chart_outlined, 'Nilai', [
                _sub('Perkuliahan', 6),
                _sub('Kartu Hasil Studi', 7),
                _sub('Transkrip Akademik', 8),
                _sub('Remedial', 9),
                _sub('Semester Pendek', 10),
              ]),
              _section('Layanan'),
              _expand(Icons.assignment_outlined, 'Pengajuan ke Admin', [
                _sub('Ujian Susulan', 11),
                _sub('Koreksi Nilai', 12),
                _sub('Tugas Akhir', 13),
                _sub('SK Aktif Kuliah', 14),
              ]),
              _menu(Icons.poll_outlined, 'Polling', 15),
              _menu(Icons.payment_outlined, 'Tagihan', 16),
              _menu(Icons.event_outlined, 'Event Kampus', 17),
              _menu(Icons.account_circle_outlined, 'Profil Saya', 19),
              if (role == 'admin') ...[
                _section('Admin'),
                _menu(Icons.edit_note, 'Kelola Berita', 18),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _menu(IconData icon, String title, int index) {
    final active = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: active ? const Color(0xFF1565C0) : Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: active ? const Color(0xFF1565C0) : Colors.black87,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () => onItemSelected(index),
    );
  }

  Widget _expand(IconData icon, String title, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: children,
    );
  }

  Widget _sub(String title, int index) {
    final active = selectedIndex == index;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 60, right: 16),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: active ? const Color(0xFF1565C0) : Colors.black87,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onItemSelected(index),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
