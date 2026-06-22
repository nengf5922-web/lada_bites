<?php

namespace App\Http\Controllers;

use App\Models\Banner;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    // === API UNTUK PELANGGAN (Flutter) ===
    // Perbaikan: Jangan double asset!
    public function index()
    {
        // Ambil yang aktif saja, urutkan dari yang terbaru
        $banners = Banner::where('is_active', true)->latest()->get();

        // Di fungsi store Kakak sudah pakai asset(), 
        // jadi datanya sudah utuh http://...
        // Langsung kirim apa adanya, jangan di-transform lagi.
        return response()->json(['data' => $banners]);
    }

    // === API UNTUK ADMIN (Halaman Web) ===
    public function adminIndex()
    {
        $banners = Banner::latest()->get();
        // Langsung kirim apa adanya (datanya sudah utuh URL lengkap)
        return response()->json($banners);
    }

    // === API UNTUK ADMIN (Upload Banner Baru) ===
    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string',
            'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:2048',
        ]);

        // Simpan gambar ke folder storage/app/public/banners
        $imagePath = $request->file('image')->store('banners', 'public');
        
        // Buat URL lengkap agar mudah dipanggil Flutter/Web
        $imageUrl = asset('storage/' . $imagePath); 

        $banner = Banner::create([
            'judul' => $request->judul,
            'image_url' => $imageUrl, // Menyimpan URL lengkap: http://domain/storage/banners/xyz.jpg
            'is_active' => true,
        ]);

        return response()->json(['message' => 'Banner berhasil diupload!', 'data' => $banner], 201);
    }

    // === API UNTUK ADMIN (Edit Banner) ===
    public function update(Request $request, $id)
    {
        $banner = Banner::find($id);
        if (!$banner) {
            return response()->json(['message' => 'Banner tidak ditemukan'], 404);
        }

        $request->validate([
            'judul' => 'required|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'is_active' => 'boolean'
        ]);

        $banner->judul = $request->judul;
        
        if ($request->has('is_active')) {
            $banner->is_active = $request->is_active;
        }

        if ($request->hasFile('image')) {
            // Hapus gambar lama
            $oldPath = str_replace(asset('storage/'), '', $banner->image_url);
            Storage::disk('public')->delete($oldPath);

            // Simpan gambar baru
            $imagePath = $request->file('image')->store('banners', 'public');
            $banner->image_url = asset('storage/' . $imagePath);
        }

        $banner->save();

        return response()->json(['message' => 'Banner berhasil diperbarui!', 'data' => $banner]);
    }

    // === API UNTUK ADMIN (Hapus Banner) ===
    public function destroy($id)
    {
        $banner = Banner::find($id);
        if ($banner) {
            // Hapus file gambar dari server
            // Ambil path aslinya dengan membuang bagian asset(storage)
            $path = str_replace(asset('storage/'), '', $banner->image_url);
            Storage::disk('public')->delete($path);
            
            $banner->delete();
            return response()->json(['message' => 'Banner berhasil dihapus']);
        }
        return response()->json(['message' => 'Banner tidak ditemukan'], 404);
    }
}