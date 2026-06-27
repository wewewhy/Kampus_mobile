import 'package:flutter/material.dart';

import '../services/api_service.dart';

class PollingPage extends StatefulWidget {
  const PollingPage({super.key});

  @override
  State<PollingPage> createState() => _PollingPageState();
}

class _PollingPageState extends State<PollingPage> {
  static const _primary = Color(0xFF1D4ED8);
  static const _violet = Color(0xFF7C3AED);

  Map<String, dynamic>? _user;
  List<dynamic> _pollings = [];
  bool _loading = true;

  bool get _isAdmin => _user?['role'] == 'admin';
  bool get _canVote => _user != null && _user?['role'] != 'admin';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final pollings = await ApiService.getPollings();
    if (!mounted) return;
    setState(() {
      _user = user;
      _pollings = pollings;
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
              onPressed: _showPollingForm,
              backgroundColor: _violet,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('Tambah Polling'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 14),
            if (_pollings.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Belum ada polling.'))),
            ..._pollings.map((polling) => _pollingCard(polling)),
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
        gradient: const LinearGradient(colors: [_violet, _primary]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.poll_outlined, color: _violet)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Polling Kampus',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(
                    _isAdmin
                        ? 'Buat polling dan pantau hasilnya'
                        : 'Pilih polling aktif dari kampus',
                    style: TextStyle(color: Colors.white.withOpacity(0.84))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pollingCard(dynamic polling) {
    final options = (polling['options'] as List<dynamic>? ?? []);
    final voters = polling['voters'] as List<dynamic>? ?? [];
    final total = options.fold<int>(
        0, (sum, option) => sum + ((option['votes'] ?? 0) as num).toInt());
    final hasVoted = voters.contains(_user?['id']);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
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
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                      color: _violet.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('AKTIF',
                      style: TextStyle(
                          color: _violet,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text('${polling['created_at'] ?? '-'}'.split('T').first,
                    style:
                        const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(polling['judul'] ?? '-',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if ('${polling['deskripsi'] ?? ''}'.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(polling['deskripsi'],
                  style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 14),
            ...List.generate(options.length, (index) {
              final option = options[index];
              final votes = ((option['votes'] ?? 0) as num).toInt();
              final percent = total == 0 ? 0.0 : votes / total;
              return _pollOption(
                label: option['label'] ?? '-',
                votes: votes,
                percent: percent,
                enabled: _canVote && !hasVoted,
                onTap: () => _vote(polling['id'], index, option['id']),
              );
            }),
            const SizedBox(height: 6),
            Text(
              hasVoted
                  ? 'Kamu sudah memilih polling ini.'
                  : _canVote
                      ? 'Ketuk salah satu pilihan untuk memberi suara'
                      : '$total suara terkumpul',
              style: TextStyle(
                  color: hasVoted ? _violet : Colors.black45,
                  fontWeight: hasVoted ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pollOption({
    required String label,
    required int votes,
    required double percent,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text('${(percent * 100).round()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: _violet)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: _violet),
              ),
              const SizedBox(height: 5),
              Text('$votes suara',
                  style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _vote(int pollingId, int optionIndex, dynamic optionId) async {
    final ok = await ApiService.votePolling(pollingId, optionIndex,
        optionId: optionId is int ? optionId : null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Terima kasih, polling berhasil diisi'
            : 'Polling ini sudah pernah diisi')));
    _loadData();
  }

  void _showPollingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => const PollingFormSheet(),
    ).then((value) {
      if (value == true) _loadData();
    });
  }
}

class PollingFormSheet extends StatefulWidget {
  const PollingFormSheet({super.key});

  @override
  State<PollingFormSheet> createState() => _PollingFormSheetState();
}

class _PollingFormSheetState extends State<PollingFormSheet> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  bool _submitting = false;

  Future<void> _submit() async {
    final options = _optionCtrls
        .map((ctrl) => ctrl.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    if (_judulCtrl.text.trim().isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Judul dan minimal dua pilihan wajib diisi')));
      return;
    }

    setState(() => _submitting = true);
    final ok = await ApiService.createPolling({
      'judul': _judulCtrl.text.trim(),
      'deskripsi': _deskripsiCtrl.text.trim(),
      'options': options,
    });
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Polling berhasil dibuat')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Polling',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(
                controller: _judulCtrl,
                decoration: const InputDecoration(
                    labelText: 'Pertanyaan polling',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: _deskripsiCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi singkat',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Text('Pilihan jawaban',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(_optionCtrls.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                    controller: _optionCtrls[index],
                    decoration: InputDecoration(
                        labelText: 'Pilihan ${index + 1}',
                        border: const OutlineInputBorder())),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _optionCtrls.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('Tambah pilihan'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Polling'),
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
    for (final ctrl in _optionCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }
}
