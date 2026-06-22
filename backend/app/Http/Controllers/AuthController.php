<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'customer', // default role
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registrasi berhasil',
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Kredensial tidak cocok dengan data kami.'
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }
    public function logout(Request $request)
    {
        // Pengecekan aman: Pastikan user login baru token dihapus
        $user = $request->user();
        if ($user && $user->currentAccessToken()) {
            $user->currentAccessToken()->delete();
        }

        return response()->json(['message' => 'Logout berhasil']);
    }

    // === FUNGSI UPDATE PROFIL & FOTO YANG SUDAH DIOPTIMALISASI ===
    public function updateProfile(Request $request)
    {
        // 1. Ambil user dengan cara yang lebih aman
        $user = Auth::user(); 

        if (!$user) {
            return response()->json(['message' => 'User tidak terdeteksi! Silakan login ulang.'], 401);
        }
        
        // 2. Setup aturan validasi
        $rules = [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'no_hp' => 'nullable|string|max:20',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:20480', // 20 MB
        ];

        // Jika user ingin mengubah password
        if ($request->filled('password')) {
            $rules['current_password'] = ['required', function ($attribute, $value, $fail) use ($user) {
                if (!Hash::check($value, $user->password)) {
                    $fail('Kata sandi saat ini tidak cocok.');
                }
            }];
            $rules['password'] = 'required|min:6'; 
        }

        $request->validate($rules);
        $user->name = $request->name;
        $user->email = $request->email;
        $user->phone = $request->no_hp; // <--- Sesuai dengan kolom di tabel database

        // 4. Update Password jika diisi
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        // 5. Update Foto
        if ($request->hasFile('image')) {
            // Hapus foto lama jika ada (agar server tidak penuh)
            if ($user->profile_photo) {
                // Hapus bagian 'storage/' dari URL untuk mendapatkan path asli
                $oldPath = str_replace(asset('storage/'), '', $user->profile_photo);
                Storage::disk('public')->delete($oldPath);
            }
            
            $path = $request->file('image')->store('profiles', 'public');
            $user->profile_photo = asset('storage/' . $path);
        }

        $user->save();

        return response()->json([
            'message' => 'Profil berhasil diperbarui!', 
            'data' => $user
        ]);
    }
}