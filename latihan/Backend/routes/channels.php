<?php

use App\Models\ChatRoom;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('chat-room-{chatRoomId}', function ($user, $chatRoomId) {
    return ChatRoom::where('id', $chatRoomId)->where(function($query) use ($user){
        $query->where('sender_id', $user->id)->orWhere('receiver_id', $user->id);
    })->exists();
});
