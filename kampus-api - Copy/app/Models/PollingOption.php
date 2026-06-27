<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PollingOption extends Model
{
    protected $fillable = ['polling_id', 'label', 'votes'];

    public function polling()
    {
        return $this->belongsTo(Polling::class);
    }
}
