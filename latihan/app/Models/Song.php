<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Song extends Model
{
    protected $table = "song";
    protected $fillable = ['title','artis_name','cover_path','audio_path','audio_raw_path','duration'];
}
