<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class StoreController extends Controller
{
    /**
     * Display a listing of stores.
     */
    public function index(Request $request)
    {
        $perPage = $request->get('per_page', 15);
        $stores = Store::with('products')
            ->withCount('products')
            ->latest()
            ->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $stores,
        ]);
    }

    /**
     * Store a newly created store.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        // Handle logo upload
        if ($request->hasFile('logo')) {
            $logo = $request->file('logo');
            $logoPath = $logo->store('logos', 'public');
            $data['logo'] = Storage::url($logoPath);
        }

        $store = Store::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Store created successfully',
            'data' => $store->load('products'),
        ], 201);
    }

    /**
     * Display the specified store.
     */
    public function show($identifier)
    {
        // Find by ID or slug
        $store = Store::where('id', $identifier)
            ->orWhere('slug', $identifier)
            ->with(['products' => function ($query) {
                $query->where('is_active', true);
            }])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $store,
        ]);
    }

    /**
     * Update the specified store.
     */
    public function update(Request $request, $id)
    {
        // Manual find to avoid binding issues
        $store = Store::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'phone' => 'sometimes|required|string|max:20',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description' => 'nullable|string|max:1000',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        \Log::info('Store Update Hit', ['all' => $request->all(), 'files' => $request->allFiles()]);

        if (request()->hasFile('logo')) {
            // Delete old logo
            if ($store->logo) {
                $oldPath = str_replace('/storage/', '', $store->logo);
                Storage::disk('public')->delete($oldPath);
            }

            $logo = $request->file('logo');
            $logoPath = $logo->store('logos', 'public');
            $data['logo'] = Storage::url($logoPath);
        }

        $store->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Store updated successfully',
            'data' => $store->fresh()->load('products'),
        ]);
    }

    /**
     * Remove the specified store.
     */
    public function destroy(Store $store)
    {
        // Delete logo
        if ($store->logo) {
            $logoPath = str_replace('/storage/', '', $store->logo);
            Storage::disk('public')->delete($logoPath);
        }

        $store->delete();

        return response()->json([
            'success' => true,
            'message' => 'Store deleted successfully',
        ]);
    }

    /**
     * Get store statistics.
     */
    public function statistics(Store $store)
    {
        $stats = [
            'total_products' => $store->products()->count(),
            'active_products' => $store->products()->where('is_active', true)->count(),
            'total_views' => $store->view_count,
            'total_clicks' => $store->products()->sum('click_count'),
            'recent_events' => $store->analyticsEvents()
                ->latest()
                ->take(10)
                ->get(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Find a store by phone number.
     */
    public function findByPhone(Request $request)
    {
        $phone = $request->query('phone');
        
        if (!$phone) {
            return response()->json([
                'success' => false,
                'message' => 'Phone number is required',
            ], 400);
        }

        // Handle both formats (with/without +91)
        $cleanPhone = str_replace('+', '', $phone);
        $withPlus = '+' . $cleanPhone;
        
        $store = Store::where('phone', $cleanPhone)
            ->orWhere('phone', $withPlus)
            ->orWhere('phone', 'like', '%' . substr($cleanPhone, -10))
            ->latest()
            ->first();

        if (!$store) {
            return response()->json([
                'success' => false,
                'message' => 'No store found for this phone number',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $store,
        ]);
    }
}
