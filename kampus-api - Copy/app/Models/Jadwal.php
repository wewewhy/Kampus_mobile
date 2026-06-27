<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Jadwal extends Model {
    protected $fillable = ['dosen_id', 'matkul_id', 'hari', 'jam_mulai', 'jam_selesai', 'ruangan', 'kelas', 'semester'];
    
    public function dosen() { return $this->belongsTo(Dosen::class); }
    public function matkul() { return $this->belongsTo(Matkul::class); }
    public function absensis() { return $this->hasMany(Absensi::class); }
}