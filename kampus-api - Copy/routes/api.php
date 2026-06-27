<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\JadwalController;
use App\Http\Controllers\AbsensiController;
use App\Http\Controllers\KrsController;
use App\Http\Controllers\NilaiController;
use App\Http\Controllers\PengajuanController;
use App\Http\Controllers\TagihanController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\DosenController;
use App\Http\Controllers\MahasiswaController;
use App\Http\Controllers\MatkulController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\BeritaController; // TAMBAHAN: Import BeritaController
use App\Http\Controllers\PollingController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ─── PUBLIC ROUTES (Tanpa Login) ───
Route::post('/login', [AuthController::class, 'login']);

// ─── PROTECTED ROUTES (Harus Login via Sanctum) ───
Route::middleware('auth:sanctum')->group(function () {

    // ─── AUTH & DASHBOARD ───
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/beritas', [BeritaController::class, 'index']); // Rute Baca Berita

    // ─── DOSEN MODULE ───
    Route::get('/dosens', [DosenController::class, 'index']);
    Route::get('/dosens/{dosen}', [DosenController::class, 'show']);

    // ─── MAHASISWA MODULE ───
    Route::get('/mahasiswas', [MahasiswaController::class, 'index']);
    Route::get('/mahasiswas/{mahasiswa}', [MahasiswaController::class, 'show']);

    // ─── MATA KULIAH MODULE ───
    Route::get('/matkuls', [MatkulController::class, 'index']);
    Route::get('/matkuls/{matkul}', [MatkulController::class, 'show']);

    // ─── JADWAL MODULE ───
    Route::get('/jadwals', [JadwalController::class, 'index']);
    Route::get('/jadwals/{jadwal}', [JadwalController::class, 'show']);
    Route::middleware('role:admin,dosen')->group(function () {
        Route::post('/jadwals', [JadwalController::class, 'store']);
        Route::put('/jadwals/{jadwal}', [JadwalController::class, 'update']);
        Route::delete('/jadwals/{jadwal}', [JadwalController::class, 'destroy']);
    });

    // ─── ABSENSI MODULE ───
    Route::get('/absensis', [AbsensiController::class, 'index']);
    Route::get('/absensis/jadwal/{jadwal}', [AbsensiController::class, 'byJadwal']);
    Route::middleware('role:admin,dosen')->group(function () {
        Route::post('/absensis', [AbsensiController::class, 'store']);
        Route::put('/absensis/{absensi}', [AbsensiController::class, 'update']);
        Route::delete('/absensis/{absensi}', [AbsensiController::class, 'destroy']);
    });

    // ─── KRS MODULE ───
    Route::get('/krs', [KrsController::class, 'index']);
    Route::get('/krs/{krs}', [KrsController::class, 'show']);
    Route::middleware('role:admin,mahasiswa')->group(function () {
        Route::post('/krs', [KrsController::class, 'store']);
        Route::put('/krs/{krs}/status', [KrsController::class, 'updateStatus']);
    });

    // ─── NILAI MODULE ───
    Route::get('/nilais', [NilaiController::class, 'index']);
    Route::get('/nilais/mahasiswa/{mahasiswa}', [NilaiController::class, 'byMahasiswa']);
    Route::get('/nilais/grafik/{mahasiswa}', [NilaiController::class, 'grafik']);
    Route::middleware('role:admin,dosen')->group(function () {
        Route::post('/nilai/store', [NilaiController::class, 'store']);
        Route::put('/nilais/{nilai}', [NilaiController::class, 'update']);
        Route::delete('/nilais/{nilai}', [NilaiController::class, 'destroy']);
    });

    // ─── PENGAJUAN SKRIPSI MODULE ───
    Route::get('/pengajuans', [PengajuanController::class, 'index']);
    Route::get('/pengajuans/dosen-list', [PengajuanController::class, 'dosenList']); 
    Route::get('/pengajuans/{pengajuan}', [PengajuanController::class, 'show']);
    Route::middleware('role:mahasiswa')->group(function () {
        Route::post('/pengajuans', [PengajuanController::class, 'store']);
    });
    Route::middleware('role:admin,dosen')->group(function () {
        Route::put('/pengajuans/{pengajuan}/status', [PengajuanController::class, 'updateStatus']);
    });

    // ─── TAGIHAN MODULE ───
    Route::get('/tagihans', [TagihanController::class, 'index']);
    Route::get('/tagihans/mahasiswa/{mahasiswa}', [TagihanController::class, 'byMahasiswa']);
    Route::middleware('role:mahasiswa')->group(function () {
        Route::post('/tagihans/{tagihan}/bayar', [TagihanController::class, 'bayar']);
    });

    // ─── EVENT MODULE ───
    Route::get('/events', [EventController::class, 'index']);
    Route::get('/events/{event}', [EventController::class, 'show']);

    // ─── POLLING MODULE ───
    Route::get('/pollings', [PollingController::class, 'index']);
    Route::middleware('role:mahasiswa,dosen')->group(function () {
        Route::post('/pollings/{polling}/vote', [PollingController::class, 'vote']);
    });
    
    //berita
    // SEMUA USER LOGIN BISA LIHAT BERITA
    Route::get('/beritas', [BeritaController::class, 'index']);

    // ─── MASTER ADMIN ONLY ROUTES ───
    Route::middleware('role:admin')->group(function () 
    {
        // User Management
        Route::apiResource('users', UserController::class);

        // Create, Update, Delete untuk Dosen, Mahasiswa, Matkul
        Route::post('/dosens', [DosenController::class, 'store']);
        Route::put('/dosens/{dosen}', [DosenController::class, 'update']);
        Route::delete('/dosens/{dosen}', [DosenController::class, 'destroy']);

        Route::post('/mahasiswas', [MahasiswaController::class, 'store']);
        Route::put('/mahasiswas/{mahasiswa}', [MahasiswaController::class, 'update']);
        Route::delete('/mahasiswas/{mahasiswa}', [MahasiswaController::class, 'destroy']);

        Route::post('/matkuls', [MatkulController::class, 'store']);
        Route::put('/matkuls/{matkul}', [MatkulController::class, 'update']);
        Route::delete('/matkuls/{matkul}', [MatkulController::class, 'destroy']);

        // Delete KRS & Pengajuan
        Route::delete('/krs/{krs}', [KrsController::class, 'destroy']);
        Route::delete('/pengajuans/{pengajuan}', [PengajuanController::class, 'destroy']);

        // Full Akses Tagihan, Events, & Berita
        Route::post('/tagihans', [TagihanController::class, 'store']);
        Route::put('/tagihans/{tagihan}', [TagihanController::class, 'update']);
        Route::delete('/tagihans/{tagihan}', [TagihanController::class, 'destroy']);

        Route::post('/events', [EventController::class, 'store']);
        Route::put('/events/{event}', [EventController::class, 'update']);
        Route::delete('/events/{event}', [EventController::class, 'destroy']);

        Route::post('/pollings', [PollingController::class, 'store']);

        // TAMBAHAN: Full Akses Berita untuk Admin
        Route::post('/beritas', [BeritaController::class, 'store']);
        Route::put('/beritas/{berita}', [BeritaController::class, 'update']);
        Route::delete('/beritas/{berita}', [BeritaController::class, 'destroy']);
    });
});
