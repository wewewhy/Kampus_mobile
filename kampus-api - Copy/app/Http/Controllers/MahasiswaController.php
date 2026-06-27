<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MahasiswaController extends Controller
{
    public function index() {
    $data = \App\Models\Mahasiswa::all();
    return response()->json($data);
}
}
