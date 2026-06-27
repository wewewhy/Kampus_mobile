import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  static const _primary = Color(0xFF1D4ED8);
  static const _teal = Color(0xFF0F766E);

  Map<String, dynamic>? _user;
  List<dynamic> _events = [];
  bool _loading = true;

  bool get _isAdmin => _user?['role'] == 'admin';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final events = await ApiService.getEvents();
    if (!mounted) return;
    setState(() {
      _user = user;
      _events = events;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showEventForm,
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Event'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 14),
            if (_events.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Belum ada event.'),
                ),
              ),
            ..._events.map((event) => _eventCard(event)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, _teal]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.event_outlined, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Kampus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isAdmin
                      ? 'Kelola poster, harga, dan peserta event'
                      : 'Daftar event gratis atau berbayar dari sini',
                  style: TextStyle(color: Colors.white.withOpacity(0.84)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(dynamic event) {
    final gratis = event['tipe'] == 'gratis';
    final color = gratis ? const Color(0xFF16A34A) : const Color(0xFFF97316);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEventDetail(event),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _posterPreview(event['poster_url'], event['judul'] ?? '-'),
              const SizedBox(height: 12),
              Text(
                event['judul'] ?? '-',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                event['deskripsi'] ?? 'Detail event belum diisi.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.schedule_outlined, event['tanggal_event'] ?? '-'),
                  _chip(Icons.location_on_outlined,
                      event['lokasi'] ?? 'Lokasi menyusul'),
                  _chip(
                    Icons.payments_outlined,
                    gratis ? 'Gratis' : _formatCurrency(event['harga']),
                    color: color,
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _posterPreview(String? poster, String title, {double height = 148}) {
    final hasPoster = poster != null && poster.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: hasPoster
            ? Image.file(
                File(poster),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _posterFallback(title),
              )
            : _posterFallback(title),
      ),
    );
  }

  Widget _posterFallback(String title) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.workspace_premium_outlined,
              color: Colors.white, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Poster Event Kampus',
            style: TextStyle(
              color: Colors.white.withOpacity(0.84),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color color = _primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEventDetail(dynamic event) async {
    final gratis = event['tipe'] == 'gratis';
    final registered = await ApiService.isRegisteredToEvent(event['id']);
    final pesertas = await ApiService.getEventPesertas(event['id']);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.94,
        minChildSize: 0.45,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            children: [
              _posterPreview(
                event['poster_url'],
                event['judul'] ?? 'Event Kampus',
                height: 220,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    Icons.confirmation_number_outlined,
                    gratis ? 'Gratis' : 'Berbayar',
                    color: gratis
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF97316),
                  ),
                  _chip(Icons.people_alt_outlined, '${pesertas.length} peserta',
                      color: _teal),
                  if (registered)
                    _chip(Icons.verified_outlined, 'Sudah terdaftar',
                        color: const Color(0xFF16A34A)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event['judul'] ?? '-',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                event['deskripsi'] ?? 'Detail event belum diisi.',
                style: const TextStyle(color: Colors.black87, height: 1.35),
              ),
              const SizedBox(height: 14),
              _detailRow(Icons.event_outlined, event['tanggal_event'] ?? '-'),
              _detailRow(Icons.location_on_outlined,
                  event['lokasi'] ?? 'Lokasi menyusul'),
              _detailRow(Icons.payments_outlined,
                  gratis ? 'Gratis' : _formatCurrency(event['harga'])),
              const SizedBox(height: 12),
              if (_isAdmin) _pesertaList(pesertas),
              if (_user?['role'] == 'mahasiswa') ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: registered
                        ? null
                        : () async {
                            final result = await ApiService.registerEvent(
                              Map<String, dynamic>.from(event),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(result['message'] ?? '-')),
                            );
                            await _loadData();
                          },
                    icon: Icon(gratis
                        ? Icons.how_to_reg_outlined
                        : Icons.payments_outlined),
                    label: Text(
                      registered
                          ? 'Sudah Terdaftar'
                          : gratis
                              ? 'Daftar Gratis'
                              : 'Daftar & Buat Tagihan',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: registered ? Colors.grey : _primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (!gratis && !registered) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Setelah daftar, tagihan event akan muncul di menu Tagihan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _pesertaList(List<dynamic> pesertas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Peserta Terdaftar',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (pesertas.isEmpty)
            const Text('Belum ada peserta.',
                style: TextStyle(color: Colors.black54))
          else
            ...pesertas.map(
              (p) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text(p['nama'] ?? '-'),
                subtitle: Text(
                  '${p['nim'] ?? '-'} - ${p['kelas'] ?? '-'} - ${p['jurusan'] ?? '-'}',
                ),
                trailing: Text(
                  p['status_pembayaran'] == 'lunas'
                      ? 'Lunas'
                      : p['status_pembayaran'] == 'gratis'
                          ? 'Gratis'
                          : 'Belum lunas',
                  style: TextStyle(
                    color: p['status_pembayaran'] == 'belum_lunas'
                        ? const Color(0xFFF97316)
                        : const Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 19),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    final number = int.tryParse('$value') ?? 0;
    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  void _showEventForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => const EventFormSheet(),
    ).then((value) {
      if (value == true) _loadData();
    });
  }
}

class EventFormSheet extends StatefulWidget {
  const EventFormSheet({super.key});

  @override
  State<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<EventFormSheet> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController(text: '0');
  final _picker = ImagePicker();

  String _tipe = 'gratis';
  String? _posterPath;
  bool _submitting = false;

  Future<void> _pickPoster() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1600,
    );
    if (image == null) return;
    setState(() => _posterPath = image.path);
  }

  Future<void> _submit() async {
    if (_judulCtrl.text.trim().isEmpty || _tanggalCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan tanggal wajib diisi')),
      );
      return;
    }

    setState(() => _submitting = true);
    final result = await ApiService.createEvent({
      'judul': _judulCtrl.text.trim(),
      'deskripsi': _deskripsiCtrl.text.trim(),
      'tipe': _tipe,
      'harga':
          _tipe == 'gratis' ? 0 : int.tryParse(_hargaCtrl.text.trim()) ?? 0,
      'tanggal_event': _tanggalCtrl.text.trim(),
      'lokasi': _lokasiCtrl.text.trim(),
      'poster_url': _posterPath ?? '',
      'status': 'aktif',
    });

    if (!mounted) return;
    setState(() => _submitting = false);
    if (result['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah Event',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickPoster,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1D4ED8)),
                ),
                child: _posterPath == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: Color(0xFF1D4ED8), size: 36),
                          SizedBox(height: 8),
                          Text(
                            'Pilih file poster event',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(File(_posterPath!),
                            fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul event',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deskripsiCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tanggalCtrl,
              decoration: const InputDecoration(
                labelText: 'Tanggal event (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lokasiCtrl,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'gratis',
                  label: Text('Gratis'),
                  icon: Icon(Icons.card_giftcard_outlined),
                ),
                ButtonSegment(
                  value: 'berbayar',
                  label: Text('Berbayar'),
                  icon: Icon(Icons.payments_outlined),
                ),
              ],
              selected: {_tipe},
              onSelectionChanged: (value) =>
                  setState(() => _tipe = value.first),
            ),
            if (_tipe == 'berbayar') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Event'),
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
    _tanggalCtrl.dispose();
    _lokasiCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }
}
