<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::table('pengajuans', function (Blueprint $table) {
            if (!Schema::hasColumn('pengajuans', 'jenis')) {
                $table->string('jenis')->default('Tugas Akhir')->after('mahasiswa_id');
            }
        });
    }

    public function down() {
        Schema::table('pengajuans', function (Blueprint $table) {
            if (Schema::hasColumn('pengajuans', 'jenis')) {
                $table->dropColumn('jenis');
            }
        });
    }
};
