<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MatkulController extends Controller
{
    public function index() {
    $data = \App\Models\Matkul::all();
    return response()->json($data);
}
}
