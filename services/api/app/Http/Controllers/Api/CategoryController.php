<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $perPage = (int) request('per_page', 50);
        $perPage = $perPage > 0 && $perPage <= 100 ? $perPage : 50;
        $q = request('q');
        $parentId = request('parent_id');

        $query = Category::query()->withCount('children');
        if ($q) {
            $query->where('name', 'ilike', "%$q%");
        }
        if ($parentId !== null) {
            $query->where('parent_id', $parentId);
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
            'parent_id' => ['nullable', 'exists:categories,id'],
        ]);

        $category = Category::create($data);
        return response()->json($category, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Category $category)
    {
        return $category->load('children');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'parent_id' => ['nullable', Rule::exists('categories', 'id')->whereNot('id', $category->id)],
        ]);

        $category->update($data);
        return $category->load('children');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Category $category)
    {
        // Optionally: prevent delete if has children or products
        if ($category->children()->exists()) {
            return response()->json(['message' => 'Cannot delete category with children'], 422);
        }
        $category->delete();
        return response()->noContent();
    }
}
