<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Store extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'phone',
        'logo',
        'slug',
        'is_active',
        'view_count',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'view_count' => 'integer',
    ];

    protected $appends = ['store_url', 'product_count'];

    /**
     * Boot the model.
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($store) {
            if (empty($store->slug)) {
                $store->slug = Str::slug($store->name) . '-' . Str::random(6);
            }
        });
    }

    /**
     * Get the products for the store.
     */
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    /**
     * Get the analytics events for the store.
     */
    public function analyticsEvents()
    {
        return $this->hasMany(AnalyticsEvent::class);
    }

    /**
     * Get the store URL attribute.
     */
    public function getStoreUrlAttribute()
    {
        return config('app.storefront_url') . '/store/' . $this->slug;
    }

    /**
     * Get the product count attribute.
     */
    public function getProductCountAttribute()
    {
        return $this->products()->count();
    }

    /**
     * Increment view count.
     */
    public function incrementViewCount()
    {
        $this->increment('view_count');
    }

    /**
     * Get active products.
     */
    public function activeProducts()
    {
        return $this->products()->where('is_active', true);
    }
}
