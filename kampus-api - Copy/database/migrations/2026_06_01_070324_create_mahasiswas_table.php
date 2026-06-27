<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('mahasiswas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('jurusan');
            $table->year('angkatan');
            $table->integer('semester_aktif')->default(1);
            $table->decimal('ipk', 3, 2)->default(0.00);
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('mahasiswas'); 
    }
};