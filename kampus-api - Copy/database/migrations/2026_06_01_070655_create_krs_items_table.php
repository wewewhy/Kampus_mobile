<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('krs_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('krs_id')->constrained('krs')->onDelete('cascade');
            $table->foreignId('matkul_id')->constrained('matkuls')->onDelete('cascade');
            $table->timestamps();
        });
    }

    public function down() { 
        Schema::dropIfExists('krs_items'); 
    }
};