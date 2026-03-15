<?php

namespace App\Http\Controllers;

use App\Jobs\SongHlsProcess;
use App\Models\Song;
use Exception;
use FFMpeg\Format\Video\X264;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use ProtoneMedia\LaravelFFMpeg\Support\FFMpeg;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

class SongApiController extends Controller
{
    public function index(){
        $data = Song::all();
        return response()->json(['message' => "Menampilkan data lagu", 'success' => true, 'data' => $data], 200);
    }

    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'title' => 'required',
            'artis_name' => 'required',
            'cover' => 'required',
            'audio' => 'required|file|mimes:mp3'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        try{
            $cover = $request->file('cover');
            $nmcover = "cover_" . time() . '.' . $cover->getClientOriginalExtension();
            $coverPath = $cover->storeAs('covers', $nmcover, 'public');

            $audio = $request->file('audio');
            $nmaudio = 'song_' . time() . '.' . $audio->getClientOriginalExtension();
            $rawAudioPath = $audio->storeAs('songs', $nmaudio, 'public');

            $song = Song::create([
                'title' => $request->title,
                'artis_name' => $request->artis_name,
                'cover_path' => $coverPath,
                'audio_raw_path' => $rawAudioPath
            ]);
            SongHlsProcess::dispatch($song);
            return response()->json(['message' => "Lagu berhasil di upload", 'success' => true, 'data' => $song]);
        }catch(Exception $e){
            return response()->json($e->getMessage());
        }
    }
}
