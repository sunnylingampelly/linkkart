<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Admin;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create default admin
        Admin::create([
            'name' => 'Admin',
            'email' => 'admin@linkkart.com',
            'password' => Hash::make('password'),
        ]);

        $this->command->info('Default admin created: admin@linkkart.com / password');
    }
}
