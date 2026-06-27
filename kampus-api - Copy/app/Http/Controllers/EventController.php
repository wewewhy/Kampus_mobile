<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class EventController extends Controller 
{
    /**
     * Tampilkan semua event aktif (untuk Dashboard/Running Text di Mobile)
     */
    public function index() 
    {
        $events = Event::where('status', 'aktif')
            ->orderBy('tanggal_event', 'asc')
            ->get();

        return response()->json($events, 200);
    }

    /**
     * Tampilkan detail satu event berdasarkan ID
     */
    public function show($id) 
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'status' => 'error',
                'message' => 'Event tidak ditemukan'
            ], 404);
        }

        return response()->json($event, 200);
    }

    /**
     * Tambah Event Baru (Khusus Admin)
     */
    public function store(Request $request) 
    {
        $validator = Validator::make($request->all(), [
            'judul'         => 'required|string|max:255',
            'deskripsi'     => 'nullable|string',
            'tipe'          => 'required|in:gratis,berbayar',
            'harga'         => 'required_if:tipe,berbayar|numeric|min:0',
            'tanggal_event' => 'required|date',
            'poster'        => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048', // Batas 2MB
            'lokasi'        => 'nullable|string|max:255',
            'status'        => 'nullable|in:aktif,nonaktif',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'validation_error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->except('poster');

        // Proses upload file poster jika ada
        if ($request->hasFile('poster')) {
            $path = $request->file('poster')->store('events', 'public');
            $data['poster_url'] = asset('storage/' . $path);
        }

        $event = Event::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Event berhasil ditambahkan',
            'data'    => $event
        ], 201);
    }

    /**
     * Perbarui Data Event (Khusus Admin)
     */
    public function update(Request $request, $id) 
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'status' => 'error',
                'message' => 'Event tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'judul'         => 'sometimes|required|string|max:255',
            'deskripsi'     => 'nullable|string',
            'tipe'          => 'sometimes|required|in:gratis,berbayar',
            'harga'         => 'required_if:tipe,berbayar|numeric|min:0',
            'tanggal_event' => 'sometimes|required|date',
            'poster'        => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'lokasi'        => 'nullable|string|max:255',
            'status'        => 'sometimes|required|in:aktif,nonaktif',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'validation_error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->except('poster');

        // Jika ada file poster baru yang diupload
        if ($request->hasFile('poster')) {
            // Hapus poster lama dari folder storage jika ada
            if ($event->poster_url) {
                $oldPath = str_replace(asset('storage/'), '', $event->poster_url);
                Storage::disk('public')->delete($oldPath);
            }

            // Simpan poster baru
            $path = $request->file('poster')->store('events', 'public');
            $data['poster_url'] = asset('storage/' . $path);
        }

        $event->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Event berhasil diperbarui',
            'data'    => $event
        ], 200);
    }

    /**
     * Hapus Event (Khusus Admin)
     */
    public function destroy($id) 
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'status' => 'error',
                'message' => 'Event tidak ditemukan'
            ], 404);
        }

        // Hapus file gambar poster dari storage agar tidak memenuhi penyimpanan lokal
        if ($event->poster_url) {
            $path = str_replace(asset('storage/'), '', $event->poster_url);
            Storage::disk('public')->delete($path);
        }

        $event->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Event berhasil dihapus'
        ], 200);
    }
}