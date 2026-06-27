<?php
namespace App\Http\Controllers;
use App\Models\Dosen;
use App\Models\Pengajuan;
use Illuminate\Http\Request;

class PengajuanController extends Controller {
    public function index(Request $request) {
        $user = $request->user();
        
        if ($user->role === 'mahasiswa') {
            $pengajuans = Pengajuan::with(['dosenUsulan1.user', 'dosenPembimbing.user'])
                ->where('mahasiswa_id', $user->mahasiswa->id)
                ->get();
        } elseif ($user->role === 'dosen') {
            $pengajuans = Pengajuan::with(['mahasiswa.user'])
                ->where('dosen_usulan_1', $user->dosen->id)
                ->orWhere('dosen_pembimbing', $user->dosen->id)
                ->get();
        } else {
            $pengajuans = Pengajuan::with(['mahasiswa.user', 'dosenUsulan1.user'])->get();
        }
        
        return response()->json($pengajuans);
    }

    public function store(Request $request) {
        $request->validate([
            'jenis' => 'nullable|string|max:100',
            'judul' => 'required|string|max:255',
            'abstrak' => 'nullable|string',
            'bidang_studi' => 'nullable|string',
            'dosen_usulan_1' => 'required|exists:dosens,id',
            'dosen_usulan_2' => 'nullable|exists:dosens,id'
        ]);

        $user = $request->user();
        if ($user->role !== 'mahasiswa') {
            return response()->json(['message' => 'Hanya mahasiswa yang bisa mengajukan'], 403);
        }

        // Cek kuota dosen
        $dosen = Dosen::find($request->dosen_usulan_1);
        if ($dosen->jumlah_bimbingan_aktif >= $dosen->kuota_bimbingan) {
            return response()->json(['message' => 'Dosen yang dipilih sudah penuh kuota'], 400);
        }

        $pengajuan = Pengajuan::create([
            'mahasiswa_id' => $user->mahasiswa->id,
            'jenis' => $request->jenis ?? 'Tugas Akhir',
            'judul' => $request->judul,
            'abstrak' => $request->abstrak,
            'bidang_studi' => $request->bidang_studi,
            'dosen_usulan_1' => $request->dosen_usulan_1,
            'dosen_usulan_2' => $request->dosen_usulan_2,
            'status' => 'menunggu'
        ]);

        return response()->json(['message' => 'Pengajuan berhasil dibuat', 'data' => $pengajuan], 201);
    }

    public function updateStatus(Request $request, $id) {
        $request->validate([
            'status' => 'required|in:diterima,ditolak',
            'keterangan' => 'nullable|string'
        ]);

        $pengajuan = Pengajuan::findOrFail($id);
        $pengajuan->status = $request->status;
        $pengajuan->keterangan = $request->keterangan;
        
        if ($request->status === 'diterima') {
            $pengajuan->dosen_pembimbing = $pengajuan->dosen_usulan_1;
            // Update kuota
            $dosen = Dosen::find($pengajuan->dosen_usulan_1);
            $dosen->increment('jumlah_bimbingan_aktif');
        }
        
        $pengajuan->save();

        return response()->json(['message' => 'Status pengajuan diperbarui']);
    }

    public function dosenList() {
        $dosens = Dosen::with('user')->get()->map(function($d) {
            return [
                'id' => $d->id,
                'nama' => $d->user->nama,
                'nidn' => $d->nidn,
                'bidang_keahlian' => $d->bidang_keahlian,
                'kuota' => $d->kuota_bimbingan,
                'sisa_kuota' => $d->kuota_bimbingan - $d->jumlah_bimbingan_aktif
            ];
        });
        return response()->json($dosens);
    }
}
