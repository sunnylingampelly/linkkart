<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnalyticsEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'store_id',
        'product_id',
        'event_type',
        'ip_address',
        'user_agent',
        'metadata',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    /**
     * Get the store that owns the event.
     */
    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    /**
     * Get the product that owns the event.
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Scope a query to only include store views.
     */
    public function scopeStoreViews($query)
    {
        return $query->where('event_type', 'store_view');
    }

    /**
     * Scope a query to only include product clicks.
     */
    public function scopeProductClicks($query)
    {
        return $query->where('event_type', 'product_click');
    }

    /**
     * Scope a query to only include WhatsApp clicks.
     */
    public function scopeWhatsappClicks($query)
    {
        return $query->where('event_type', 'whatsapp_click');
    }
}
