import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'absensi_page.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<dynamic> _jadwals = [];
  String? _role;
  bool _loading = true;

  final List<String> _hariOrder = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final jadwals = await ApiService.getJadwal();

    // Sort berdasarkan hari
    jadwals.sort((a, b) {
      return _hariOrder
          .indexOf(a['hari'])
          .compareTo(_hariOrder.indexOf(b['hari']));
    });

    setState(() {
      _role = user?['role'];
      _jadwals = jadwals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_role == 'dosen' || _role == 'admin') {
      return _buildDosenView();
    }
    return _buildMahasiswaView();
  }

  // ========== MAHASISWA: Lihat Jadwal ==========
  Widget _buildMahasiswaView() {
    final grouped = <String, List<dynamic>>{};
    for (var j in _jadwals) {
      grouped.putIfAbsent(j['hari'], () => []).add(j);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hariOrder.length,
      itemBuilder: (ctx, index) {
        final hari = _hariOrder[index];
        final items = grouped[hari] ?? [];
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hari,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((j) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.schedule, color: Color(0xFF1565C0)),
                    ),
                    title: Text(
                      j['matkul']?['nama'] ?? 'Mata Kuliah',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${j['jam_mulai']} - ${j['jam_selesai']}'),
                        Text('Ruangan: ${j['ruangan']} | Kelas: ${j['kelas']}'),
                        Text('Dosen: ${j['dosen']?['user']?['nama'] ?? '-'}'),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ========== DOSEN: Kelola Jadwal + Absensi ==========
  Widget _buildDosenView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddJadwalDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Jadwal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _jadwals.length,
            itemBuilder: (ctx, index) {
              final j = _jadwals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(j['matkul']?['nama'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${j['hari']}, ${j['jam_mulai']} - ${j['jam_selesai']} | ${j['ruangan']} | ${j['kelas']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AbsensiPage(
                                jadwalId: j['id'],
                                matkulNama: j['matkul']?['nama'] ?? '-')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Absen'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddJadwalDialog() {
    final matkulCtrl = TextEditingController();
    final hariCtrl = TextEditingController(text: 'Senin');
    final jamMulaiCtrl = TextEditingController(text: '08:00');
    final jamSelesaiCtrl = TextEditingController(text: '10:00');
    final ruanganCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: matkulCtrl,
                  decoration: const InputDecoration(labelText: 'ID Matkul')),
              TextField(
                  controller: hariCtrl,
                  decoration: const InputDecoration(labelText: 'Hari')),
              TextField(
                  controller: jamMulaiCtrl,
                  decoration: const InputDecoration(labelText: 'Jam Mulai')),
              TextField(
                  controller: jamSelesaiCtrl,
                  decoration: const InputDecoration(labelText: 'Jam Selesai')),
              TextField(
                  controller: ruanganCtrl,
                  decoration: const InputDecoration(labelText: 'Ruangan')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.createJadwal({
                'matkul_id': int.tryParse(matkulCtrl.text) ?? 1,
                'hari': hariCtrl.text,
                'jam_mulai': jamMulaiCtrl.text,
                'jam_selesai': jamSelesaiCtrl.text,
                'ruangan': ruanganCtrl.text,
                'kelas': 'A',
                'semester': 5,
              });
              if (!mounted) return;
              Navigator.pop(context);
              if (result['status'] == 201) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Jadwal ditambahkan')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
