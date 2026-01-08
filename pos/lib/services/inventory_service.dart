import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_transaction.dart';
import '../models/product.dart';
import 'product_service.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductService _productService = ProductService();

  // Collection reference
  CollectionReference get _transactionsCollection =>
      _firestore.collection('stockTransactions');

  // Get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Stock In operation
  Future<void> stockIn({
    required String productId,
    required int quantity,
    String notes = '',
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    try {
      // Get current product
      final product = await _productService.getProduct(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      final previousStock = product.stockQuantity;
      final newStock = previousStock + quantity;

      // Create transaction record
      final transaction = StockTransaction(
        id: '',
        productId: productId,
        productName: product.name,
        type: TransactionType.stockIn,
        quantity: quantity,
        previousStock: previousStock,
        newStock: newStock,
        notes: notes,
        createdAt: DateTime.now(),
        createdBy: _currentUserId,
      );

      // Use batch write for atomic operation
      final batch = _firestore.batch();

      // Add transaction
      final transactionRef = _transactionsCollection.doc();
      batch.set(transactionRef, transaction.toFirestore());

      // Update product stock
      final productRef = _firestore.collection('products').doc(productId);
      batch.update(productRef, {
        'stockQuantity': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to stock in: $e');
    }
  }

  // Stock Out operation
  Future<void> stockOut({
    required String productId,
    required int quantity,
    String notes = '',
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    try {
      // Get current product
      final product = await _productService.getProduct(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      final previousStock = product.stockQuantity;
      
      // Check if enough stock available
      if (previousStock < quantity) {
        throw Exception(
          'Insufficient stock. Available: $previousStock, Requested: $quantity'
        );
      }

      final newStock = previousStock - quantity;

      // Create transaction record
      final transaction = StockTransaction(
        id: '',
        productId: productId,
        productName: product.name,
        type: TransactionType.stockOut,
        quantity: quantity,
        previousStock: previousStock,
        newStock: newStock,
        notes: notes,
        createdAt: DateTime.now(),
        createdBy: _currentUserId,
      );

      // Use batch write for atomic operation
      final batch = _firestore.batch();

      // Add transaction
      final transactionRef = _transactionsCollection.doc();
      batch.set(transactionRef, transaction.toFirestore());

      // Update product stock
      final productRef = _firestore.collection('products').doc(productId);
      batch.update(productRef, {
        'stockQuantity': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to stock out: $e');
    }
  }

  // Get stock history for a specific product
  Stream<List<StockTransaction>> getStockHistory(String productId) {
    return _transactionsCollection
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockTransaction.fromFirestore(doc))
            .toList());
  }

  // Get all stock transactions
  Stream<List<StockTransaction>> getAllStockHistory() {
    return _transactionsCollection
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockTransaction.fromFirestore(doc))
            .toList());
  }

  // Get stock history by date range
  Stream<List<StockTransaction>> getStockHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _transactionsCollection
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockTransaction.fromFirestore(doc))
            .toList());
  }

  // Get stock history by type
  Stream<List<StockTransaction>> getStockHistoryByType(TransactionType type) {
    final typeString = type == TransactionType.stockIn ? 'stock_in' : 'stock_out';
    return _transactionsCollection
        .where('type', isEqualTo: typeString)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockTransaction.fromFirestore(doc))
            .toList());
  }

  // Get recent transactions (last 20)
  Stream<List<StockTransaction>> getRecentTransactions({int limit = 20}) {
    return _transactionsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockTransaction.fromFirestore(doc))
            .toList());
  }
}
