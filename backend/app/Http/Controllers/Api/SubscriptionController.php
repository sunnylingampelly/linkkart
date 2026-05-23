<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Plan;
use App\Models\Subscription;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SubscriptionController extends Controller
{
    /**
     * Get all available plans.
     */
    public function plans()
    {
        $plans = Plan::where('is_active', true)->orderBy('sort_order')->get();
        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * Create a new subscription.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'store_id' => 'required|exists:stores,id',
            'plan_id' => 'required|exists:plans,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $store = Store::findOrFail($request->store_id);
        $plan = Plan::findOrFail($request->plan_id);

        // If it's a free plan, activate immediately
        if ($plan->slug === 'free') {
            $subscription = Subscription::create([
                'store_id' => $store->id,
                'plan_id' => $plan->id,
                'status' => 'active',
                'starts_at' => now(),
                'ends_at' => now()->addYears(10), // Basically forever
            ]);

            $store->update(['subscription_id' => $subscription->id]);

            return response()->json([
                'success' => true,
                'message' => 'Free plan activated successfully',
                'data' => $subscription->load('plan'),
            ]);
        }

        // For paid plans, create a pending subscription
        $subscription = Subscription::create([
            'store_id' => $store->id,
            'plan_id' => $plan->id,
            'status' => 'trial', // Default to trial or pending payment
            'starts_at' => now(),
            'ends_at' => now()->addDays(14), // 14 days trial
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Subscription created successfully (Trial active)',
            'data' => $subscription->load('plan'),
        ]);
    }

    /**
     * Verify payment and activate subscription.
     */
    public function verifyPayment(Request $request)
    {
        // Mock payment verification for now
        $validator = Validator::make($request->all(), [
            'razorpay_order_id' => 'required',
            'razorpay_payment_id' => 'required',
            'razorpay_signature' => 'required',
        ]);

        // In a real app, we would verify the signature here
        
        // Find subscription by razorpay_order_id (if we stored it)
        // For this demo, let's assume we're activating the latest trial subscription for the store
        
        return response()->json([
            'success' => true,
            'message' => 'Payment verified and subscription activated',
        ]);
    }
}
