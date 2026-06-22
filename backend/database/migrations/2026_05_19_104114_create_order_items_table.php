<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
 // File: database/migrations/xxxx_create_order_items_table.php
$table->id();
$table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
$table->foreignId('product_id')->constrained('products')->onDelete('cascade');
$table->integer('jumlah');
$table->integer('harga_satuan'); // Simpan harga saat itu agar laporan akurat walau harga produk berubah
$table->integer('subtotal');
$table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
