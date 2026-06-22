<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    // READ: Get all users
    public function index()
    {
        $users = User::orderBy('created_at', 'desc')->get();
        return response()->json([
            'message' => 'Berhasil mengambil data pengguna',
            'data' => $users
        ], 200);
    }

    // CREATE: Create new user
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'role' => 'required|in:admin,customer'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        return response()->json([
            'message' => 'Pengguna berhasil ditambahkan',
            'data' => $user
        ], 201);
    }

    // UPDATE: Edit user details
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'Pengguna tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $id,
            'password' => 'nullable|string|min:8',
            'role' => 'required|in:admin,customer'
        ]);

        $user->name = $request->name;
        $user->email = $request->email;
        $user->role = $request->role;
        
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json([
            'message' => 'Data pengguna berhasil diperbarui',
            'data' => $user
        ], 200);
    }

    // DELETE: Delete a user
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'Pengguna tidak ditemukan'
            ], 404);
        }

        // Jangan izinkan admin menghapus dirinya sendiri jika diinginkan, tapi untuk sekarang kita bebaskan
        $user->delete();

        return response()->json([
            'message' => 'Pengguna berhasil dihapus'
        ], 200);
    }
}
