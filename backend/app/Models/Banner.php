<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    use HasFactory;

    // === KUNCI UTAMA: Izinkan Laravel mengisi kolom-kolom ini ===
    protected $fillable = [
        'judul',
        'image_url',
        'is_active',
    ];
}