<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CustomerController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $perPage = (int) request('per_page', 15);
        $perPage = $perPage > 0 && $perPage <= 100 ? $perPage : 15;
        $q = request('q');

        $query = Customer::query();
        if ($q) {
            $qLike = "%$q%";
            $query->where(fn($w) => $w
                ->where('name', 'ilike', $qLike)
                ->orWhere('email', 'ilike', $qLike)
                ->orWhere('phone', 'ilike', $qLike)
            );
        }
        return $query->orderBy('name')->paginate($perPage);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:64'],
            'email' => ['nullable', 'email', 'max:255', Rule::unique('customers', 'email')],
            'address' => ['nullable', 'string'],
        ]);

        $customer = Customer::create($data);
        return response()->json($customer, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Customer $customer)
    {
        return $customer;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Customer $customer)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:64'],
            'email' => ['nullable', 'email', 'max:255', Rule::unique('customers', 'email')->ignore($customer->id)],
            'address' => ['nullable', 'string'],
        ]);

        $customer->update($data);
        return $customer;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Customer $customer)
    {
        if ($customer->orders()->exists()) {
            return response()->json(['message' => 'Cannot delete customer with orders'], 422);
        }
        $customer->delete();
        return response()->noContent();
    }
}
