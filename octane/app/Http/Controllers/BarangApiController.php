<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BarangApiController extends Controller
{
    //GET http://localhost:8081/barangs
    public function index(){
        $data = Barang::all();
        return response()->json(['message' => "Menampilkan semua data barang", 'success' => true, 'data' => $data]);
    }

    //POST http://localhost:8081/barangs
    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'gambar' => 'required|image|mimes:jpeg,jpg,png',
            'nama_barang' => 'required',
            'merk' => 'required',
            'stok' => 'required|numeric',
            'harga' => 'required|numeric'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false]);
        }

        if($request->hasFile('gambar')){
            $gambar = $request->file('gambar');
            $nmgambar = "image" . '_' . time() . '.' . $gambar->getClientOriginalExtension();
            $gambar->storeAs('images',$nmgambar,'public');
        }else{
            $nmgambar = null;
        }

        $data = Barang::create([
            'gambar' => $nmgambar,
            'nama_barang' => $request->nama_barang,
            'merk' => $request->merk,
            'stok' => $request->stok,
            'harga' => $request->harga
        ]);

        return response()->json(['message' => "Barang berhasil di tambahkan", 'success' => true, 'data' => $data]);
    }

    //GET http://localhost:8081/barangs/1
    public function show($id){
        $data = Barang::findOrFail($id);
        return response()->json(['message' => "Menampilkan data barang", 'success' => true, 'data' => $data]);
    }

    //PUT http://localhost:8081/barangs/1
    public function update(Request $request, $id){
        $validator = Validator::make($request->all(),[
            'gambar' => 'nullable|image|mimes:jpeg,jpg,png',
            'nama_barang' => 'required',
            'merk' => 'required',
            'stok' => 'required|numeric',
            'harga' => 'required|numeric'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false]);
        }

        $data = Barang::findOrFail($id);
        if($request->hasFile('gambar')){
            if(Storage::disk('public')->exists('images/' . $data->gambar)){
                Storage::disk('public')->delete('images/' . $data->gambar);
            }

            $gambar = $request->file('gambar');
            $nmgambar = 'image_' . time() . '.' . $gambar->getClientOriginalExtension();
            $gambar->storeAs('images',$nmgambar,'public');
        }else{
            $nmgambar = $data->gambar;
        }
        $data->update([
            'gambar' => $nmgambar,
            'nama_barang' => $request->nama_barang,
            'merk' => $request->merk,
            'stok' => $request->stok,
            'harga' => $request->harga
        ]);

        return response()->json(['message' => "Barang berhasil diupdate", 'success' => true, 'data' => $data]);
    }

    //DELETE http://localhost:8081/barangs/1
    public function destroy($id){
        Barang::findOrFail($id)->delete();
        return response()->json(['message' => "Barang berhasil dihapus", 'success' => true]);
    }
}
