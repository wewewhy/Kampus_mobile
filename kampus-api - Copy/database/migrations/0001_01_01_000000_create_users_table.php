<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('nama');
            $table->string('email')->unique();
            $table->string('password');
            $table->enum('role', ['admin', 'dosen', 'mahasiswa']);
            $table->string('nomor_induk')->unique(); // NIM atau NIDN
            $table->string('avatar')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }
    public function down() { Schema::dropIfExists('users'); }
};