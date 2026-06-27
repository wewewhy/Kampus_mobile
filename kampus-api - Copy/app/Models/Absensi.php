<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    protected $fillable = [
        'jadwal_id',
        'mahasiswa_id',
        'pertemuan_ke',
        'status',
        'tanggal',
    ];

    // Relasi ke jadwal
    public function jadwal()
    {
        return $this->belongsTo(Jadwal::class);
    }

    // Relasi ke mahasiswa
    public function mahasiswa() 
    { 
        return $this->belongsTo(Mahasiswa::class); 
    }
} // <--- KURUNG TUTUP INI HARUS BERADA DI PALING AKHIR FILE