<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Dosen extends Model {
    protected $fillable = ['user_id', 'nidn', 'bidang_keahlian', 'kuota_bimbingan', 'jumlah_bimbingan_aktif'];
    
    public function user() { return $this->belongsTo(User::class); }
    public function matkuls() { return $this->hasMany(Matkul::class); }
    public function jadwals() { return $this->hasMany(Jadwal::class); }
}