<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class UserController extends Controller
{
    public function updateProfile(Request $request) {
    $user = $request->user();
    $user->update($request->only(['nama', 'avatar']));
    return response()->json(['message' => 'Profil diupdate', 'user' => $user]);
}
}
