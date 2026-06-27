<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Nilai extends Model
{
    protected $fillable = [
        'mahasiswa_id',
        'matkul_id',
        'dosen_id',
        'uts',
        'uas',
        'tugas',
        'nilai_akhir',
        'grade',
        'semester'
    ];

    // Relasi ke data Mahasiswa
    public function mahasiswa()
    {
        return $this->belongsTo(Mahasiswa::class);
    }

    // Relasi ke data Mata Kuliah
    public function matkul()
    {
        return $this->belongsTo(Matkul::class);
    }

    // Relasi ke data Dosen
    public function dosen()
    {
        return $this->belongsTo(Dosen::class);
    }
}