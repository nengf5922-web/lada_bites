<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    // READ ALL: Menampilkan semua produk
    public function index()
    {
        $products = Product::with('category')->latest()->get();
        return response()->json([
            'message' => 'Berhasil mengambil data produk',
            'data' => $products
        ]);
    }

    // CREATE: Menambah produk baru (Hanya Admin)
    public function store(Request $request)
    {


        $validatedData = $request->validate([
            'nama_produk' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'deskripsi' => 'nullable|string',
            'harga' => 'required|integer|min:0',
            'stok' => 'required|integer|min:0',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:10240' // Maksimal 10MB
        ]);

        // Proses upload gambar jika ada
        if ($request->hasFile('gambar')) {
            $path = $request->file('gambar')->store('products', 'public');
            $validatedData['gambar'] = asset('storage/' . $path);
        }

        $product = Product::create($validatedData);

        return response()->json([
            'message' => 'Produk berhasil ditambahkan',
            'data' => $product
        ], 201);
    }

    // READ ONE: Menampilkan detail satu produk
    public function show($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        return response()->json([
            'message' => 'Detail produk',
            'data' => $product
        ]);
    }

    // UPDATE: Mengubah data produk (Hanya Admin)
    public function update(Request $request, $id)
    {


        $product = Product::find($id);
        if (!$product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $validatedData = $request->validate([
            'nama_produk' => 'sometimes|required|string|max:255',
            'category_id' => 'sometimes|required|exists:categories,id',
            'deskripsi' => 'nullable|string',
            'harga' => 'sometimes|required|integer|min:0',
            'stok' => 'sometimes|required|integer|min:0',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:10240'
        ]);

        // Proses ganti gambar jika admin mengunggah gambar baru
        if ($request->hasFile('gambar')) {
            // Hapus gambar lama jika ada (hanya path relatifnya saja yang dihapus dari storage)
            if ($product->gambar) {
                $oldPath = str_replace(asset('storage/'), '', $product->gambar);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }
            
            $path = $request->file('gambar')->store('products', 'public');
            $validatedData['gambar'] = asset('storage/' . $path);
        }

        $product->update($validatedData);

        return response()->json([
            'message' => 'Produk berhasil diperbarui',
            'data' => $product
        ]);
    }

    // DELETE: Menghapus produk (Hanya Admin)
    public function destroy(Request $request, $id)
    {


        $product = Product::find($id);
        if (!$product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        // Hapus file gambar dari server sebelum menghapus data di database
        if ($product->gambar && Storage::exists('public/' . $product->gambar)) {
            Storage::delete('public/' . $product->gambar);
        }

        $product->delete();

        return response()->json([
            'message' => 'Produk berhasil dihapus'
        ]);
    }
}