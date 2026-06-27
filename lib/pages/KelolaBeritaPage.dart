import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'form_tambah_berita_page.dart';

class KelolaBeritaPage extends StatefulWidget {
  const KelolaBeritaPage({super.key});

  @override
  State<KelolaBeritaPage> createState() => _KelolaBeritaPageState();
}

class _KelolaBeritaPageState extends State<KelolaBeritaPage> {
  List<dynamic> _berita = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBerita();
  }

  // Fungsi mengambil data berita
  Future<void> _fetchBerita() async {
    setState(() => _isLoading = true);

    final data = await ApiService.getBerita();

    setState(() {
      _berita = data;
      _isLoading = false;
    });
  }

  // Fungsi menghapus berita dengan konfirmasi dialog
  Future<void> _hapusBerita(int id) async {
    bool berhasil = await ApiService.deleteBerita(id);
    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil dihapus')),
      );
      _fetchBerita(); // Refresh data setelah menghapus
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus berita')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Berita")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke form tambah, lalu refresh data jika kembali
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormTambahBeritaPage()),
          );
          _fetchBerita();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Animasi Loading
          : _berita.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada berita.\nPastikan server aktif & cek Debug Console.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _berita.length,
                  itemBuilder: (context, index) {
                    final item = _berita[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading:
                            const Icon(Icons.newspaper, color: Colors.blue),
                        title: Text(
                          item['judul'] ?? 'Tanpa Judul',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item['tanggal'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Menampilkan dialog konfirmasi hapus
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Berita'),
                                content: const Text(
                                    'Apakah Anda yakin ingin menghapus berita ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _hapusBerita(item['id']);
                                    },
                                    child: const Text('Hapus',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
