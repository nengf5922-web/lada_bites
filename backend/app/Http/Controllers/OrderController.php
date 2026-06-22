<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderItem; // Pastikan model ini sudah Kakak buat sebelumnya
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    /**
     * TAMPILKAN RIWAYAT PESANAN (Untuk HistoryScreen Flutter)
     */
    public function index()
    {
        // Ambil pesanan HANYA milik user yang sedang login, urutkan dari yang terbaru
        $orders = Order::with(['items.product'])
                    ->where('user_id', Auth::id())
                    ->orderBy('created_at', 'desc')
                    ->get();

        return response()->json($orders, 200);
    }

    /**
     * SIMPAN PESANAN BARU (Dari CheckoutScreen Flutter)
     */
    public function store(Request $request)
    {
        // 1. Validasi data yang dikirim dari Flutter
        $request->validate([
            'nama_penerima'     => 'required|string',
            'no_hp'             => 'required|string',
            'alamat_lengkap'    => 'required|string',
            'metode_pembayaran' => 'required|string',
            'wilayah_pengiriman'=> 'nullable|string',
            'ongkir'            => 'nullable|numeric',
            'total_harga'       => 'required|numeric',
            'items'             => 'required|array', // Array produk dari keranjang
            'items.*.product_id'=> 'required|integer',
            'items.*.jumlah'    => 'required|integer|min:1',
            'items.*.harga_satuan' => 'required|numeric',
            'items.*.subtotal'  => 'required|numeric',
        ]);

        try {
            // Cek Stok Terlebih Dahulu
            foreach ($request->items as $item) {
                $product = \App\Models\Product::find($item['product_id']);
                if (!$product) {
                    return response()->json(['message' => 'Produk tidak ditemukan!'], 404);
                }
                if ($product->stok < $item['jumlah']) {
                    return response()->json(['message' => 'Stok produk ' . $product->nama_produk . ' tidak mencukupi. Tersisa: ' . $product->stok], 400);
                }
            }

            $status_awal = 'pending';
            if ($request->metode_pembayaran == 'QRIS') {
                $status_awal = 'menunggu pembayaran';
            }

            // 3. Simpan ke tabel `orders`
            $order = Order::create([
                'user_id'           => Auth::id() ?? 1, // Jika blm ada autentikasi flutter, default 1
                'tanggal_pesan'     => date('Y-m-d'),
                'nama_penerima'     => $request->nama_penerima,
                'no_hp'             => $request->no_hp,
                'alamat_lengkap'    => $request->alamat_lengkap,
                'wilayah_pengiriman'=> $request->wilayah_pengiriman,
                'ongkir'            => $request->ongkir ?? 0,
                'metode_pembayaran' => $request->metode_pembayaran,
                'total_harga'       => $request->total_harga,
                'status'            => $status_awal,
            ]);

            // 4. Simpan rincian produk ke tabel `order_items` dan Kurangi Stok
            foreach ($request->items as $item) {
                $order->items()->create([
                    'product_id'   => $item['product_id'],
                    'jumlah'       => $item['jumlah'],
                    'harga_satuan' => $item['harga_satuan'],
                    'subtotal'     => $item['subtotal'],
                ]);

                // Kurangi stok di database
                $product = \App\Models\Product::find($item['product_id']);
                if ($product) {
                    $product->stok -= $item['jumlah'];
                    $product->save();
                }
            }

            // 5. Kembalikan respons sukses ke Flutter
            return response()->json([
                'message' => 'Yeay! Pesanan berhasil dibuat!',
                'order'   => $order->load('items')
            ], 201);

        } catch (\Exception $e) {
            // Jika terjadi error (misal masalah database), tangkap dan kirim pesan error
            return response()->json([
                'message' => 'Gagal memproses pesanan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * TAMPILKAN SEMUA PESANAN UNTUK ADMIN
     */
    public function adminIndex()
    {
        // Ambil semua pesanan dari semua user, urutkan dari yang terbaru
        $orders = Order::with(['items', 'user'])
                    ->orderBy('created_at', 'desc')
                    ->get();

        return response()->json($orders, 200);
    }

    /**
     * UPDATE STATUS PESANAN (Admin)
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:Pending,Diproses,Dikirim,Selesai,Dibatalkan,Belum Dibayar'
        ]);

        $order = Order::find($id);

        if (!$order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        $order->status = $request->status;
        $order->save();

        return response()->json([
            'message' => 'Status pesanan berhasil diperbarui',
            'order' => $order
        ], 200);
    }

    /**
     * UPLOAD BUKTI PEMBAYARAN (QRIS)
     */
    public function uploadBuktiPembayaran(Request $request, $id)
    {
        $order = Order::find($id);

        if (!$order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        if ($order->user_id != Auth::id() && Auth::user()->role != 'admin') {
            return response()->json(['message' => 'Anda tidak memiliki akses ke pesanan ini'], 403);
        }

        $request->validate([
            'bukti_pembayaran' => 'required|image|mimes:jpeg,png,jpg,webp|max:2048'
        ]);

        if ($request->hasFile('bukti_pembayaran')) {
            $path = $request->file('bukti_pembayaran')->store('bukti_pembayaran', 'public');
            $order->bukti_pembayaran = asset('storage/' . $path);
            $order->status = 'menunggu konfirmasi';
            $order->save();

            return response()->json([
                'message' => 'Bukti pembayaran berhasil diunggah',
                'order' => $order
            ], 200);
        }

        return response()->json(['message' => 'File bukti pembayaran tidak ditemukan'], 400);
    }
}