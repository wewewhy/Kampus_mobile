<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->string('judul');
            $table->text('deskripsi')->nullable();
            $table->enum('tipe', ['gratis', 'berbayar']);
            $table->decimal('harga', 12, 0)->default(0);
            $table->date('tanggal_event');
            $table->string('poster_url')->nullable();
            $table->string('lokasi')->nullable();
            $table->enum('status', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('events'); 
    }
};