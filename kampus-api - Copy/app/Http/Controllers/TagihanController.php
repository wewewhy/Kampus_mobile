<?php

namespace App\Http\Controllers;

use App\Models\Tagihan;
use Illuminate\Http\Request;

class TagihanController extends Controller
{
    public function index(Request $request)
    {
        // Mengambil semua tagihan milik mahasiswa yang login
        $tagihan = Tagihan::where('mahasiswa_id', $request->user()->mahasiswa->id)->get();
        
        return response()->json([
            'status' => 'success',
            'data' => $tagihan
        ], 200);
    }
}