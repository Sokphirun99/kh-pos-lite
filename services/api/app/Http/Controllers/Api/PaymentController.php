<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $perPage = (int) request('per_page', 50);
        $perPage = $perPage > 0 && $perPage <= 100 ? $perPage : 50;
        $orderId = request('order_id');
        $query = Payment::query()->with('order');
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
            'amount' => ['required', 'numeric', 'min:0.01'],
            'method' => ['required', 'string', 'max:32'],
            'reference' => ['nullable', 'string', 'max:255'],
            'paid_at' => ['nullable', 'date'],
        ]);
        $payment = Payment::create($data);
        return response()->json($payment->load('order'), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Payment $payment)
    {
        return $payment->load('order');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Payment $payment)
    {
        $data = $request->validate([
            'amount' => ['sometimes', 'required', 'numeric', 'min:0.01'],
            'method' => ['sometimes', 'required', 'string', 'max:32'],
            'reference' => ['nullable', 'string', 'max:255'],
            'paid_at' => ['nullable', 'date'],
        ]);
        $payment->update($data);
        return $payment->load('order');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Payment $payment)
    {
        $payment->delete();
        return response()->noContent();
    }
}
