<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('nilais', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mahasiswa_id')->constrained('mahasiswas')->onDelete('cascade');
            $table->foreignId('matkul_id')->constrained('matkuls')->onDelete('cascade');
            $table->foreignId('dosen_id')->constrained('dosens')->onDelete('cascade');
            $table->decimal('uts', 5, 2)->nullable()->default(0.00);
            $table->decimal('uas', 5, 2)->nullable()->default(0.00);
            $table->decimal('tugas', 5, 2)->nullable()->default(0.00);
            $table->decimal('nilai_akhir', 5, 2)->nullable()->default(0.00);
            $table->string('grade', 2)->nullable();
            $table->integer('semester');
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('nilais'); 
    }
};