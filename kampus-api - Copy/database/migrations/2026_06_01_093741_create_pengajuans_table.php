<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('pengajuans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mahasiswa_id')->constrained('mahasiswas')->onDelete('cascade');
            $table->string('jenis')->default('Tugas Akhir');
            $table->string('judul');
            $table->text('abstrak')->nullable();
            $table->string('bidang_studi')->nullable();
            $table->foreignId('dosen_usulan_1')->constrained('dosens')->onDelete('cascade');
            $table->foreignId('dosen_usulan_2')->nullable()->constrained('dosens')->onDelete('cascade');
            $table->foreignId('dosen_pembimbing')->nullable()->constrained('dosens')->onDelete('cascade');
            $table->enum('status', ['menunggu', 'diterima', 'ditolak'])->default('menunggu');
            $table->text('keterangan')->nullable();
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('pengajuans'); 
    }
};
