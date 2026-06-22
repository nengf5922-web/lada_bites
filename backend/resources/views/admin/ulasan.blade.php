@extends('layouts.admin')

@section('title', 'Ulasan Produk')

@section('content')
<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0" style="color: #111111;">Ulasan Produk</h2>
    </div>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th scope="col" class="text-secondary fw-semibold">Tanggal</th>
                            <th scope="col" class="text-secondary fw-semibold">Pengguna</th>
                            <th scope="col" class="text-secondary fw-semibold">Produk</th>
                            <th scope="col" class="text-secondary fw-semibold text-center">Rating</th>
                            <th scope="col" class="text-secondary fw-semibold">Komentar</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($reviews as $review)
                            <tr>
                                <td>{{ $review->created_at->format('d M Y') }}</td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-secondary rounded-circle text-white d-flex justify-content-center align-items-center me-2" style="width: 32px; height: 32px;">
                                            <i class="fa-solid fa-user" style="font-size: 12px;"></i>
                                        </div>
                                        <span class="fw-bold">{{ $review->user->name ?? 'Anonim' }}</span>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge bg-light text-dark border">{{ $review->product->name ?? 'Produk Dihapus' }}</span>
                                </td>
                                <td class="text-center" style="min-width: 100px;">
                                    <div class="text-warning mb-1">
                                        @for($i = 1; $i <= 5; $i++)
                                            <i class="fa-{{ $i <= $review->rating ? 'solid' : 'regular' }} fa-star" style="font-size: 14px;"></i>
                                        @endfor
                                    </div>
                                    <small class="text-muted fw-bold">{{ $review->rating }} / 5</small>
                                </td>
                                <td>
                                    @if($review->comment)
                                        <p class="mb-0 text-wrap" style="max-width: 350px; font-size: 14px; color: #444;">
                                            "{{ $review->comment }}"
                                        </p>
                                    @else
                                        <span class="text-muted fst-italic" style="font-size: 13px;">Tidak ada komentar</span>
                                    @endif
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                    <i class="fa-regular fa-star fs-1 mb-3 text-black-50"></i>
                                    <p class="mb-0">Belum ada ulasan yang diberikan oleh pelanggan.</p>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
