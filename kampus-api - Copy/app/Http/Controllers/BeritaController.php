<?php

namespace App\Http\Controllers;

use App\Models\Berita;
use Illuminate\Http\Request;

class BeritaController extends Controller
{
    // 1. READ: Melihat daftar berita (Bisa diakses semua role)
    public function index()
    {
        $beritas = Berita::orderBy('tanggal', 'desc')->get();
        return response()->json([
            'status' => 'success',
            'data' => $beritas
        ], 200);
    }

    // 2. CREATE: Menambah berita baru (Hanya Admin)
    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:255',
            'isi' => 'required|string',
            'tag' => 'required|string',
            'tanggal' => 'required|date',
        ]);

        $berita = Berita::create([
            'judul' => $request->judul,
            'isi' => $request->isi,
            'tag' => $request->tag,
            'tanggal' => $request->tanggal,
        ]);

        return response()->json([
            'message' => 'Berita berhasil ditambahkan',
            'data' => $berita
        ], 201);
    }

    // 3. UPDATE: Mengedit berita yang sudah ada (Hanya Admin)
    public function update(Request $request, $id)
    {
        // Menggunakan 'sometimes' agar admin tidak harus mengupdate semua kolom
        $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'isi' => 'sometimes|required|string',
            'tag' => 'sometimes|required|string',
            'tanggal' => 'sometimes|required|date',
        ]);

        $berita = Berita::find($id);

        if (!$berita) {
            return response()->json(['message' => 'Berita tidak ditemukan!'], 404);
        }

        $berita->update($request->only(['judul', 'isi', 'tag', 'tanggal']));

        return response()->json([
            'message' => 'Berita berhasil diperbarui',
            'data' => $berita
        ], 200);
    }

    // 4. DELETE: Menghapus berita (Hanya Admin)
    public function destroy($id)
    {
        $berita = Berita::find($id);

        if (!$berita) {
            return response()->json(['message' => 'Berita tidak ditemukan!'], 404);
        }

        $berita->delete();

        return response()->json([
            'message' => 'Berita berhasil dihapus'
        ], 200);
    }
}