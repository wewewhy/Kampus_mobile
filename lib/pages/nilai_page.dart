import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NilaiPage extends StatefulWidget {
  final bool transcriptMode;

  const NilaiPage({super.key, this.transcriptMode = false});

  @override
  State<NilaiPage> createState() => _NilaiPageState();
}

class _NilaiPageState extends State<NilaiPage> {
  List<dynamic> _nilais = [];
  Map<String, dynamic>? _grafik;
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final nilais = await ApiService.getNilai();
    Map<String, dynamic>? grafik;

    if (user?['mahasiswa'] != null) {
      grafik = await ApiService.getGrafikNilai(user!['mahasiswa']['id']);
    }

    if (!mounted) return;
    setState(() {
      _user = user;
      _nilais = nilais;
      _grafik = grafik;
      _loading = false;
    });
  }

  bool get _canEdit =>
      !widget.transcriptMode &&
      (_user?['role'] == 'admin' || _user?['role'] == 'dosen');

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _summaryCard(),
        const SizedBox(height: 16),
        if (widget.transcriptMode) ...[
          _transcriptSummary(),
          const SizedBox(height: 16),
        ],
        if (_grafik != null && _grafik!['per_semester'] != null)
          _chart('Grafik Nilai', _grafik!['per_semester'], 'semester'),
        const SizedBox(height: 16),
        Text(widget.transcriptMode ? 'Transkrip Nilai' : 'Detail Nilai',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_nilais.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Belum ada data nilai.'))),
        ..._nilais.map((n) => _nilaiCard(n)),
      ],
    );
  }

  Widget _summaryCard() {
    final role = _user?['role'] ?? '';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.bar_chart_outlined, color: Color(0xFF1565C0))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.transcriptMode ? 'Transkrip Akademik' : 'Nilai Akademik',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  widget.transcriptMode
                      ? 'Nilai sesuai input dosen pada mata kuliah yang diikuti'
                      : role == 'mahasiswa'
                          ? 'Mode lihat data'
                          : 'Data sesuai jurusan dan mata kuliah',
                  style: TextStyle(color: Colors.white.withOpacity(0.84)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transcriptSummary() {
    final totalSks = _nilais.fold<int>(0, (sum, n) {
      return sum + ((n['matkul']?['sks'] ?? 0) as num).toInt();
    });
    final totalBobot = _nilais.fold<double>(0, (sum, n) {
      final sks = ((n['matkul']?['sks'] ?? 0) as num).toDouble();
      return sum + (_gradePoint('${n['grade'] ?? ''}') * sks);
    });
    final ipk = totalSks == 0 ? 0.0 : totalBobot / totalSks;

    return Row(
      children: [
        Expanded(child: _metricTile('IPK', ipk.toStringAsFixed(2))),
        const SizedBox(width: 10),
        Expanded(child: _metricTile('Total SKS', '$totalSks')),
        const SizedBox(width: 10),
        Expanded(child: _metricTile('Mata Kuliah', '${_nilais.length}')),
      ],
    );
  }

  Widget _metricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
        ],
      ),
    );
  }

  double _gradePoint(String grade) {
    switch (grade) {
      case 'A':
        return 4;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3;
      case 'C':
        return 2;
      case 'D':
        return 1;
      default:
        return 0;
    }
  }

  Widget _nilaiCard(dynamic n) {
    final mahasiswa = n['mahasiswa']?['user']?['nama'];
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F2FE),
          child: Text('${n['grade'] ?? '-'}', style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        ),
        title: Text(n['matkul']?['nama'] ?? 'Mata Kuliah', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text([
          if (mahasiswa != null) mahasiswa,
          'Semester ${n['semester']}',
        ].join(' - ')),
        trailing: _canEdit
            ? IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF1565C0)),
                onPressed: () => _showEditDialog(n),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${n['nilai_akhir'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1565C0))),
                  const Text('Nilai', style: TextStyle(fontSize: 11)),
                ],
              ),
      ),
    );
  }

  void _showEditDialog(dynamic nilai) {
    final controller = TextEditingController(text: '${nilai['nilai_akhir'] ?? 0}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nilai'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nilai akhir', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final score = int.tryParse(controller.text) ?? 0;
              await ApiService.updateNilai(nilai['id'], {'nilai_akhir': score});
              if (!mounted) return;
              Navigator.pop(context);
              await _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai berhasil diperbarui')));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _chart(String title, List<dynamic> data, String keyField) {
    if (data.isEmpty) return const SizedBox.shrink();
    final spots = data.asMap().entries.map((e) {
      final val = double.tryParse('${e.value['rata_rata']}') ?? 0;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) return Text('${data[idx][keyField]}', style: const TextStyle(fontSize: 10));
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF1565C0),
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: const Color(0xFF1565C0).withOpacity(0.14)),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
