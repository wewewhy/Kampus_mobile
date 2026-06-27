<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('dosens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('nidn')->unique();
            $table->string('bidang_keahlian')->nullable();
            $table->integer('kuota_bimbingan')->default(10);
            $table->integer('jumlah_bimbingan_aktif')->default(0);
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('dosens'); 
    }
};