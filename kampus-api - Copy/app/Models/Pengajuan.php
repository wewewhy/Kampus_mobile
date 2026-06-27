<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Pengajuan extends Model {
    protected $fillable = ['mahasiswa_id', 'jenis', 'judul', 'abstrak', 'bidang_studi', 'dosen_usulan_1', 'dosen_usulan_2', 'dosen_pembimbing', 'status', 'keterangan'];
    
    public function mahasiswa() { return $this->belongsTo(Mahasiswa::class); }
    public function dosenUsulan1() { return $this->belongsTo(Dosen::class, 'dosen_usulan_1'); }
    public function dosenPembimbing() { return $this->belongsTo(Dosen::class, 'dosen_pembimbing'); }
}
