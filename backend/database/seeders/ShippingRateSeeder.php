<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\ShippingRate;

class ShippingRateSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $rates = [
            ['wilayah' => 'Jawa Barat (Tasikmalaya)', 'tarif' => 0],
            ['wilayah' => 'Jawa Barat (Luar Tasik)', 'tarif' => 15000],
            ['wilayah' => 'DKI Jakarta', 'tarif' => 20000],
            ['wilayah' => 'Luar Jawa Barat', 'tarif' => 25000],
            ['wilayah' => 'Luar Pulau Jawa', 'tarif' => 45000],
        ];

        foreach ($rates as $rate) {
            ShippingRate::create($rate);
        }
    }
}
