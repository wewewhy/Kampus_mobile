<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('absensis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('jadwal_id')->constrained('jadwals')->onDelete('cascade');
            $table->foreignId('mahasiswa_id')->constrained('mahasiswas')->onDelete('cascade');
            $table->foreignId('dosen_id')->constrained('dosens')->onDelete('cascade'); // Menghubungkan pencatatan dosen pengampu
            $table->integer('pertemuan_ke');
            $table->enum('status', ['hadir', 'alpa', 'izin', 'sakit']);
            $table->date('tanggal');
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('absensis'); 
    }
};