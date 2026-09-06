<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@vendorhub.com'],
            [
                'first_name' => 'Admin',
                'last_name' => 'VendorHub',
                'phone' => '+15550000000',
                'password' => Hash::make('Password@123'),
                'role' => 'admin',
                'email_verified_at' => now(),
                'status' => 'active',
                'email_notifications' => true,
                'push_notifications' => true,
                'sms_notifications' => false,
                'language' => 'en',
                'timezone' => 'UTC',
            ]
        );
    }
}
