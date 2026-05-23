<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'store_id',
        'product_id',
        'name',
        'price',
        'description',
        'image',
        'images',
        'stock_quantity',
        'is_active',
        'click_count',
        'sizes',
        'has_sizes',
        'size_chart_image',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'is_active' => 'boolean',
        'has_sizes' => 'boolean',
        'click_count' => 'integer',
        'stock_quantity' => 'integer',
        'images' => 'array', // Cast JSON to array
        'sizes' => 'array', // Cast JSON to array
    ];

    protected $appends = ['formatted_price', 'whatsapp_url'];

    /**
     * Boot the model and generate product_id automatically.
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($product) {
            if (empty($product->product_id)) {
                // Generate unique product ID: LK-0001, LK-0002, etc.
                // Get the last product_id and increment
                $lastProduct = static::withTrashed()
                    ->whereNotNull('product_id')
                    ->orderBy('product_id', 'desc')
                    ->first();
                
                if ($lastProduct && $lastProduct->product_id) {
                    // Extract number from LK-0001 format
                    $lastNumber = (int) substr($lastProduct->product_id, 3);
                    $nextId = $lastNumber + 1;
                } else {
                    $nextId = 1;
                }
                
                $product->product_id = 'LK-' . str_pad($nextId, 4, '0', STR_PAD_LEFT);
            }

            // Sync stock quantity with sizes if applicable
            if ($product->has_sizes && is_array($product->sizes)) {
                $product->stock_quantity = array_sum($product->sizes);
            }
        });

        static::updating(function ($product) {
            // Sync stock quantity with sizes if applicable
            if ($product->has_sizes && is_array($product->sizes)) {
                $product->stock_quantity = array_sum($product->sizes);
            }
        });
    }

    /**
     * Get the store that owns the product.
     */
    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    /**
     * Get the analytics events for the product.
     */
    public function analyticsEvents()
    {
        return $this->hasMany(AnalyticsEvent::class);
    }

    /**
     * Get the formatted price attribute.
     */
    public function getFormattedPriceAttribute()
    {
        return '₹' . number_format($this->price, 2);
    }

    /**
     * Get the WhatsApp URL attribute.
     */
    public function getWhatsappUrlAttribute()
    {
        $message = urlencode("Hi, I want to order {$this->name} - {$this->formatted_price}");
        $phone = preg_replace('/[^0-9]/', '', $this->store->phone);
        return "https://wa.me/{$phone}?text={$message}";
    }

    /**
     * Increment click count.
     */
    public function incrementClickCount()
    {
        $this->increment('click_count');
    }

    /**
     * Scope a query to only include active products.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
