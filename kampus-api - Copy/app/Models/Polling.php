<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Polling extends Model
{
    protected $fillable = ['judul', 'deskripsi', 'status'];

    public function options()
    {
        return $this->hasMany(PollingOption::class);
    }

    public function votes()
    {
        return $this->hasMany(PollingVote::class);
    }
}
