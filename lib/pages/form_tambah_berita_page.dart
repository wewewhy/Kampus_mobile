import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FormTambahBeritaPage extends StatefulWidget {
  const FormTambahBeritaPage({super.key});

  @override
  State<FormTambahBeritaPage> createState() => _FormTambahBeritaPageState();
}

class _FormTambahBeritaPageState extends State<FormTambahBeritaPage> {
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _tagController = TextEditingController();
  final _tanggalController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _simpanBerita() async {
    if (_judulController.text.isEmpty || _tanggalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul dan Tanggal wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Menyiapkan data
      final dataBerita = {
        'judul': _judulController.text,
        'isi': _isiController.text,
        'tag': _tagController.text,
        'tanggal': _tanggalController.text,
      };

      print("DEBUG: Mengirim data: $dataBerita"); // CEK DI CONSOLE

      final success = await ApiService.createBerita(dataBerita);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context);
      } else {
        // JIKA GAGAL, KITA TAMPILKAN SNACKBAR
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal: Pastikan role Anda Admin dan data valid!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Berita")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                      controller: _judulController,
                      decoration: const InputDecoration(labelText: 'Judul')),
                  TextField(
                      controller: _isiController,
                      decoration:
                          const InputDecoration(labelText: 'Isi Berita')),
                  TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(labelText: 'Tag')),
                  TextFormField(
                    controller: _tanggalController,
                    decoration: const InputDecoration(
                        labelText: 'Tanggal (Klik kalender)',
                        suffixIcon: Icon(Icons.calendar_today)),
                    readOnly: true,
                    onTap: () => _pilihTanggal(context),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                      onPressed: _simpanBerita,
                      child: const Text('Simpan Berita')),
                ],
              ),
            ),
    );
  }
}
