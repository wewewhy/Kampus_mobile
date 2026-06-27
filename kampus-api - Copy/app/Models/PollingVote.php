<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PollingVote extends Model
{
    protected $fillable = ['polling_id', 'polling_option_id', 'user_id'];
}
