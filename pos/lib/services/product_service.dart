import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _productsCollection => 
      _firestore.collection('products');

  // Get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Add new product
  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _productsCollection.add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update existing product
  Future<void> updateProduct(Product product) async {
    try {
      await _productsCollection.doc(product.id).update(
        product.copyWith(updatedAt: DateTime.now()).toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get single product
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // Get all products as stream
  Stream<List<Product>> getProducts() {
    return _productsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Search products by name or SKU
  Stream<List<Product>> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _productsCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((product) =>
                product.name.toLowerCase().contains(lowerQuery) ||
                product.sku.toLowerCase().contains(lowerQuery))
            .toList());
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _productsCollection
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Get low stock products
  Stream<List<Product>> getLowStockProducts() {
    return _productsCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((product) => product.isLowStock)
            .toList());
  }

  // Generate unique SKU
  Future<String> generateSKU() async {
    try {
      final snapshot = await _productsCollection
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      int nextNumber = 1;
      if (snapshot.docs.isNotEmpty) {
        final lastProduct = Product.fromFirestore(snapshot.docs.first);
        // Extract number from SKU (assuming format like SKU-00001)
        final lastSKU = lastProduct.sku;
        final numbers = RegExp(r'\d+').allMatches(lastSKU);
        if (numbers.isNotEmpty) {
          final lastNumber = int.tryParse(numbers.last.group(0) ?? '0') ?? 0;
          nextNumber = lastNumber + 1;
        }
      }
      
      return 'SKU-${nextNumber.toString().padLeft(5, '0')}';
    } catch (e) {
      // Fallback to timestamp-based SKU
      return 'SKU-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Check if SKU already exists
  Future<bool> skuExists(String sku, {String? excludeProductId}) async {
    try {
      final query = await _productsCollection
          .where('sku', isEqualTo: sku)
          .get();
      
      if (excludeProductId != null) {
        // Exclude current product when editing
        return query.docs.any((doc) => doc.id != excludeProductId);
      }
      
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _productsCollection.get();
      final categories = snapshot.docs
          .map((doc) => Product.fromFirestore(doc).category)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    } catch (e) {
      return [];
    }
  }

  // Update stock quantity (used by inventory service)
  Future<void> updateStock(String productId, int newQuantity) async {
    try {
      await _productsCollection.doc(productId).update({
        'stockQuantity': newQuantity,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }
}
