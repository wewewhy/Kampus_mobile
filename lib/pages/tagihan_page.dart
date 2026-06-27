import 'package:flutter/material.dart';

import '../services/api_service.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  static const _primary = Color(0xFF1D4ED8);
  static const _green = Color(0xFF16A34A);
  static const _orange = Color(0xFFF97316);

  List<dynamic> _tagihans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tagihans = await ApiService.getTagihan();
    if (!mounted) return;
    setState(() {
      _tagihans = tagihans;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final totalBelumLunas = _tagihans
        .where((t) => t['status'] != 'lunas')
        .fold<int>(0, (sum, t) => sum + (int.tryParse('${t['jumlah']}') ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summary(totalBelumLunas),
            const SizedBox(height: 14),
            if (_tagihans.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Tidak ada tagihan.'),
                ),
              )
            else
              ..._tagihans.map((tagihan) => _billCard(tagihan)),
          ],
        ),
      ),
    );
  }

  Widget _summary(int totalBelumLunas) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, Color(0xFF0F766E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.receipt_long_outlined, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tagihan Mahasiswa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalBelumLunas == 0
                      ? 'Semua tagihan sudah lunas'
                      : 'Belum lunas: ${_formatCurrency(totalBelumLunas)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.86)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billCard(dynamic tagihan) {
    final lunas = tagihan['status'] == 'lunas';
    final isEvent = tagihan['jenis'] == 'event' || tagihan['event_id'] != null;
    final color = lunas ? _green : _orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  isEvent ? Icons.event_available_outlined : Icons.school,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagihan['nama_tagihan'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEvent
                          ? 'Tagihan event dan status peserta otomatis terhubung'
                          : 'Tagihan akademik kampus',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusChip(lunas),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  'Jumlah',
                  _formatCurrency(tagihan['jumlah']),
                  Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoTile(
                  'Metode',
                  tagihan['metode_pembayaran'] ?? 'Belum dipilih',
                  Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
          if (!lunas) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentSheet(tagihan),
                icon: const Icon(Icons.payment_outlined),
                label: const Text('Bayar Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool lunas) {
    final color = lunas ? _green : _orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        lunas ? 'Lunas' : 'Belum lunas',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPaymentSheet(dynamic tagihan) {
    final methods = [
      (Icons.qr_code_2_outlined, 'QRIS', 'Scan QR dan konfirmasi otomatis'),
      (Icons.account_balance_outlined, 'Bank Transfer', 'BCA, BNI, BRI, Mandiri'),
      (Icons.account_balance_wallet_outlined, 'E-Wallet', 'DANA, OVO, GoPay'),
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tagihan['nama_tagihan'] ?? 'Pembayaran',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(tagihan['jumlah']),
              style: const TextStyle(
                color: _primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...methods.map(
              (method) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _primary.withOpacity(0.10),
                    child: Icon(method.$1, color: _primary),
                  ),
                  title: Text(method.$2,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(method.$3),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final ok =
                        await ApiService.payTagihan(tagihan['id'], method.$2);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Pembayaran ${method.$2} berhasil. Tagihan lunas.'
                            : 'Pembayaran gagal diproses.'),
                      ),
                    );
                    await _loadData();
                  },
                ),
              ),
            ),
          ],
        ),
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
}
