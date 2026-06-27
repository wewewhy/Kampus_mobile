<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Tagihan extends Model {
    protected $fillable = ['mahasiswa_id', 'jenis_tagihan', 'nominal', 'semester', 'deadline', 'status', 'bukti_bayar'];
}