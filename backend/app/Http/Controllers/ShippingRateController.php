<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ShippingRate;

class ShippingRateController extends Controller
{
    // API Endpoint: Get All Rates for Flutter
    public function index()
    {
        $rates = ShippingRate::orderBy('wilayah', 'asc')->get();
        return response()->json($rates, 200);
    }

    // Admin View: Tampilkan Halaman Pengaturan Ongkir
    public function adminIndex()
    {
        return view('admin.ongkir');
    }

    // Admin Action: Tambah Ongkir (API)
    public function store(Request $request)
    {
        $request->validate([
            'wilayah' => 'required|string|unique:shipping_rates',
            'tarif' => 'required|numeric|min:0',
        ]);

        $rate = ShippingRate::create($request->all());
        return response()->json(['message' => 'Tarif ongkir berhasil ditambahkan!', 'data' => $rate], 201);
    }

    // Admin Action: Update Ongkir (API)
    public function update(Request $request, $id)
    {
        $rate = ShippingRate::findOrFail($id);

        $request->validate([
            'wilayah' => 'required|string|unique:shipping_rates,wilayah,' . $id,
            'tarif' => 'required|numeric|min:0',
        ]);

        $rate->update($request->all());
        return response()->json(['message' => 'Tarif ongkir berhasil diperbarui!', 'data' => $rate], 200);
    }

    // Admin Action: Hapus Ongkir (API)
    public function destroy($id)
    {
        ShippingRate::findOrFail($id)->delete();
        return response()->json(['message' => 'Tarif ongkir berhasil dihapus!'], 200);
    }
}
