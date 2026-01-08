import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  Product? _selectedProduct;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get filtered products based on search and category
  List<Product> get filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(query) ||
        p.sku.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  // Get low stock products
  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  // Get all categories
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set selected product
  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // Load products
  void loadProducts() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _productService.getProducts().listen(
      (products) {
        _products = products;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add product
  Future<bool> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _productService.addProduct(product);
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _productService.updateProduct(product);
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _productService.deleteProduct(productId);
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Generate SKU
  Future<String> generateSKU() async {
    return await _productService.generateSKU();
  }

  // Check if SKU exists
  Future<bool> skuExists(String sku, {String? excludeProductId}) async {
    return await _productService.skuExists(sku, excludeProductId: excludeProductId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
