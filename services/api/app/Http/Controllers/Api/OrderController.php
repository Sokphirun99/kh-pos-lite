<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $perPage = (int) request('per_page', 15);
        $perPage = $perPage > 0 && $perPage <= 100 ? $perPage : 15;
        $status = request('status');
        $customerId = request('customer_id');

        $query = Order::query()->with(['customer'])->withCount(['items', 'payments']);
        if ($status) {
            $query->where('status', $status);
        }
        if ($customerId) {
            $query->where('customer_id', $customerId);
        }

        return $query->orderByDesc('id')->paginate($perPage);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'number' => ['nullable', 'string', 'max:64', 'unique:orders,number'],
            'customer_id' => ['nullable', 'exists:customers,id'],
            'status' => ['nullable', 'string', 'max:32'],
            'subtotal' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'total' => ['nullable', 'numeric', 'min:0'],
            'paid_at' => ['nullable', 'date'],
        ]);

        if (empty($data['number'])) {
            $data['number'] = 'ORD-'.now()->format('Ymd').'-'.Str::upper(Str::random(5));
        }

        $data['status'] = $data['status'] ?? 'draft';

        $order = Order::create($data);
        return response()->json($order->load(['customer']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Order $order)
    {
        return $order->load(['customer', 'items.product', 'payments']);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Order $order)
    {
        $data = $request->validate([
            'number' => ['sometimes', 'required', 'string', 'max:64', 'unique:orders,number,'.$order->id],
            'customer_id' => ['nullable', 'exists:customers,id'],
            'status' => ['nullable', 'string', 'max:32'],
            'subtotal' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'total' => ['nullable', 'numeric', 'min:0'],
            'paid_at' => ['nullable', 'date'],
        ]);

        $order->update($data);
        return $order->load(['customer']);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Order $order)
    {
        if ($order->payments()->exists()) {
            return response()->json(['message' => 'Cannot delete order with payments'], 422);
        }
        $order->delete();
        return response()->noContent();
    }
}
