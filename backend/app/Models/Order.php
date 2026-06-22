<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    // Tambahkan nama_penerima, no_hp, alamat_lengkap, dan metode_pembayaran ke dalam sini!
    protected $fillable = [
        'user_id',
        'tanggal_pesan',
        'nama_penerima',
        'no_hp',
        'alamat_lengkap',
        'metode_pembayaran',
        'total_harga',
        'status',
    ];

    // Relasi ke OrderItems (Rincian Produk)
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}