import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ledger_entry.dart';
import 'customer_service.dart';

class LedgerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustomerService _customerService = CustomerService();
  final String _collection = 'ledgerEntries';

  // Create debit entry (credit sale - customer owes money)
  Future<void> createDebitEntry({
    required String customerId,
    required String customerName,
    required double amount,
    required String saleId,
  }) async {
    try {
      // Get current balance
      final customer = await _customerService.getCustomer(customerId);
      if (customer == null) {
        throw Exception('Customer not found');
      }

      final newBalance = customer.outstandingBalance + amount;

      final entry = LedgerEntry(
        id: '',
        customerId: customerId,
        customerName: customerName,
        type: LedgerEntryType.debit,
        amount: amount,
        balance: newBalance,
        description: 'Credit sale - Sale #$saleId',
        saleId: saleId,
        createdAt: DateTime.now(),
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      // Create entry and update customer balance atomically
      final batch = _firestore.batch();

      final entryRef = _firestore.collection(_collection).doc();
      batch.set(entryRef, entry.copyWith(id: entryRef.id).toFirestore());

      final customerRef = _firestore.collection('customers').doc(customerId);
      batch.update(customerRef, {
        'outstandingBalance': newBalance,
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create debit entry: $e');
    }
  }

  // Create credit entry (payment - customer pays money)
  Future<void> createCreditEntry({
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // Get current balance
      final customer = await _customerService.getCustomer(customerId);
      if (customer == null) {
        throw Exception('Customer not found');
      }

      if (amount > customer.outstandingBalance) {
        throw Exception('Payment amount exceeds outstanding balance');
      }

      final newBalance = customer.outstandingBalance - amount;

      final entry = LedgerEntry(
        id: '',
        customerId: customerId,
        customerName: customerName,
        type: LedgerEntryType.credit,
        amount: amount,
        balance: newBalance,
        description: notes ?? 'Payment received - $paymentMethod',
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      // Create entry and update customer balance atomically
      final batch = _firestore.batch();

      final entryRef = _firestore.collection(_collection).doc();
      batch.set(entryRef, entry.copyWith(id: entryRef.id).toFirestore());

      final customerRef = _firestore.collection('customers').doc(customerId);
      batch.update(customerRef, {
        'outstandingBalance': newBalance,
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create credit entry: $e');
    }
  }

  // Get ledger entries for a customer
  Stream<List<LedgerEntry>> getCustomerLedger(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LedgerEntry.fromFirestore(doc)).toList());
  }

  // Get all ledger entries (admin view)
  Stream<List<LedgerEntry>> getAllLedgerEntries() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LedgerEntry.fromFirestore(doc)).toList());
  }

  // Get customer balance from ledger (calculated)
  Future<double> getCustomerBalance(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      final lastEntry = LedgerEntry.fromFirestore(snapshot.docs.first);
      return lastEntry.balance;
    } catch (e) {
      return 0;
    }
  }

  // Get total outstanding (sum of all customer balances)
  Future<double> getTotalOutstanding() async {
    try {
      final snapshot = await _firestore.collection('customers').get();
      
      double total = 0;
      for (final doc in snapshot.docs) {
        final balance = (doc.data()['outstandingBalance'] ?? 0).toDouble();
        total += balance;
      }
      
      return total;
    } catch (e) {
      return 0;
    }
  }

  // Get today's payments (credit entries)
  Future<double> getTodayPayments() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: 'credit')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  // Get count of customers with outstanding balance
  Future<int> getOutstandingCustomersCount() async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .where('outstandingBalance', isGreaterThan: 0)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
