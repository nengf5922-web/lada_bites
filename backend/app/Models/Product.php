<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    // Izinkan kolom-kolom ini diisi secara langsung
    protected $fillable = ['category_id', 'nama_produk', 'harga', 'stok', 'gambar', 'deskripsi'];

    // Relasi: Produk ini milik kategori apa?
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}