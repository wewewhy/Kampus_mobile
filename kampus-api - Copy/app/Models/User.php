<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory; // Tambah baris ini jika hilang
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable; // Tambah baris ini jika hilang
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable {
    // Pastikan 3 trait ini tertulis lengkap di dalam class!
    use HasApiTokens, HasFactory, Notifiable; 

    protected $fillable = ['nama', 'email', 'password', 'role', 'nomor_induk', 'avatar'];
    protected $hidden = ['password', 'rememberToken'];
    
    public function mahasiswa() { return $this->hasOne(Mahasiswa::class); }
    public function dosen() { return $this->hasOne(Dosen::class); }
}