import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/dummy_data_service.dart';

class AbsensiOverviewPage extends StatefulWidget {
  const AbsensiOverviewPage({super.key});

  @override
  State<AbsensiOverviewPage> createState() => _AbsensiOverviewPageState();
}

class _AbsensiOverviewPageState extends State<AbsensiOverviewPage> {
  List<dynamic> _jadwals = [];
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await ApiService.getUser();
    final jadwals = await ApiService.getJadwal();
    if (!mounted) return;
    setState(() {
      _user = user;
      _jadwals = jadwals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final role = _user?['role'] ?? '';
    if (role == 'mahasiswa') return _buildMahasiswaReadOnly();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('Kelola Absensi', 'Pilih kelas untuk mengisi atau mengubah absensi.'),
        const SizedBox(height: 14),
        ..._jadwals.map((j) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Icon(Icons.fact_check_outlined, color: Color(0xFF1565C0)),
                ),
                title: Text(j['matkul']?['nama'] ?? 'Mata Kuliah', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${j['hari']}, ${j['jam_mulai']} - ${j['jam_selesai']} | ${j['kelas']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AbsensiPage(jadwalId: j['id'], matkulNama: j['matkul']?['nama'] ?? 'Mata Kuliah'),
                    ),
                  ).then((_) => _load());
                },
              ),
            )),
      ],
    );
  }

  Widget _buildMahasiswaReadOnly() {
    final mahasiswaId = _user?['mahasiswa']?['id'];
    final rows = DummyDataService.absensis.where((a) => a['mahasiswa_id'] == mahasiswaId).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('Rekap Absensi', 'Mahasiswa hanya dapat melihat data kehadiran.'),
        const SizedBox(height: 14),
        if (rows.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Belum ada data absensi.'))),
        ...rows.map((a) {
          final jadwal = DummyDataService.jadwals.firstWhere((j) => j['id'] == a['jadwal_id']);
          final matkul = DummyDataService.matkulById(jadwal['matkul_id']);
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: Icon(_statusIcon(a['status']), color: _statusColor(a['status'])),
              title: Text(matkul?['nama'] ?? 'Mata Kuliah', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Pertemuan ${a['pertemuan_ke']} - ${a['tanggal']}'),
              trailing: Text('${a['status']}'.toUpperCase(), style: TextStyle(color: _statusColor(a['status']), fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ],
    );
  }

  Widget _header(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.check_circle_outline, color: Color(0xFF1565C0))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.84))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'hadir') return Colors.green;
    if (status == 'alpa') return Colors.red;
    return Colors.orange;
  }

  IconData _statusIcon(String status) {
    if (status == 'hadir') return Icons.check_circle_outline;
    if (status == 'alpa') return Icons.cancel_outlined;
    return Icons.info_outline;
  }
}

class AbsensiPage extends StatefulWidget {
  final int jadwalId;
  final String matkulNama;

  const AbsensiPage(
      {super.key, required this.jadwalId, required this.matkulNama});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  List<dynamic> _mahasiswas = [];
  Map<int, String> _statusMap = {}; // id_mahasiswa -> status
  int _pertemuan = 1;
  bool _loading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMahasiswa();
  }

  Future<void> _loadMahasiswa() async {
    try {
      final data = await ApiService.getPesertaJadwal(widget.jadwalId);

      if (!mounted) return;
      setState(() {
        _mahasiswas = data;
        for (var m in _mahasiswas) {
          _statusMap[m['id']] = 'hadir';
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat daftar mahasiswa')),
      );
    }
  }

  Future<void> _simpanAbsensi() async {
    setState(() => _isSaving = true);

    for (var entry in _statusMap.entries) {
      await ApiService.createAbsensi({
        'jadwal_id': widget.jadwalId,
        'mahasiswa_id': entry.key,
        'pertemuan_ke': _pertemuan,
        'status': entry.value,
        'tanggal': DateTime.now().toIso8601String().split('T')[0],
      });
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Absensi berhasil disimpan!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absen - ${widget.matkulNama}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('Pertemuan ke:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: _pertemuan,
                        items: List.generate(16, (i) => i + 1).map((p) {
                          return DropdownMenuItem(value: p, child: Text('$p'));
                        }).toList(),
                        onChanged: (val) => setState(() => _pertemuan = val!),
                      ),
                    ],
                  ),
                ),
                if (_mahasiswas.isEmpty)
                  const Expanded(
                      child:
                          Center(child: Text('Tidak ada mahasiswa terdaftar'))),
                Expanded(
                  child: ListView.builder(
                    itemCount: _mahasiswas.length,
                    itemBuilder: (ctx, index) {
                      final m = _mahasiswas[index];
                      final namaMhs =
                          m['user']?['nama'] ?? m['nama'] ?? 'Unknown';
                      final nimMhs =
                          m['user']?['nomor_induk'] ?? m['nim'] ?? '-';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF1565C0).withOpacity(0.1),
                            foregroundColor: const Color(0xFF1565C0),
                            child: Text('${index + 1}'),
                          ),
                          title: Text(namaMhs,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('NIM: $nimMhs'),
                          trailing: DropdownButton<String>(
                            value: _statusMap[m['id']],
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                            items: ['hadir', 'alpa', 'izin', 'sakit'].map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s.toUpperCase(),
                                  style: TextStyle(
                                    color: s == 'hadir'
                                        ? Colors.green
                                        : (s == 'alpa'
                                            ? Colors.red
                                            : Colors.orange),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _statusMap[m['id']] = val!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_mahasiswas.isEmpty || _isSaving)
                          ? null
                          : _simpanAbsensi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SIMPAN ABSENSI',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
