<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Dosen;
use App\Models\Mahasiswa;
use App\Models\Matkul;
use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\KrsItem;
use App\Models\Absensi;
use App\Models\Nilai;
use App\Models\Pengajuan;
use App\Models\Tagihan;
use App\Models\Event;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder {
    public function run(): void {
        
        // ==========================================
        // 1. SEEDER USER & ROLE (Admin, Dosen, Mahasiswa)
        // ==========================================
        
        // Admin
        User::updateOrCreate(
            ['email' => 'admin@kampus.ac.id'],
            [
                'nama' => 'Admin Pusat Akademik',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'nomor_induk' => 'ADM001'
            ]
        );

        // Dosen 1
        $uDosen1 = User::updateOrCreate(
            ['email' => 'ahmad@kampus.ac.id'],
            [
                'nama' => 'Dr. Ahmad Fauzi, M.T.',
                'password' => Hash::make('password123'),
                'role' => 'dosen',
                'nomor_induk' => 'D001'
            ]
        );
        $dosen1 = Dosen::updateOrCreate(
            ['user_id' => $uDosen1->id],
            [
                'nidn' => '0011223301',
                'bidang_keahlian' => 'Machine Learning & AI',
                'kuota_bimbingan' => 10,
                'jumlah_bimbingan_aktif' => 1
            ]
        );

        // Dosen 2
        $uDosen2 = User::updateOrCreate(
            ['email' => 'budi@kampus.ac.id'],
            [
                'nama' => 'Budi Setiawan, M.Kom.',
                'password' => Hash::make('dosen123'),
                'role' => 'dosen',
                'nomor_induk' => 'D002'
            ]
        );
        $dosen2 = Dosen::updateOrCreate(
            ['user_id' => $uDosen2->id],
            [
                'nidn' => '0011223302',
                'bidang_keahlian' => 'Web & Mobile Development',
                'kuota_bimbingan' => 8,
                'jumlah_bimbingan_aktif' => 0
            ]
        );

        // Mahasiswa 1
        $uMhs1 = User::updateOrCreate(
            ['email' => 'dzakwan@student.kampus.ac.id'],
            [
                'nama' => 'Dzakwan Hanif',
                'password' => Hash::make('mhs123'),
                'role' => 'mahasiswa',
                'nomor_induk' => '20220001'
            ]
        );
        $mhs1 = Mahasiswa::updateOrCreate(
            ['user_id' => $uMhs1->id],
            [
                'jurusan' => 'Teknik Informatika',
                'angkatan' => 2022,
                'semester_aktif' => 4,
                'ipk' => 3.85
            ]
        );

        // ==========================================
        // 2. SEEDER MATA KULIAH (Matkul)
        // ==========================================
        $matkul1 = Matkul::updateOrCreate(
            ['kode' => 'IF-201'],
            [
                'nama' => 'Pemrograman Aplikasi Mobile',
                'sks' => 4,
                'semester_wajib' => 4,
                'dosen_id' => $dosen2->id
            ]
        );

        $matkul2 = Matkul::updateOrCreate(
            ['kode' => 'IF-302'],
            [
                'nama' => 'Kecerdasan Buatan (AI)',
                'sks' => 3,
                'semester_wajib' => 4,
                'dosen_id' => $dosen1->id
            ]
        );

        // ==========================================
        // 3. SEEDER JADWAL KULIAH
        // ==========================================
        $jadwal1 = Jadwal::updateOrCreate(
            ['matkul_id' => $matkul1->id, 'kelas' => 'TI-4A'],
            [
                'dosen_id' => $dosen2->id,
                'hari' => 'Senin',
                'jam_mulai' => '08:00:00',
                'jam_selesai' => '11:30:00',
                'ruangan' => 'Lab Komputer 3',
                'semester' => 4
            ]
        );

        $jadwal2 = Jadwal::updateOrCreate(
            ['matkul_id' => $matkul2->id, 'kelas' => 'TI-4A'],
            [
                'dosen_id' => $dosen1->id,
                'hari' => 'Rabu',
                'jam_mulai' => '13:00:00',
                'jam_selesai' => '15:30:00',
                'ruangan' => 'Ruang Teori 202',
                'semester' => 4
            ]
        );

        // ==========================================
        // 4. SEEDER KRS & KRS ITEMS
        // ==========================================
        $krs = Krs::updateOrCreate(
            ['mahasiswa_id' => $mhs1->id, 'semester' => 4],
            [
                'tahun_akademik' => '2025/2026',
                'status' => 'disetujui'
            ]
        );

        KrsItem::updateOrCreate(['krs_id' => $krs->id, 'matkul_id' => $matkul1->id]);
        KrsItem::updateOrCreate(['krs_id' => $krs->id, 'matkul_id' => $matkul2->id]);

        // ==========================================
        // 5. SEEDER ABSENSI
        // ==========================================
        Absensi::updateOrCreate(
            ['jadwal_id' => $jadwal1->id, 'mahasiswa_id' => $mhs1->id, 'pertemuan_ke' => 1],
            [
                'dosen_id' => $dosen2->id,
                'status' => 'hadir',
                'tanggal' => '2026-06-01'
            ]
        );

        Absensi::updateOrCreate(
            ['jadwal_id' => $jadwal2->id, 'mahasiswa_id' => $mhs1->id, 'pertemuan_ke' => 1],
            [
                'dosen_id' => $dosen1->id,
                'status' => 'izin',
                'tanggal' => '2026-06-03'
            ]
        );

        // ==========================================
        // 6. SEEDER NILAI AKADEMIK
        // ==========================================
        Nilai::updateOrCreate(
            ['mahasiswa_id' => $mhs1->id, 'matkul_id' => $matkul1->id],
            [
                'dosen_id' => $dosen2->id,
                'uts' => 85.00,
                'uas' => 90.00,
                'tugas' => 88.00,
                'nilai_akhir' => 88.20,
                'grade' => 'A',
                'semester' => 4
            ]
        );

        // ==========================================
        // 7. SEEDER PENGAJUAN SKRIPSI / TUGAS AKHIR
        // ==========================================
        Pengajuan::updateOrCreate(
            ['mahasiswa_id' => $mhs1->id, 'judul' => 'Pengembangan Aplikasi Dashboard Kampus Berbasis Mobile Menggunakan REST API Laravel'],
            [
                'abstrak' => 'Abstrak penelitian mengenai efisiensi sistem mobile dashboard akademik...',
                'bidang_studi' => 'Mobile Application',
                'dosen_usulan_1' => $dosen2->id,
                'dosen_usulan_2' => $dosen1->id,
                'dosen_pembimbing' => $dosen2->id,
                'status' => 'diterima',
                'keterangan' => 'Judul disetujui, langsung lanjutkan ke Bab 1.'
            ]
        );

        // ==========================================
        // 8. SEEDER TAGIHAN KEUANGAN
        // ==========================================
        Tagihan::updateOrCreate(
            ['mahasiswa_id' => $mhs1->id, 'jenis_tagihan' => 'SPP Tetap Semester 4'],
            [
                'nominal' => 3500000,
                'semester' => 4,
                'deadline' => '2026-07-01',
                'status' => 'belum',
                'bukti_bayar' => null
            ]
        );

        Tagihan::updateOrCreate(
            ['mahasiswa_id' => $mhs1->id, 'jenis_tagihan' => 'Biaya Praktikum Mobile'],
            [
                'nominal' => 500000,
                'semester' => 4,
                'deadline' => '2026-06-15',
                'status' => 'lunas',
                'bukti_bayar' => 'bukti_transfer_spp.png'
            ]
        );

        // ==========================================
        // 9. SEEDER EVENTS (Untuk Running Marquee Text)
        // ==========================================
        Event::updateOrCreate(
            ['judul' => 'Seminar Nasional: Tren AI & Machine Learning 2026'],
            [
                'deskripsi' => 'Seminar teknologi mendatangkan pembicara internasional.',
                'tipe' => 'gratis',
                'harga' => 0,
                'tanggal_event' => '2026-06-20',
                'poster_url' => 'event1.png',
                'lokasi' => 'Aula Utama Kampus',
                'status' => 'aktif'
            ]
        );

        Event::updateOrCreate(
            ['judul' => 'Workshop UI/UX Clean Design for Mobile App'],
            [
                'deskripsi' => 'Belajar mendesain UI aplikasi mobile minimalis dan interaktif.',
                'tipe' => 'berbayar',
                'harga' => 75000,
                'tanggal_event' => '2026-07-05',
                'poster_url' => 'event2.png',
                'lokasi' => 'Gedung Inkubator Lt. 2',
                'status' => 'aktif'
            ]
        );
        
    }
}