<?php

namespace App\Jobs;

use App\Models\Barang;
use App\Models\Gambar;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\SerializesModels;

class BarangUpdate implements ShouldQueue
{
    use Queueable, Dispatchable, SerializesModels;
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
        $barang = $this->barang;
        Barang::find($barang['id'])->update($barang);
        $gambarList = $this->gambarList;
        if(!empty($gambarList)){
            foreach($gambarList as $gambar){
                Gambar::where('id_barang', $barang['id'])->where('id', $gambar['id'])->update([
                    'nama_gambar' => $gambar['nama_gambar']
                ]);
            }
        }
    }
}
