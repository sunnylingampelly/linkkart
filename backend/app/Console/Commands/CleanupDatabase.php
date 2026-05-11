<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class CleanupDatabase extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:cleanup';
    protected $description = 'Cleanup all stores and products for a fresh start';

    public function handle()
    {
        $this->info('Cleaning up database...');
        
        \Schema::disableForeignKeyConstraints();
        \DB::table('products')->truncate();
        \DB::table('orders')->truncate();
        \DB::table('customers')->truncate();
        \DB::table('stores')->truncate();
        \Schema::enableForeignKeyConstraints();
        
        $this->info('Database cleaned successfully!');
        return 0;
    }
}
