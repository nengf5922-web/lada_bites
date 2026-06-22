<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Jalankan migration untuk menambah kolom baru.
     */
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Menambahkan kolom baru setelah kolom 'status' (atau kolom lain yang ada)
            $table->string('nama_penerima')->nullable()->after('status');
            $table->string('no_hp')->nullable()->after('nama_penerima');
            $table->text('alamat_lengkap')->nullable()->after('no_hp');
            $table->string('metode_pembayaran')->nullable()->after('alamat_lengkap');
        });
    }

    /**
     * Hapus kolom jika dilakukan rollback.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'nama_penerima',
                'no_hp',
                'alamat_lengkap',
                'metode_pembayaran'
            ]);
        });
    }
};