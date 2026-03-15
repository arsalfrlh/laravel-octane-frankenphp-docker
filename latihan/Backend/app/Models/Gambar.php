<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Gambar extends Model
{
    protected $table = "gambar";
    protected $fillable = ["id_barang","nama_gambar"];
}
