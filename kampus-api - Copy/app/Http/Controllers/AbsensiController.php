<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AbsensiController extends Controller
{
    public function index(Request $request) {
    // Ambil absensi user yang login
    $data = \App\Models\Absensi::where('mahasiswa_id', $request->user()->mahasiswa->id)->get();
    return response()->json($data);
}
}
