<?php

namespace App\Http\Controllers;

use App\Events\ChatUpdated;
use App\Models\ChatRoom;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class MessageApiController extends Controller
{
    public function index(Request $request){
        $user = $request->user();
        $data = User::where('id','!=',$user->id)->get();
        return response()->json(['message' => "Menampilkan semua User", 'success' => true, 'data' => $data], 200);
    }

    public function show(Request $request, $receiverId){
        $senderId = $request->user()->id;

        $chatRoom = ChatRoom::where(function($query) use ($senderId, $receiverId){
            $query->where('sender_id', $senderId)->where('receiver_id', $receiverId)->orWhere('sender_id', $receiverId)->where('receiver_id', $senderId);
        })->first();
        if(!$chatRoom){
            $chatRoom = ChatRoom::create([
                'sender_id' => $senderId,
                'receiver_id' => $receiverId
            ]);
        }

        $data = Message::with('user')->where('chat_room_id', $chatRoom->id)->get();
        return response()->json(['message' => "Menampilkan isi Pesan", 'success' => true, 'data' => $data, 'chat_room_id' => $chatRoom->id]);
    }

    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'receiver_id' => 'required',
            'message' => 'required',
            'gambar' => 'nullable|image|mimes:jpeg,jpg,png'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $senderId = $request->user()->id;
        $receiverId = $request->receiver_id;
        $chatRoom = ChatRoom::where(function($query) use ($senderId, $receiverId){
            $query->where('sender_id', $senderId)->where('receiver_id', $receiverId)->orWhere('sender_id', $receiverId)->where('receiver_id', $senderId);
        })->first();
        if(!$chatRoom){
            $chatRoom = ChatRoom::create([
                'sender_id' => $senderId,
                'receiver_id' => $receiverId
            ]);
        }

        if($request->hasFile('gambar')){
            $gambar = $request->file('gambar');
            $nmGambar = "image_" . time() . '.' . $gambar->getClientOriginalExtension();
            $gambarPath = $gambar->storeAs('images',$nmGambar,'public');
        }else{
            $gambarPath = null;
        }

        $message = Message::create([
            'chat_room_id' => $chatRoom->id,
            'id_user' => $senderId,
            'message' => $request->message,
            'gambar' => $gambarPath
        ]);

        $message->load('user');
        broadcast(new ChatUpdated($message,'create',$chatRoom->id));
        return response()->json(['message' => "Pesan berhasil dikirim", 'success' => true, 'data' => $message], 201);
    }

    public function update(Request $request, $id){
        $validator = Validator::make($request->all(),[
            'message' => 'required',
            'image' => 'nullable|image|mimes:jpeg,jpg,png'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $user = $request->user();
        $data = Message::with('user')->where("id_user", $user->id)->findOrFail($id);

        if($request->hasFile('gambar')){
            if(Storage::disk('public')->exists($data->gambar)){
                Storage::disk('public')->delete($data->gambar);
            }
            $gambar = $request->file('gambar');
            $nmGambar = "image_" . time() . '.' . $gambar->getClientOriginalExtension();
            $gambarPath = $gambar->storeAs('images',$nmGambar,'public');
        }else{
            $gambarPath = $data->gambar;
        }

        $data->update([
            'message' => $request->message,
            'gambar' => $gambarPath
        ]);
        broadcast(new ChatUpdated($data, "update", $data->chat_room_id));
        return response()->json(['message' => "Pesan berhasil diupdate", 'success' => true, 'data' => $data], 200);
    }

    public function destroy(Request $request, $id){
        $user = $request->user();
        $message = Message::with('user')->where('id_user', $user->id)->findOrFail($id);
        if(Storage::disk('public')->exists($message->gambar)){
            Storage::disk('public')->delete($message->gambar);
        }

        $chatRoomId = $message->chat_room_id;
        $data = $message->toArray();
        $message->delete();
        broadcast(new ChatUpdated($data,'delete',$chatRoomId));
        return response()->json(['message' => "Pesan telah anda hapus", 'success' => true, 'data' => $data], 200);
    }
}
