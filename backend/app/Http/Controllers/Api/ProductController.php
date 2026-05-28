<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Display a listing of products for a store.
     */
    public function index(Request $request, $storeId = null)
    {
        $query = Product::with('store');

        if ($storeId) {
            $query->where('store_id', $storeId);
        }

        $perPage = $request->get('per_page', 15);
        $products = $query->latest()->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $products,
        ]);
    }

    /**
     * Store a newly created product.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'store_id' => 'required|exists:stores,id',
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'description' => 'nullable|string',
            'stock_quantity' => 'nullable|integer|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'has_sizes' => 'nullable|boolean',
            'sizes' => 'nullable|json',
            'size_chart_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        
        // Check product limit based on subscription plan
        $store = Store::findOrFail($data['store_id']);
        $plan = $store->current_plan;
        
        if ($plan && $store->products()->count() >= $plan->product_limit) {
            return response()->json([
                'success' => false,
                'message' => 'Product limit reached for your current plan (' . $plan->name . '). Please upgrade to add more products.',
                'limit_reached' => true,
                'current_limit' => $plan->product_limit
            ], 403);
        }

        // Set default stock quantity if not provided
        if (!isset($data['stock_quantity'])) {
            $data['stock_quantity'] = 0;
        }

        // Handle image upload
        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $imagePath = $image->store('products', 'public');
            $data['image'] = Storage::url($imagePath);
        }

        // Handle size chart image upload
        if ($request->hasFile('size_chart_image')) {
            $image = $request->file('size_chart_image');
            $imagePath = $image->store('products/charts', 'public');
            $data['size_chart_image'] = Storage::url($imagePath);
        }

        // Decode sizes if it's a string
        if (isset($data['sizes']) && is_string($data['sizes'])) {
            $data['sizes'] = json_decode($data['sizes'], true);
        }

        $product = Product::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => $product->load('store'),
        ], 201);
    }

    /**
     * Display the specified product.
     */
    public function show(Product $product)
    {
        return response()->json([
            'success' => true,
            'data' => $product->load('store'),
        ]);
    }

    /**
     * Update the specified product.
     */
    public function update(Request $request, Product $product)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'price' => 'sometimes|required|numeric|min:0',
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'is_active' => 'sometimes|boolean',
            'has_sizes' => 'sometimes|boolean',
            'sizes' => 'sometimes|json',
            'size_chart_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'stock_quantity' => 'sometimes|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        // Handle image upload
        if ($request->hasFile('image')) {
            // Delete old image
            if ($product->image) {
                $oldPath = str_replace('/storage/', '', $product->image);
                Storage::disk('public')->delete($oldPath);
            }

            $image = $request->file('image');
            $imagePath = $image->store('products', 'public');
            $data['image'] = Storage::url($imagePath);
        } else {
            // Ensure we don't overwrite with null if it's not a file
            unset($data['image']);
        }

        // Handle size chart image upload
        if ($request->hasFile('size_chart_image')) {
            // Delete old size chart image
            if ($product->size_chart_image) {
                $oldPath = str_replace('/storage/', '', $product->size_chart_image);
                Storage::disk('public')->delete($oldPath);
            }

            $image = $request->file('size_chart_image');
            $imagePath = $image->store('products/charts', 'public');
            $data['size_chart_image'] = Storage::url($imagePath);
        } else {
            // Ensure we don't overwrite with null if it's not a file
            unset($data['size_chart_image']);
        }

        // Decode sizes if it's a string
        if (isset($data['sizes']) && is_string($data['sizes'])) {
            $decodedSizes = json_decode($data['sizes'], true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $data['sizes'] = $decodedSizes;
                
                // Explicitly sync stock_quantity if sizes are provided
                if (is_array($data['sizes'])) {
                    $data['stock_quantity'] = array_sum($data['sizes']);
                }
            }
        }

        $product->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product->fresh()->load('store'),
        ]);
    }

    /**
     * Remove the specified product.
     */
    public function destroy(Product $product)
    {
        // Delete image
        if ($product->image) {
            $imagePath = str_replace('/storage/', '', $product->image);
            Storage::disk('public')->delete($imagePath);
        }

        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully',
        ]);
    }

    /**
     * Get products by store slug.
     */
    public function byStore($storeSlug)
    {
        $store = Store::where('slug', $storeSlug)->firstOrFail();
        $products = $store->products()->where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'store' => $store,
                'products' => $products,
            ],
        ]);
    }
}
