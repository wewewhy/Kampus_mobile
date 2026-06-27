<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('krs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mahasiswa_id')->constrained('mahasiswas')->onDelete('cascade');
            $table->integer('semester');
            $table->string('tahun_akademik');
            $table->enum('status', ['draft', 'disetujui'])->default('draft');
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('krs'); 
    }
};