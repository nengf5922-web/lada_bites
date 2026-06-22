<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = ['order_id', 'product_id', 'jumlah', 'harga_satuan', 'subtotal'];

    // Relasi: Item ini dari produk apa?
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}