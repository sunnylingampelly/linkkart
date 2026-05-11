<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AnalyticsEvent;
use App\Models\Store;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AnalyticsController extends Controller
{
    /**
     * Track an analytics event.
     */
    public function track(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'store_id' => 'required|exists:stores,id',
            'product_id' => 'nullable|exists:products,id',
            'event_type' => 'required|in:store_view,product_click,whatsapp_click',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        $data['ip_address'] = $request->ip();
        $data['user_agent'] = $request->userAgent();

        $event = AnalyticsEvent::create($data);

        // Update counters
        if ($data['event_type'] === 'store_view') {
            Store::find($data['store_id'])->incrementViewCount();
        } elseif ($data['event_type'] === 'product_click' && isset($data['product_id'])) {
            Product::find($data['product_id'])->incrementClickCount();
        }

        return response()->json([
            'success' => true,
            'message' => 'Event tracked successfully',
            'data' => $event,
        ], 201);
    }

    /**
     * Get analytics for a store.
     */
    public function storeAnalytics($storeId)
    {
        $store = Store::findOrFail($storeId);

        $analytics = [
            'overview' => [
                'total_views' => $store->view_count,
                'total_products' => $store->products()->count(),
                'total_clicks' => $store->products()->sum('click_count'),
                'active_products' => $store->products()->where('is_active', true)->count(),
            ],
            'events_by_type' => AnalyticsEvent::where('store_id', $storeId)
                ->select('event_type', DB::raw('count(*) as count'))
                ->groupBy('event_type')
                ->get(),
            'daily_views' => AnalyticsEvent::where('store_id', $storeId)
                ->where('event_type', 'store_view')
                ->where('created_at', '>=', now()->subDays(30))
                ->select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
                ->groupBy('date')
                ->orderBy('date')
                ->get(),
            'top_products' => Product::where('store_id', $storeId)
                ->orderBy('click_count', 'desc')
                ->take(5)
                ->get(),
            'recent_events' => AnalyticsEvent::where('store_id', $storeId)
                ->with('product')
                ->latest()
                ->take(20)
                ->get(),
        ];

        return response()->json([
            'success' => true,
            'data' => $analytics,
        ]);
    }

    /**
     * Get global analytics (admin).
     */
    public function globalAnalytics()
    {
        $analytics = [
            'overview' => [
                'total_stores' => Store::count(),
                'active_stores' => Store::where('is_active', true)->count(),
                'total_products' => Product::count(),
                'total_views' => Store::sum('view_count'),
                'total_clicks' => Product::sum('click_count'),
            ],
            'stores_by_date' => Store::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
                ->where('created_at', '>=', now()->subDays(30))
                ->groupBy('date')
                ->orderBy('date')
                ->get(),
            'products_by_date' => Product::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
                ->where('created_at', '>=', now()->subDays(30))
                ->groupBy('date')
                ->orderBy('date')
                ->get(),
            'top_stores' => Store::withCount('products')
                ->orderBy('view_count', 'desc')
                ->take(10)
                ->get(),
            'recent_stores' => Store::with('products')
                ->latest()
                ->take(10)
                ->get(),
        ];

        return response()->json([
            'success' => true,
            'data' => $analytics,
        ]);
    }
}
