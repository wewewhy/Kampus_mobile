<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('tagihans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mahasiswa_id')->constrained('mahasiswas')->onDelete('cascade');
            $table->string('jenis_tagihan'); 
            $table->decimal('nominal', 12, 0)->default(0);
            $table->integer('semester');
            $table->date('deadline');
            $table->enum('status', ['lunas', 'belum'])->default('belum');
            $table->string('bukti_bayar')->nullable();
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('tagihans'); 
    }
};