<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Matkul extends Model {
    protected $fillable = ['kode', 'nama', 'sks', 'semester_wajib', 'dosen_id'];
    
    public function dosen() { return $this->belongsTo(Dosen::class); }
    public function jadwals() { return $this->hasMany(Jadwal::class); }
}