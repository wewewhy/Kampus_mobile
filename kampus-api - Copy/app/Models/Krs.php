<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Krs extends Model {
    protected $table = 'krs';
    protected $fillable = ['mahasiswa_id', 'semester', 'tahun_akademik', 'status'];
    
    public function items() { return $this->hasMany(KrsItem::class); }
}