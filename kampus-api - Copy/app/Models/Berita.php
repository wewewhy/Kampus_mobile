<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Berita extends Model
{
    use HasFactory;

    // Pastikan semua kolom yang ada di database/migrasi terdaftar di sini
    protected $fillable = ['judul', 'isi', 'tag', 'tanggal'];
}