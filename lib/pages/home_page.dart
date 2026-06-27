import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _primary = Color(0xFF1D4ED8);
  static const _teal = Color(0xFF0F766E);
  static const _ink = Color(0xFF111827);

  Map<String, dynamic>? _user;
  List<dynamic> _events = [];
  List<dynamic> _beritaList = [];

  bool _loading = true;

  final ScrollController _eventController = ScrollController();
  final ScrollController _beritaController = ScrollController();
  Timer? _eventTimer;
  Timer? _beritaTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoScroll(_eventController, (timer) => _eventTimer = timer);
    _startAutoScroll(_beritaController, (timer) => _beritaTimer = timer,
        step: 0.8);
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final dashboard = await ApiService.getDashboard();
    final events = await ApiService.getEvents();
    final berita = await ApiService.getBerita();

    if (!mounted) return;
    setState(() {
      _user = user;
      _events = events.isNotEmpty ? events : dashboard['events'] ?? [];
      _beritaList = berita;
      _loading = false;
    });
  }

  void _startAutoScroll(
    ScrollController controller,
    void Function(Timer timer) saveTimer, {
    double step = 1,
  }) {
    final timer = Timer.periodic(const Duration(milliseconds: 45), (_) {
      if (!controller.hasClients || controller.position.maxScrollExtent <= 0)
        return;
      final next = controller.offset + step;
      if (next >= controller.position.maxScrollExtent) {
        controller.jumpTo(0);
      } else {
        controller.jumpTo(next);
      }
    });
    saveTimer(timer);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final nama = _user?['nama'] ?? 'User';
    final role = _user?['role'] ?? '';
    final isMahasiswa = role == 'mahasiswa';

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _profileHero(nama, role),
          const SizedBox(height: 14),
          _quickActions(isMahasiswa),
          if (isMahasiswa) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _metricCard('Semester', '${_user?['semester'] ?? '-'}',
                    Icons.school_outlined, const Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                _metricCard('IPK', '${_user?['ipk'] ?? '-'}',
                    Icons.auto_graph_outlined, const Color(0xFF16A34A)),
                const SizedBox(width: 10),
                _metricCard('SKS', '${_user?['sks'] ?? '-'}',
                    Icons.menu_book_outlined, const Color(0xFF7C3AED)),
              ],
            ),
          ],
          const SizedBox(height: 18),
          _runningPanel(
            title: 'Event & Pelatihan',
            icon: Icons.event_available_outlined,
            height: 172,
            child: _events.isEmpty
                ? _emptyInline('Tidak ada event aktif')
                : ListView.builder(
                    controller: _eventController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _events.length * 12,
                    itemBuilder: (ctx, index) =>
                        _eventCard(_events[index % _events.length]),
                  ),
          ),
          const SizedBox(height: 16),
          _runningPanel(
            title: 'Berita Kampus',
            icon: Icons.newspaper_outlined,
            accent: _teal,
            height: 142,
            child: _beritaList.isEmpty
                ? _emptyInline('Belum ada berita terbaru')
                : ListView.builder(
                    controller: _beritaController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _beritaList.length * 12,
                    itemBuilder: (context, index) =>
                        _beritaCard(_beritaList[index % _beritaList.length]),
                  ),
          ),
          const SizedBox(height: 16),
          _campusPulse(),
        ],
      ),
    );
  }

  Widget _profileHero(String nama, String role) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, _teal]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(0.20),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage:
                _user?['avatar'] != null && '${_user?['avatar']}'.isNotEmpty
                    ? FileImage(File(_user!['avatar']))
                    : null,
            child: _user?['avatar'] != null && '${_user?['avatar']}'.isNotEmpty
                ? null
                : const Icon(Icons.person, size: 30, color: _primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $nama',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(role.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.84),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(bool isMahasiswa) {
    final items = [
      (
        Icons.assignment_outlined,
        isMahasiswa ? 'Ajukan SK' : 'Pengajuan',
        const Color(0xFF0F766E)
      ),
      (Icons.poll_outlined, 'Polling', const Color(0xFF7C3AED)),
      (Icons.calendar_month_outlined, 'Jadwal', const Color(0xFF2563EB)),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: item == items.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
                color: item.$3.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: item.$3.withOpacity(0.18))),
            child: Column(
              children: [
                Icon(item.$1, color: item.$3),
                const SizedBox(height: 8),
                Text(item.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: item.$3,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.22))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _runningPanel(
      {required String title,
      required IconData icon,
      required Widget child,
      Color accent = _primary,
      double height = 132}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.28), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: _ink)),
              const Spacer(),
              Icon(Icons.arrow_forward,
                  color: accent.withOpacity(0.7), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }

  Widget _eventCard(dynamic event) {
    final isGratis = event['tipe'] == 'gratis';
    final poster = event['poster_url'];
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showEventDetail(event),
      child: Container(
        width: 255,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: poster != null && '$poster'.isNotEmpty
                    ? Image.file(
                        File(poster),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _posterFallback(event['judul'] ?? '-'),
                      )
                    : _posterFallback(event['judul'] ?? '-'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _pill(
                    isGratis ? 'GRATIS' : 'BERBAYAR',
                    isGratis
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF97316)),
                const Spacer(),
                const Icon(Icons.touch_app_outlined,
                    size: 16, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 8),
            Text(event['judul'] ?? '-',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: _ink)),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 15, color: Colors.black45),
                const SizedBox(width: 5),
                Expanded(
                    child: Text(event['tanggal_event'] ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _beritaCard(dynamic berita) {
    return Container(
      width: 255,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill(berita['tag'] ?? 'Info', _teal),
              const Spacer(),
              Text(berita['tanggal'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 12),
          Text(berita['judul'] ?? 'Tanpa Judul',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: _ink)),
        ],
      ),
    );
  }

  Widget _campusPulse() {
    return Row(
      children: [
        _pulseCard('Event aktif', '${_events.length}',
            Icons.local_activity_outlined, _primary),
        const SizedBox(width: 10),
        _pulseCard('Berita baru', '${_beritaList.length}',
            Icons.campaign_outlined, _teal),
      ],
    );
  }

  Widget _pulseCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyInline(String message) {
    return Center(
        child: Text(message, style: const TextStyle(color: Colors.black54)));
  }

  Widget _posterFallback(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_primary, _teal]),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showEventDetail(dynamic event) async {
    final isGratis = event['tipe'] == 'gratis';
    final registered = await ApiService.isRegisteredToEvent(event['id']);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: ListView(
            shrinkWrap: true,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: event['poster_url'] != null &&
                          '${event['poster_url']}'.isNotEmpty
                      ? Image.file(
                          File(event['poster_url']),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _posterFallback(event['judul'] ?? '-'),
                        )
                      : _posterFallback(event['judul'] ?? '-'),
                ),
              ),
              const SizedBox(height: 14),
              _pill(isGratis ? 'GRATIS' : 'BERBAYAR',
                  isGratis ? const Color(0xFF16A34A) : const Color(0xFFF97316)),
              const SizedBox(height: 12),
              Text(event['judul'] ?? '-',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(event['deskripsi'] ?? 'Detail event belum diisi.',
                  style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 14),
              _detailRow(Icons.event_outlined, event['tanggal_event'] ?? '-'),
              _detailRow(Icons.location_on_outlined,
                  event['lokasi'] ?? 'Lokasi menyusul'),
              if (!isGratis)
                _detailRow(
                    Icons.payments_outlined, 'Rp ${event['harga'] ?? 0}'),
              if (_user?['role'] == 'mahasiswa') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                    icon: Icon(isGratis
                        ? Icons.how_to_reg_outlined
                        : Icons.payments_outlined),
                    label: Text(registered
                        ? 'Sudah Terdaftar'
                        : isGratis
                            ? 'Daftar Gratis'
                            : 'Daftar & Buat Tagihan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: registered ? Colors.grey : _primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 19, color: _primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _eventTimer?.cancel();
    _beritaTimer?.cancel();
    _eventController.dispose();
    _beritaController.dispose();
    super.dispose();
  }
}
