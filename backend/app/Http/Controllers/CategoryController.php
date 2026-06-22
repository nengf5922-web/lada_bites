<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    // READ: Mengambil semua data kategori
    public function index()
    {
        // Ambil kategori beserta semua produk, lalu kita filter di collection untuk menghindari bug Eloquent limit(1) per grup
        $categories = Category::with('products')->get();
        
        $data = $categories->map(function($cat) {
            $image = null;
            // Ambil produk terbaru (yang paling akhir dibuat) yang memiliki gambar
            $latestProduct = $cat->products->sortByDesc('created_at')->firstWhere('gambar', '!=', null);
            
            if ($latestProduct) {
                $image = $latestProduct->gambar;
            }

            return [
                'id' => $cat->id,
                'name' => $cat->name,
                'image' => $image,
                'created_at' => $cat->created_at,
                'updated_at' => $cat->updated_at
            ];
        });

        return response()->json([
            'message' => 'Berhasil mengambil data kategori',
            'data' => $data
        ], 200);
    }

    // CREATE: Menyimpan kategori baru
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:categories,name'
        ]);

        $category = Category::create([
            'name' => $request->name
        ]);

        return response()->json([
            'message' => 'Kategori berhasil ditambahkan',
            'data' => $category
        ], 201);
    }

    // UPDATE: Memperbarui data kategori
    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:categories,name,' . $id
        ]);

        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        $category->name = $request->name;
        $category->save();

        return response()->json([
            'message' => 'Kategori berhasil diperbarui',
            'data' => $category
        ], 200);
    }

    // DELETE: Menghapus data kategori
    public function destroy($id)
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        $category->delete();

        return response()->json([
            'message' => 'Kategori berhasil dihapus'
        ], 200);
    }
}