<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Review;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    // Mengambil daftar produk yang dibeli user dengan status 'Selesai'
    public function getReviewableProducts()
    {
        $userId = Auth::id();

        // Cari semua pesanan selesai milik user ini
        $completedOrderIds = Order::where('user_id', $userId)
            ->whereIn('status', ['Selesai', 'completed', 'Completed'])
            ->pluck('id');

        // Cari semua item di dalam pesanan tersebut
        $orderItems = OrderItem::whereIn('order_id', $completedOrderIds)->get();

        $reviewable = [];
        foreach ($orderItems as $item) {
            $product = Product::find($item->product_id);
            if (!$product) continue;

            $order = Order::find($item->order_id);

            // Cek apakah user sudah mengulas produk ini
            $review = Review::where('user_id', $userId)
                ->where('product_id', $product->id)
                ->first();

            $key = 'prod_' . $product->id;
            
            if (!isset($reviewable[$key]) || $order->created_at > $reviewable[$key]['tanggal_raw']) {
                $reviewable[$key] = [
                    'product_id' => $product->id,
                    'nama' => $product->name,
                    'tanggal' => $order->created_at->format('d M Y'),
                    'tanggal_raw' => $order->created_at,
                    'status' => $review ? 'Sudah Diulas' : 'Belum Diulas',
                    'rating' => $review ? $review->rating : 0,
                    'comment' => $review ? $review->comment : '',
                ];
            }
        }

        usort($reviewable, function ($a, $b) {
            if ($a['status'] === 'Belum Diulas' && $b['status'] === 'Sudah Diulas') return -1;
            if ($a['status'] === 'Sudah Diulas' && $b['status'] === 'Belum Diulas') return 1;
            return $b['tanggal_raw'] <=> $a['tanggal_raw'];
        });

        // Hapus property tanggal_raw sebelum dikirim ke frontend
        $result = array_map(function($item) {
            unset($item['tanggal_raw']);
            return $item;
        }, $reviewable);

        return response()->json(array_values($result));
    }

    // Menyimpan / Mengupdate Ulasan
    public function store(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:500'
        ]);

        $userId = Auth::id();
        $productId = $request->product_id;

        $review = Review::updateOrCreate(
            ['user_id' => $userId, 'product_id' => $productId],
            ['rating' => $request->rating, 'comment' => $request->comment]
        );

        return response()->json([
            'message' => 'Ulasan berhasil disimpan',
            'review' => $review
        ]);
    }

    // Menampilkan ulasan untuk 1 produk spesifik
    public function getProductReviews($productId)
    {
        $reviews = Review::where('product_id', $productId)
            ->with('user:id,name,profile_image')
            ->orderBy('updated_at', 'desc')
            ->get()
            ->map(function ($review) {
                return [
                    'id' => $review->id,
                    'user_name' => $review->user->name ?? 'Pengguna',
                    'user_image' => $review->user->profile_image ?? null,
                    'rating' => $review->rating,
                    'comment' => $review->comment,
                    'tanggal' => $review->updated_at->format('d M Y')
                ];
            });

        $totalRating = $reviews->sum('rating');
        $count = $reviews->count();
        $average = $count > 0 ? round($totalRating / $count, 1) : 0;

        return response()->json([
            'average_rating' => $average,
            'total_reviews' => $count,
            'reviews' => $reviews
        ]);
    }
}
