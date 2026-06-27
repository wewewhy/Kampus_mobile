<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Jadwal; // Pastikan Model Jadwal sudah ada

class JadwalController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        // Contoh: Ambil jadwal berdasarkan relasi user (mahasiswa atau dosen)
        if ($user->role === 'mahasiswa') {
            $jadwal = Jadwal::where('mahasiswa_id', $user->mahasiswa->id)->get();
        } elseif ($user->role === 'dosen') {
            $jadwal = Jadwal::where('dosen_id', $user->dosen->id)->get();
        } else {
            return response()->json(['message' => 'Role tidak dikenali'], 403);
        }

        return response()->json([
            'status' => 'success',
            'data' => $jadwal
        ], 200);
    }
}