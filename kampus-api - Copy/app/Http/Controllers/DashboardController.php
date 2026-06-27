<?php
namespace App\Http\Controllers;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller {
    public function index(Request $request) {
        $user = $request->user();
        $response = ['user' => [
            'id' => $user->id,
            'nama' => $user->nama,
            'role' => $user->role,
            'nomor_induk' => $user->nomor_induk
        ]];

        if ($user->role === 'mahasiswa' && $user->mahasiswa) {
            $mhs = $user->mahasiswa;
            $response['user']['semester'] = $mhs->semester_aktif;
            $response['user']['ipk'] = $mhs->ipk;
            
            // Hitung SKS dari KRS
            $totalSks = DB::table('krs_items')
                ->join('krs', 'krs_items.krs_id', '=', 'krs.id')
                ->join('matkuls', 'krs_items.matkul_id', '=', 'matkuls.id')
                ->where('krs.mahasiswa_id', $mhs->id)
                ->where('krs.semester', $mhs->semester_aktif)
                ->sum('matkuls.sks');
            $response['user']['sks'] = $totalSks;
        }

        // Event running layer (aktif & tanggal mendatang)
        $events = Event::where('status', 'aktif')
            ->where('tanggal_event', '>=', now())
            ->orderBy('tanggal_event')
            ->limit(10)
            ->get();

        $response['events'] = $events;

        return response()->json($response);
    }
}