<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Mahasiswa extends Model {
    protected $fillable = ['user_id', 'jurusan', 'angkatan', 'semester_aktif', 'ipk'];
    
    public function user() { return $this->belongsTo(User::class); }
    public function nilais() { return $this->hasMany(Nilai::class); }
    public function pengajuans() { return $this->hasMany(Pengajuan::class); }
    public function tagihans() { return $this->hasMany(Tagihan::class); }
    public function krs() { return $this->hasMany(Krs::class); }
}