<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class KrsController extends Controller
{
    public function index(Request $request) {
    $data = \App\Models\Krs::where('mahasiswa_id', $request->user()->mahasiswa->id)->get();
    return response()->json($data);
}
}
