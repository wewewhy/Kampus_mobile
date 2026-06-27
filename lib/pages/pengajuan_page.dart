import 'package:flutter/material.dart';

import '../services/api_service.dart';

class PengajuanPage extends StatefulWidget {
  final String initialType;

  const PengajuanPage({super.key, this.initialType = 'Tugas Akhir'});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  List<dynamic> _pengajuans = [];
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final data = await ApiService.getPengajuan();
    if (!mounted) return;
    setState(() {
      _user = user;
      _pengajuans = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final isMahasiswa = _user?['role'] == 'mahasiswa';
    final visiblePengajuans = _pengajuans.where(_matchesCurrentType).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButton: isMahasiswa
          ? FloatingActionButton.extended(
              onPressed: _showFormPengajuan,
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text('Ajukan', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(isMahasiswa),
          const SizedBox(height: 14),
          if (visiblePengajuans.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Belum ada pengajuan.'))),
          ...visiblePengajuans.map((p) => _pengajuanCard(p)),
        ],
      ),
    );
  }

  bool _matchesCurrentType(dynamic pengajuan) {
    final jenis = '${pengajuan['jenis'] ?? ''}';
    if (jenis.isEmpty && widget.initialType == 'Tugas Akhir') return true;
    return jenis == widget.initialType;
  }

  Widget _header(bool isMahasiswa) {
    final isSkAktif = widget.initialType == 'SK Aktif Kuliah';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSkAktif
              ? const [Color(0xFF0F766E), Color(0xFF1D4ED8)]
              : const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.assignment_outlined, color: Color(0xFF0F766E))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    isSkAktif
                        ? 'Layanan SK Aktif Kuliah'
                        : 'Pengajuan ${widget.initialType}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(
                  isMahasiswa
                      ? 'Isi form dan kirim langsung ke admin'
                      : 'Daftar pengajuan mahasiswa',
                  style: TextStyle(color: Colors.white.withOpacity(0.84)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pengajuanCard(dynamic p) {
    final status = p['status'] ?? 'menunggu';
    final color = status == 'diterima'
        ? Colors.green
        : status == 'ditolak'
            ? Colors.red
            : Colors.orange;
    final mahasiswa = p['mahasiswa']?['user']?['nama'];
    final isSkAktif = p['jenis'] == 'SK Aktif Kuliah';
    final detail = '${p['abstrak'] ?? ''}'.trim();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('$status'.toUpperCase(),
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const Spacer(),
                Text('${p['created_at'] ?? '-'}'.split('T').first,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(p['judul'] ?? '-',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (p['jenis'] != null) ...[
              const SizedBox(height: 6),
              Text('Jenis layanan: ${p['jenis']}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
            if (mahasiswa != null) ...[
              const SizedBox(height: 6),
              Text('Mahasiswa: $mahasiswa',
                  style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 6),
            Text(
                'Tujuan: ${isSkAktif ? 'Admin Akademik' : p['nama_dosen_usulan'] ?? p['dosen_usulan1']?['user']?['nama'] ?? 'Admin Akademik'}',
                style: const TextStyle(fontSize: 13)),
            if (isSkAktif && detail.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detail,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFormPengajuan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FormPengajuanBottomSheet(type: widget.initialType),
    ).then((value) {
      if (value == true) _loadData();
    });
  }
}

class FormPengajuanBottomSheet extends StatefulWidget {
  final String type;

  const FormPengajuanBottomSheet({super.key, required this.type});

  @override
  State<FormPengajuanBottomSheet> createState() =>
      _FormPengajuanBottomSheetState();
}

class _FormPengajuanBottomSheetState extends State<FormPengajuanBottomSheet> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _keperluanCtrl = TextEditingController();
  final _instansiCtrl = TextEditingController();
  List<dynamic> _dosens = [];
  int? _selectedDosen;
  bool _loadingDosen = true;
  bool _isSubmitting = false;

  bool get _isSkAktif => widget.type == 'SK Aktif Kuliah';
  bool get _isTugasAkhir => widget.type == 'Tugas Akhir';

  @override
  void initState() {
    super.initState();
    _loadDosens();
    _judulCtrl.text =
        widget.type == 'Tugas Akhir' ? '' : 'Pengajuan ${widget.type}';
  }

  Future<void> _loadDosens() async {
    final data = await ApiService.getDosenList();
    if (!mounted) return;
    setState(() {
      _dosens = data;
      if (!_isTugasAkhir && data.isNotEmpty) _selectedDosen = data.first['id'];
      _loadingDosen = false;
    });
  }

  Future<void> _submit() async {
    if (_judulCtrl.text.trim().isEmpty ||
        (_isTugasAkhir && _selectedDosen == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data wajib belum lengkap')));
      return;
    }

    if (_isSkAktif && _keperluanCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keperluan SK aktif wajib diisi')));
      return;
    }

    final tujuanDosen =
        _selectedDosen ?? (_dosens.isNotEmpty ? _dosens.first['id'] : null);
    if (tujuanDosen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data tujuan belum tersedia')));
      return;
    }

    final detail = _isSkAktif
        ? [
            'Keperluan: ${_keperluanCtrl.text.trim()}',
            if (_instansiCtrl.text.trim().isNotEmpty)
              'Instansi tujuan: ${_instansiCtrl.text.trim()}',
            if (_deskripsiCtrl.text.trim().isNotEmpty)
              'Catatan: ${_deskripsiCtrl.text.trim()}',
          ].join('\n')
        : _deskripsiCtrl.text.trim();

    setState(() => _isSubmitting = true);
    final result = await ApiService.createPengajuan({
      'jenis': widget.type,
      'judul': _judulCtrl.text.trim(),
      'abstrak': detail,
      'bidang_studi': _isSkAktif ? 'Layanan Akademik' : null,
      'dosen_usulan_1': tujuanDosen,
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajuan berhasil dikirim ke admin')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pengajuan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Form ${widget.type}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(
                controller: _judulCtrl,
                decoration: const InputDecoration(
                    labelText: 'Judul pengajuan',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            if (_isSkAktif) ...[
              TextField(
                  controller: _keperluanCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Keperluan SK aktif',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: _instansiCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Instansi tujuan (opsional)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _deskripsiCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: _isSkAktif ? 'Catatan tambahan' : 'Keterangan',
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            if (_isTugasAkhir) ...[
              const Text('Pilih dosen tujuan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _loadingDosen
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _dosens.length,
                        itemBuilder: (ctx, i) {
                          final d = _dosens[i];
                          return RadioListTile<int>(
                            title: Text(d['nama'] ?? '-'),
                            subtitle: Text(
                                '${d['bidang_keahlian'] ?? '-'} | Sisa: ${d['sisa_kuota'] ?? 0}'),
                            value: d['id'],
                            groupValue: _selectedDosen,
                            onChanged: (d['sisa_kuota'] ?? 0) > 0
                                ? (val) => setState(() => _selectedDosen = val)
                                : null,
                          );
                        },
                      ),
                    ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        color: Color(0xFF0F766E)),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            'Pengajuan akan dikirim ke admin akademik untuk diproses.')),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim Pengajuan'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    _keperluanCtrl.dispose();
    _instansiCtrl.dispose();
    super.dispose();
  }
}
