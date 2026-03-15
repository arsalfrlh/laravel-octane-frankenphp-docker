<?php

namespace App\Http\Controllers;

use App\Jobs\BarangCreated;
use App\Jobs\BarangUpdate;
use App\Models\Barang;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BarangApiController extends Controller
{
    public function index(){
        $data = Barang::with('gambar')->get();
        return response()->json(['message' => "Menampilkan data barang", 'success' => true, 'data' => $data], 200);
    }

    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'gambar' => 'required',
            'gambar.*' => 'required|image|mimes:jpeg,jpg,png',
            'nama_barang' => 'required',
            'merk' => 'required',
            'stok' => 'required|numeric',
            'harga' => 'required|numeric'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }
        
        $gambarList = [];
        try{
            foreach($request->file('gambar') as $index => $gambar){
                $nmgambar = "images_" . ($index + 1) . uniqid() . '.' . $gambar->getClientOriginalExtension();
                $gambar->storeAs('images',$nmgambar,'public');
                $gambarList[] = $nmgambar;
            }
        }catch(Exception $e){
            return response()->json(['message' => $e->getMessage(), 'success' => false], 500);
        }

        $barang = [
            'nama_barang' => $request->nama_barang,
            'merk' => $request->merk,
            'stok' => $request->stok,
            'harga' => $request->harga
        ];

        BarangCreated::dispatch($barang, $gambarList);
        return response()->json(['message' => "Barang berhasil ditambahkan", 'success' => true], 201);
    }

    public function update(Request $request, $id){
        $validator = Validator::make($request->all(),[
            'gambar' => 'nullable',
            'gambar.*' => 'nullable|image|mimes:jpeg,jpg,png',
            'gambar_old' => 'nullable|array',
            'nama_barang' => 'required',
            'merk' => 'required',
            'stok' => 'required|numeric',
            'harga' => 'required|numeric'
        ]);
        
        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $gambarList = [];
        if($request->hasFile('gambar')){
            $gambarOld = $request->input('gambar_old');
            foreach($request->file('gambar') as $index => $gambar){
                if(Storage::disk('public')->exists("images/" . $gambarOld[$index]['nama_gambar'])){
                    Storage::disk('public')->delete("images/" . $gambarOld[$index]['nama_gambar']);
                }

                $nmgambar = 'images_' . ($index + 1) . uniqid() . '.' . $gambar->getClientOriginalExtension();
                $gambar->storeAs('images',$nmgambar,'public');
                $gambarList[] = [
                    'id' => $gambarOld[$index]['id'],
                    'nama_gambar' => $nmgambar
                ];
            }
        }

        $barang = [
            'id' => $id,
            'nama_barang' => $request->nama_barang,
            'merk' => $request->merk,
            'stok' => $request->stok,
            'harga' => $request->harga
        ];
        BarangUpdate::dispatch($barang, $gambarList);
        return response()->json(['message' => "Barang berhasil di update", 'success' => true], 200);
    }

    public function show($id){
        $data = Barang::with('gambar')->findOrFail($id);
        return response()->json(['message' => "Menampilkan barang", 'success' => true, 'data' => $data], 200);
    }

    public function destroy($id){
        $barang = Barang::with('gambar')->findOrFail($id);
        foreach($barang->gambar as $gambar){
            if(Storage::disk('public')->exists('images/' . $gambar->nama_gambar)){
                Storage::disk('public')->delete('images/' . $gambar->nama_gambar);
            }
            $gambar->delete();
        }
        $barang->delete();

        return response()->json(['message' => "Barang telah dihapus", 'success' => true], 200);
    }
}
