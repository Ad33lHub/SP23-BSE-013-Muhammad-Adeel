import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'customers';

  // Add new customer
  Future<String> addCustomer(Customer customer) async {
    try {
      // Check if phone already exists
      final existing = await _firestore
          .collection(_collection)
          .where('phone', isEqualTo: customer.phone)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Customer with this phone number already exists');
      }

      final docRef = await _firestore.collection(_collection).add(customer.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(customer.id)
          .update(customer.toFirestore());
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection(_collection).doc(customerId).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Get all customers
  Stream<List<Customer>> getCustomers() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  // Get single customer
  Future<Customer?> getCustomer(String customerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(customerId).get();
      if (doc.exists) {
        return Customer.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  // Search customers by name or phone
  Stream<List<Customer>> searchCustomers(String query) {
    if (query.isEmpty) {
      return getCustomers();
    }

    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  // Get customer's purchase history
  Future<List<Sale>> getCustomerSales(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('sales')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get customer sales: $e');
    }
  }

  // Update customer statistics (after sale)
  Future<void> updateCustomerStats({
    required String customerId,
    required double amount,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(customerId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Customer not found');
        }

        final currentPurchases = (snapshot.data()?['totalPurchases'] ?? 0).toDouble();
        final currentOrders = snapshot.data()?['totalOrders'] ?? 0;

        transaction.update(docRef, {
          'totalPurchases': currentPurchases + amount,
          'totalOrders': currentOrders + 1,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update customer stats: $e');
    }
  }

  // Update customer balance
  Future<void> updateCustomerBalance({
    required String customerId,
    required double balanceChange,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(customerId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Customer not found');
        }

        final currentBalance = (snapshot.data()?['outstandingBalance'] ?? 0).toDouble();
        final newBalance = currentBalance + balanceChange;

        if (newBalance < 0) {
          throw Exception('Payment exceeds outstanding balance');
        }

        transaction.update(docRef, {
          'outstandingBalance': newBalance,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update customer balance: $e');
    }
  }

  // Get customers by type
  Stream<List<Customer>> getCustomersByType(CustomerType type) {
    return _firestore
        .collection(_collection)
        .where('customerType', isEqualTo: type.name)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  // Get customers with outstanding balance
  Stream<List<Customer>> getCustomersWithBalance() {
    return _firestore
        .collection(_collection)
        .where('outstandingBalance', isGreaterThan: 0)
        .orderBy('outstandingBalance', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }
}
