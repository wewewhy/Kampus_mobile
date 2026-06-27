<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, $role): Response
    {
        // Mengecek apakah user sudah memiliki token (login) 
        // dan mencocokkan role-nya dengan yang diminta di route (contoh: 'admin')
        if (!$request->user() || $request->user()->role !== $role) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses ditolak. Anda bukan ' . $role,
            ], 403);
        }

        return $next($request);
    }
}