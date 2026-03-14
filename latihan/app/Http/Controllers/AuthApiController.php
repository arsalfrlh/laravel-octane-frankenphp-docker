<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AuthApiController extends Controller
{
    public function login(Request $request){
        $validator = Validator::make($request->all(),[
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        if(!User::where('email', $request->email)->exists()){
            return response()->json(['message' => "Email anda belum terdaftar", 'success' => false], 401);
        }

        if(Auth::attempt($request->all())){
            $data = [
                'name' => Auth::user()->name,
                'token' => Auth::user()->createToken('auth-token')->plainTextToken
            ];

            return response()->json(['message' => "Login berhasil", 'success' => true, 'data' => $data], 200);
        }else{
            return response()->json(['message' => "Password anda salah", 'success' => false], 401);
        }
    }

    public function register(Request $request){
        $validator = Validator::make($request->all(),[
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $user = User::create($request->all());
        $data = [
            'name' => $user->name,
            'token' => $user->createToken('auth-token')->plainTextToken
        ];
        return response()->json(['message' => "Register berhasil", 'success' => true, 'data' => $data], 201);
    }
}
