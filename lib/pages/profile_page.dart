import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _primary = Color(0xFF1D4ED8);
  static const _teal = Color(0xFF0F766E);

  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _kelasCtrl = TextEditingController();
  final _jurusanCtrl = TextEditingController();
  final _picker = ImagePicker();

  Map<String, dynamic>? _user;
  List<dynamic> _mahasiswaList = [];
  String? _avatarPath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getUser();
    final mahasiswaList =
        user?['role'] == 'admin' ? await ApiService.getMahasiswaUsers() : [];
    if (!mounted) return;
    setState(() {
      _user = user;
      _mahasiswaList = mahasiswaList;
      _avatarPath = user?['avatar'];
      _namaCtrl.text = user?['nama'] ?? '';
      _nimCtrl.text = user?['nomor_induk'] ?? '';
      _kelasCtrl.text = user?['kelas'] ?? user?['mahasiswa']?['kelas'] ?? '';
      _jurusanCtrl.text =
          user?['jurusan'] ?? user?['mahasiswa']?['jurusan'] ?? '';
      _loading = false;
    });
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1000,
    );
    if (image == null) return;
    setState(() => _avatarPath = image.path);
  }

  Future<void> _save() async {
    final role = _user?['role'];
    final isMahasiswa = role == 'mahasiswa';

    if (!isMahasiswa &&
        (_namaCtrl.text.trim().isEmpty || _nimCtrl.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan NIM wajib diisi')),
      );
      return;
    }

    setState(() => _saving = true);
    final updated = await ApiService.updateProfile(
      isMahasiswa
          ? {'avatar': _avatarPath}
          : {
              'nama': _namaCtrl.text.trim(),
              'nomor_induk': _nimCtrl.text.trim(),
              'kelas': _kelasCtrl.text.trim(),
              'jurusan': _jurusanCtrl.text.trim(),
              'avatar': _avatarPath,
            },
    );

    if (!mounted) return;
    setState(() {
      _user = updated ?? _user;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMahasiswa
              ? 'Foto profil berhasil diperbarui'
              : 'Profil berhasil diperbarui',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final isMahasiswa = _user?['role'] == 'mahasiswa';
    final canEditBiodata = !isMahasiswa;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primary, _teal]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _avatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?['nama'] ?? 'Mahasiswa',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMahasiswa
                            ? '${_user?['nomor_induk'] ?? '-'} - ${_user?['kelas'] ?? _user?['mahasiswa']?['kelas'] ?? '-'}'
                            : (_user?['role'] ?? '').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.86),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMahasiswa
                      ? 'Biodata Mahasiswa'
                      : 'Data Profil Pengguna',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isMahasiswa
                      ? 'Data akademik hanya dapat diubah oleh admin.'
                      : 'Admin dapat memperbarui data profil lengkap.',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                _field(
                  _namaCtrl,
                  'Nama lengkap',
                  Icons.badge_outlined,
                  readOnly: !canEditBiodata,
                ),
                const SizedBox(height: 12),
                _field(
                  _nimCtrl,
                  'NIM',
                  Icons.credit_card_outlined,
                  readOnly: !canEditBiodata,
                ),
                const SizedBox(height: 12),
                _field(
                  _kelasCtrl,
                  'Kelas',
                  Icons.groups_2_outlined,
                  readOnly: !canEditBiodata,
                ),
                const SizedBox(height: 12),
                _field(
                  _jurusanCtrl,
                  'Jurusan',
                  Icons.school_outlined,
                  readOnly: !canEditBiodata,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _saving
                          ? 'Menyimpan...'
                          : isMahasiswa
                              ? 'Simpan Foto Profil'
                              : 'Simpan Profil',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_user?['role'] == 'admin') ...[
            const SizedBox(height: 16),
            _adminMahasiswaPanel(),
          ],
        ],
      ),
    );
  }

  Widget _avatar() {
    final hasAvatar = _avatarPath != null && _avatarPath!.trim().isNotEmpty;
    return Stack(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: Colors.white,
          backgroundImage: hasAvatar ? FileImage(File(_avatarPath!)) : null,
          child: hasAvatar
              ? null
              : const Icon(Icons.person, size: 38, color: _primary),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: _pickAvatar,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withOpacity(0.25)),
              ),
              child: const Icon(Icons.photo_camera_outlined,
                  size: 18, color: _primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFF8FAFC) : null,
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline, size: 18, color: Colors.black38)
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _adminMahasiswaPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelola Biodata Mahasiswa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Admin dapat memperbarui nama, NIM, kelas, dan jurusan mahasiswa.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          if (_mahasiswaList.isEmpty)
            const Text('Belum ada data mahasiswa.')
          else
            ..._mahasiswaList.map(
              (item) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(item['nama'] ?? '-'),
                  subtitle: Text(
                    '${item['nomor_induk'] ?? '-'} - ${item['kelas'] ?? item['mahasiswa']?['kelas'] ?? '-'} - ${item['jurusan'] ?? item['mahasiswa']?['jurusan'] ?? '-'}',
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _showEditMahasiswaSheet(
                    Map<String, dynamic>.from(item),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditMahasiswaSheet(Map<String, dynamic> mahasiswa) {
    final namaCtrl = TextEditingController(text: mahasiswa['nama'] ?? '');
    final nimCtrl =
        TextEditingController(text: mahasiswa['nomor_induk'] ?? '');
    final kelasCtrl = TextEditingController(
      text: mahasiswa['kelas'] ?? mahasiswa['mahasiswa']?['kelas'] ?? '',
    );
    final jurusanCtrl = TextEditingController(
      text: mahasiswa['jurusan'] ?? mahasiswa['mahasiswa']?['jurusan'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
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
                'Edit Biodata Mahasiswa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _sheetField(namaCtrl, 'Nama lengkap', Icons.badge_outlined),
              const SizedBox(height: 12),
              _sheetField(nimCtrl, 'NIM', Icons.credit_card_outlined),
              const SizedBox(height: 12),
              _sheetField(kelasCtrl, 'Kelas', Icons.groups_2_outlined),
              const SizedBox(height: 12),
              _sheetField(jurusanCtrl, 'Jurusan', Icons.school_outlined),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await ApiService.updateUserProfileById(
                      mahasiswa['id'],
                      {
                        'nama': namaCtrl.text.trim(),
                        'nomor_induk': nimCtrl.text.trim(),
                        'kelas': kelasCtrl.text.trim(),
                        'jurusan': jurusanCtrl.text.trim(),
                      },
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          updated == null
                              ? 'Biodata gagal diperbarui'
                              : 'Biodata mahasiswa berhasil diperbarui',
                        ),
                      ),
                    );
                    await _loadUser();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Biodata'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      namaCtrl.dispose();
      nimCtrl.dispose();
      kelasCtrl.dispose();
      jurusanCtrl.dispose();
    });
  }

  Widget _sheetField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _kelasCtrl.dispose();
    _jurusanCtrl.dispose();
    super.dispose();
  }
}
