<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Carbon\Carbon;

class ReportController extends Controller
{
    // READ: Menarik laporan penjualan (Hanya Admin/Owner)
    public function index(Request $request)
    {
        // Pengecekan hak akses
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Akses ditolak. Hanya Admin/Owner yang dapat melihat laporan.'], 403);
        }

        // Mengambil parameter tanggal dari request frontend (default: bulan ini)
        $startDate = $request->query('start_date', Carbon::now()->startOfMonth()->toDateString());
        $endDate = $request->query('end_date', Carbon::now()->endOfMonth()->toDateString());

        // Tarik data pesanan yang statusnya sudah 'selesai' pada rentang tanggal tersebut
        $orders = Order::with('items.product')
            ->whereBetween('tanggal_pesan', [$startDate, $endDate])
            ->where('status', 'selesai')
            ->get();

        // Hitung total pendapatan dan jumlah barang terjual
        $totalPendapatan = $orders->sum('total_harga');
        $totalPesanan = $orders->count();
        $totalItemTerjual = 0;

        foreach ($orders as $order) {
            $totalItemTerjual += $order->items->sum('jumlah');
        }

        // Menghitung total entity lainnya
        $totalKategori = \App\Models\Category::count();
        $totalProduk = \App\Models\Product::count();
        $totalPelanggan = \App\Models\User::where('role', 'user')->count();

        return response()->json([
            'message' => 'Berhasil menarik data laporan penjualan',
            'periode' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'ringkasan' => [
                'total_pesanan' => $totalPesanan,
                'total_item_terjual' => $totalItemTerjual,
                'total_pendapatan' => $totalPendapatan,
                'total_kategori' => $totalKategori,
                'total_produk' => $totalProduk,
                'total_pelanggan' => $totalPelanggan,
            ],
            'data_transaksi' => $orders
        ]);
    }

    // Fungsi untuk Export CSV Laporan Pesanan Selesai
    public function downloadCsv(Request $request)
    {
        $startDate = $request->query('start_date', Carbon::now()->startOfMonth()->toDateString());
        $endDate = $request->query('end_date', Carbon::now()->endOfMonth()->toDateString());

        $orders = Order::with('items.product')
            ->whereBetween('tanggal_pesan', [$startDate, $endDate])
            ->where('status', 'selesai')
            ->get();

        $filename = "laporan_penjualan_ladabites_{$startDate}_sampai_{$endDate}.csv";
        
        $headers = [
            "Content-type"        => "text/csv",
            "Content-Disposition" => "attachment; filename=$filename",
            "Pragma"              => "no-cache",
            "Cache-Control"       => "must-revalidate, post-check=0, pre-check=0",
            "Expires"             => "0"
        ];

        $columns = ['ID Pesanan', 'Tanggal Pesan', 'Nama Penerima', 'No HP', 'Alamat', 'Metode Pembayaran', 'Status', 'Total Harga', 'Detail Produk (Nama x Jumlah)'];

        $callback = function() use($orders, $columns) {
            $file = fopen('php://output', 'w');
            fputcsv($file, $columns);

            foreach ($orders as $order) {
                $detailProduk = [];
                foreach ($order->items as $item) {
                    $namaProduk = $item->product ? $item->product->nama_produk : 'Produk Dihapus';
                    $detailProduk[] = "{$namaProduk} (x{$item->jumlah})";
                }
                
                $row = [
                    'LB-' . str_pad($order->id, 5, '0', STR_PAD_LEFT),
                    $order->tanggal_pesan,
                    $order->nama_penerima,
                    $order->no_hp,
                    $order->alamat_lengkap,
                    $order->metode_pembayaran,
                    $order->status,
                    $order->total_harga,
                    implode(', ', $detailProduk)
                ];

                fputcsv($file, $row);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}