<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('polling_votes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('polling_id')->constrained('pollings')->onDelete('cascade');
            $table->foreignId('polling_option_id')->constrained('polling_options')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->timestamps();
            $table->unique(['polling_id', 'user_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('polling_votes');
    }
};
