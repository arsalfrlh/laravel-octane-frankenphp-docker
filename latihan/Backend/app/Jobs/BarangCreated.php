<?php

namespace App\Jobs;

use App\Models\Barang;
use App\Models\Gambar;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\SerializesModels;

class BarangCreated implements ShouldQueue
{
    use Queueable, SerializesModels, Dispatchable;
    protected $barang;
    protected $gambarList;

    /**
     * Create a new job instance.
     */
    public function __construct($barang, $gambarList)
    {
        $this->barang = $barang;
        $this->gambarList = $gambarList;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $barang = Barang::create($this->barang);
        foreach($this->gambarList as $gambar){
            Gambar::create([
                'id_barang' => $barang->id,
                'nama_gambar' => $gambar
            ]);
        }
    }
}
