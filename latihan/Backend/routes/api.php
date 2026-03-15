<?php

use App\Http\Controllers\AuthApiController;
use App\Http\Controllers\BarangApiController;
use App\Http\Controllers\MessageApiController;
use App\Http\Controllers\SongApiController;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/name-auth', function(){
    $data = ['Kwanzaa','Arsal','Fahrulloh'];
    return response()->json($data);
})->middleware('auth:sanctum');

Route::get('/name-guest', function(){
    $data = ['Kwanzaa','Arsal','Fahrulloh'];
    return response()->json($data);
});

Route::apiResource('/barang',BarangApiController::class);
Route::apiResource('/song',SongApiController::class);
Route::middleware('auth:sanctum')->group(function(){
    Route::apiResource('/message',MessageApiController::class);
});

Broadcast::routes(['middleware' => ['auth:sanctum']]);
Route::post("/login",[AuthApiController::class,'login']);
Route::post('/register',[AuthApiController::class,'register']);