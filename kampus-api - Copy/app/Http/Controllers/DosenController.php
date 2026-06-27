<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class DosenController extends Controller
{
    // 1. Ambil daftar kelas yang diajar oleh Dosen yang sedang login
public function getKelasDosen()
{
    $dosenId = auth()->user()->id; // Mengambil ID dari token Sanctum
    
    $kelas = Kelas::where('dosen_id', $dosenId)->get();
    
    return response()->json([
        'status' => 'success',
        'data' => $kelas
    ]);
}

// 2. Ambil daftar mahasiswa berdasarkan kelas yang dipilih
public function getMahasiswaByKelas($kelas_id)
{
    $dosenId = auth()->user()->id;

    // Keamanan: Pastikan kelas ini memang milik dosen yang login
    $kelas = Kelas::where('id', $kelas_id)->where('dosen_id', $dosenId)->first();
    
    if (!$kelas) {
        return response()->json(['message' => 'Anda tidak mengajar di kelas ini!'], 403);
    }

    // Ambil mahasiswa yang terdaftar di kelas ini (melalui relasi tabel pivot KRS)
    $mahasiswa = $kelas->mahasiswas; 

    return response()->json([
        'status' => 'success',
        'data' => $mahasiswa
    ]);
}