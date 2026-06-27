<?php

namespace App\Http\Controllers;

use App\Models\Nilai;
use App\Models\Matkul;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NilaiController extends Controller 
{
    /**
     * Mengambil daftar nilai sesuai role user
     */
    public function index(Request $request) 
    {
        $user = $request->user();
        
        if ($user->role === 'mahasiswa') {
            $nilais = Nilai::with('matkul')
                ->where('mahasiswa_id', $user->mahasiswa->id)
                ->get();
        } elseif ($user->role === 'dosen') {
            $nilais = Nilai::with(['mahasiswa.user', 'matkul'])
                ->where('dosen_id', $user->dosen->id)
                ->get();
        } else {
            $nilais = Nilai::with(['mahasiswa.user', 'matkul', 'dosen.user'])->get();
        }
        
        return response()->json($nilais);
    }

    /**
     * Input nilai oleh Dosen
     */
    public function store(Request $request) 
    {
        $request->validate([
            'mahasiswa_id' => 'required|exists:mahasiswas,id',
            'matkul_id' => 'required|exists:matkuls,id',
            'uts' => 'nullable|numeric',
            'uas' => 'nullable|numeric',
            'tugas' => 'nullable|numeric',
            'semester' => 'required|integer'
        ]);

        $user = $request->user();
        
        // Proteksi: Pastikan user adalah dosen
        if ($user->role !== 'dosen') {
            return response()->json(['message' => 'Hanya dosen yang berhak menginput nilai.'], 403);
        }

        $dosenId = $user->dosen->id;

        // Pengecekan Keamanan: Apakah dosen ini benar mengampu matkul tersebut?
        $isAuthorized = Matkul::where('id', $request->matkul_id)
                              ->where('dosen_id', $dosenId)
                              ->exists();

        if (!$isAuthorized) {
            return response()->json(['message' => 'Anda tidak mengampu mata kuliah ini!'], 403);
        }

        // Kalkulasi nilai
        $na = (($request->uts ?? 0) + ($request->uas ?? 0) + ($request->tugas ?? 0)) / 3;
        
        $grade = 'E';
        if ($na >= 85) $grade = 'A';
        elseif ($na >= 75) $grade = 'B';
        elseif ($na >= 65) $grade = 'C';
        elseif ($na >= 50) $grade = 'D';

        // Simpan ke database
        $nilai = Nilai::updateOrCreate(
            [
                'mahasiswa_id' => $request->mahasiswa_id,
                'matkul_id' => $request->matkul_id,
                'semester' => $request->semester
            ],
            [
                'dosen_id' => $dosenId,
                'uts' => $request->uts,
                'uas' => $request->uas,
                'tugas' => $request->tugas,
                'nilai_akhir' => $na,
                'grade' => $grade,
            ]
        );

        return response()->json([
            'message' => 'Nilai berhasil disimpan',
            'data' => $nilai
        ], 200);
    }

    public function update(Request $request, Nilai $nilai)
    {
        $request->validate([
            'uts' => 'nullable|numeric|min:0|max:100',
            'uas' => 'nullable|numeric|min:0|max:100',
            'tugas' => 'nullable|numeric|min:0|max:100',
            'nilai_akhir' => 'nullable|numeric|min:0|max:100',
        ]);

        $user = $request->user();
        if ($user->role === 'dosen' && $nilai->dosen_id !== $user->dosen->id) {
            return response()->json(['message' => 'Anda tidak mengampu nilai ini.'], 403);
        }

        $data = $request->only(['uts', 'uas', 'tugas', 'nilai_akhir']);
        if ($request->has('nilai_akhir')) {
            $data['grade'] = $this->gradeFromScore((float) $request->nilai_akhir);
        } else {
            $uts = $request->uts ?? $nilai->uts ?? 0;
            $uas = $request->uas ?? $nilai->uas ?? 0;
            $tugas = $request->tugas ?? $nilai->tugas ?? 0;
            $data['nilai_akhir'] = ($uts + $uas + $tugas) / 3;
            $data['grade'] = $this->gradeFromScore((float) $data['nilai_akhir']);
        }

        $nilai->update($data);

        return response()->json([
            'message' => 'Nilai berhasil diperbarui',
            'data' => $nilai->load(['mahasiswa.user', 'matkul', 'dosen.user'])
        ]);
    }

    public function byMahasiswa($mahasiswaId)
    {
        return response()->json(
            Nilai::with(['matkul', 'dosen.user'])
                ->where('mahasiswa_id', $mahasiswaId)
                ->orderBy('semester')
                ->get()
        );
    }

    public function destroy(Nilai $nilai)
    {
        $user = request()->user();
        if ($user->role === 'dosen' && $nilai->dosen_id !== $user->dosen->id) {
            return response()->json(['message' => 'Anda tidak mengampu nilai ini.'], 403);
        }

        $nilai->delete();

        return response()->json(['message' => 'Nilai berhasil dihapus']);
    }

    /**
     * Mengambil data grafik nilai mahasiswa
     */
    public function grafik($mahasiswaId) 
    {
        // Per semester
        $perSemester = Nilai::select('semester', DB::raw('AVG(nilai_akhir) as rata_rata'))
            ->where('mahasiswa_id', $mahasiswaId)
            ->groupBy('semester')
            ->orderBy('semester')
            ->get();

        return response()->json([
            'per_semester' => $perSemester
        ]);
    }

    private function gradeFromScore(float $score): string
    {
        if ($score >= 90) return 'A';
        if ($score >= 85) return 'A-';
        if ($score >= 78) return 'B+';
        if ($score >= 70) return 'B';
        if ($score >= 60) return 'C';
        return 'D';
    }
}
