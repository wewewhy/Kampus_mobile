<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class KrsItem extends Model {
    protected $fillable = ['krs_id', 'matkul_id'];
    
    public function matkul() { return $this->belongsTo(Matkul::class); }
}