<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('polling_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('polling_id')->constrained('pollings')->onDelete('cascade');
            $table->string('label');
            $table->unsignedInteger('votes')->default(0);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('polling_options');
    }
};
