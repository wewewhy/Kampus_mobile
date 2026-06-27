<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Berita;

class BeritaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Menyisipkan data dummy ke tabel beritas
        Berita::create([
            'judul' => 'Kunjungan Industri Mahasiswa Informatika',
            'isi' => 'Mahasiswa program studi Informatika melakukan kunjungan industri ke perusahaan teknologi besar untuk melihat implementasi cloud computing dan machine learning secara nyata.',
            'tag' => 'Pendidikan',
            'tanggal' => '2026-06-07',
        ]);

        Berita::create([
            'judul' => 'Workshop Framework Flutter dan Laravel',
            'isi' => 'Himpunan mahasiswa mengadakan workshop intensif mengenai pembuatan aplikasi mobile multi-platform menggunakan Flutter dan backend API Laravel Sanctum.',
            'tag' => 'Workshop',
            'tanggal' => '2026-06-08',
        ]);

        $this->command->info('Data dummy berita berhasil dibuat!');
    }
}