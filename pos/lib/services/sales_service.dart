import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import '../models/cart_item.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sales';

  // Generate unique sale number
  Future<String> generateSaleNumber() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'SALE-00001';
      }

      final lastSale = snapshot.docs.first.data() as Map<String, dynamic>;
      final lastNumber = lastSale['saleNumber'] as String;
      final numberPart = int.parse(lastNumber.split('-')[1]);
      final newNumber = numberPart + 1;

      return 'SALE-${newNumber.toString().padLeft(5, '0')}';
    } catch (e) {
      return 'SALE-00001';
    }
  }

  // Complete sale - save to Firestore and update stock
  Future<void> completeSale(Sale sale) async {
    final batch = _firestore.batch();

    try {
      // Add sale document
      final saleRef = _firestore.collection(_collection).doc();
      batch.set(saleRef, sale.copyWith(id: saleRef.id).toFirestore());

      // Update product stocks
      for (final item in sale.items) {
        final productRef = _firestore.collection('products').doc(item.product.id);
        batch.update(productRef, {
          'stockQuantity': FieldValue.increment(-item.quantity),
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to complete sale: $e');
    }
  }

  // Get all sales
  Stream<List<Sale>> getSales() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  // Get sales by date
  Stream<List<Sale>> getSalesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  // Get sales by date range
  Stream<List<Sale>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  // Get sale by ID
  Future<Sale?> getSale(String saleId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(saleId).get();
      if (doc.exists) {
        return Sale.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get sale: $e');
    }
  }

  // Get today's sales count
  Future<int> getTodaySalesCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final snapshot = await _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    
    return snapshot.docs.length;
  }

  // Get today's total revenue
  Future<double> getTodayRevenue() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final snapshot = await _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    
    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['totalAmount'] ?? 0).toDouble();
    }
    
    return total;
  }
}
