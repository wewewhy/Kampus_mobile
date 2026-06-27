<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller 
{
    public function login(Request $request) 
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Format email atau password tidak valid.',
                'errors' => $validator->errors()
            ], 422);
        }

        $inputEmail = trim($request->email);
        $inputPassword = trim($request->password);

        $user = User::where('email', $inputEmail)->first();

        if (!$user) {
            return response()->json(['message' => "Email '$inputEmail' tidak ditemukan!"], 401);
        }

        // Menggunakan Hash::check karena password di Laravel umumnya di-hash
        if (!Hash::check($inputPassword, $user->password)) {
            return response()->json(['message' => "Password salah!"], 401);
        }

        $user->tokens()->delete();
        $token = $user->createToken('mobile')->plainTextToken;
        
        $data = [
            'id' => $user->id,
            'nama' => $user->nama,
            'email' => $user->email,
            'role' => $user->role,
            'nomor_induk' => $user->nomor_induk,
            'avatar' => $user->avatar,
        ];  

        if ($user->role === 'mahasiswa') {
            $data['mahasiswa'] = $user->mahasiswa;
        } elseif ($user->role === 'dosen') {
            $data['dosen'] = $user->dosen;
        }

        return response()->json([
            'token' => $token,
            'user' => $data
        ], 200);
    }

    public function logout(Request $request) 
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logout berhasil'], 200);
    }

    public function me(Request $request) 
    {
        $user = $request->user();
        
        $data = [
            'id' => $user->id,
            'nama' => $user->nama,
            'email' => $user->email,
            'role' => $user->role,
            'nomor_induk' => $user->nomor_induk,
            'avatar' => $user->avatar,
        ];

        if ($user->role === 'mahasiswa') {
            $data['mahasiswa'] = $user->mahasiswa;
        } elseif ($user->role === 'dosen') {
            $data['dosen'] = $user->dosen;
        }

        return response()->json(['user' => $data], 200);
    }
}