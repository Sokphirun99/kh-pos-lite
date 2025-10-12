<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OrderItem;
use Illuminate\Http\Request;

class OrderItemController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $perPage = (int) request('per_page', 50);
        $perPage = $perPage > 0 && $perPage <= 100 ? $perPage : 50;
        $orderId = request('order_id');
        $query = OrderItem::query()->with(['product', 'order']);
        if ($orderId) {
            $query->where('order_id', $orderId);
        }
        return $query->orderByDesc('id')->paginate($perPage);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'order_id' => ['required', 'exists:orders,id'],
            'product_id' => ['required', 'exists:products,id'],
            'quantity' => ['required', 'integer', 'min:1'],
            'unit_price' => ['required', 'numeric', 'min:0'],
            'line_total' => ['nullable', 'numeric', 'min:0'],
        ]);
        $data['line_total'] = $data['line_total'] ?? ($data['quantity'] * $data['unit_price']);
        $item = OrderItem::create($data);
        return response()->json($item->load(['product']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(OrderItem $orderItem)
    {
        return $orderItem->load(['product', 'order']);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, OrderItem $orderItem)
    {
        $data = $request->validate([
            'quantity' => ['sometimes', 'required', 'integer', 'min:1'],
            'unit_price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'line_total' => ['nullable', 'numeric', 'min:0'],
        ]);
        $orderItem->fill($data);
        if (! array_key_exists('line_total', $data)) {
            $orderItem->line_total = $orderItem->quantity * $orderItem->unit_price;
        }
        $orderItem->save();
        return $orderItem->load(['product']);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(OrderItem $orderItem)
    {
        $orderItem->delete();
        return response()->noContent();
    }
}
