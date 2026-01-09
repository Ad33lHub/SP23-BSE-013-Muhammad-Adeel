import 'package:flutter/foundation.dart';
import '../models/ledger_entry.dart';
import '../models/customer.dart';
import '../services/ledger_service.dart';
import '../services/customer_service.dart';

class LedgerProvider with ChangeNotifier {
  final LedgerService _ledgerService = LedgerService();
  final CustomerService _customerService = CustomerService();
  
  List<LedgerEntry> _entries = [];
  List<Customer> _customersWithBalance = [];
  double _totalOutstanding = 0;
  int _outstandingCustomersCount = 0;
  double _todayPayments = 0;
  String? _error;
  bool _isLoading = false;

  // Getters
  List<LedgerEntry> get entries => _entries;
  List<Customer> get customersWithBalance => _customersWithBalance;
  double get totalOutstanding => _totalOutstanding;
  int get outstandingCustomersCount => _outstandingCustomersCount;
  double get todayPayments => _todayPayments;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Load customer ledger
  void loadCustomerLedger(String customerId) {
    _ledgerService.getCustomerLedger(customerId).listen(
      (entries) {
        _entries = entries;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load all ledger entries
  void loadAllEntries() {
    _ledgerService.getAllLedgerEntries().listen(
      (entries) {
        _entries = entries;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load customers with balance
  void loadCustomersWithBalance() {
    _customerService.getCustomersWithBalance().listen(
      (customers) {
        _customersWithBalance = customers;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load summary data
  Future<void> loadSummary() async {
    try {
      _totalOutstanding = await _ledgerService.getTotalOutstanding();
      _outstandingCustomersCount = await _ledgerService.getOutstandingCustomersCount();
      _todayPayments = await _ledgerService.getTodayPayments();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Create credit sale (debit entry)
  Future<bool> createCreditSale({
    required String customerId,
    required String customerName,
    required double amount,
    required String saleId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ledgerService.createDebitEntry(
        customerId: customerId,
        customerName: customerName,
        amount: amount,
        saleId: saleId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Record payment (credit entry)
  Future<bool> recordPayment({
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ledgerService.createCreditEntry(
        customerId: customerId,
        customerName: customerName,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get customer balance
  Future<double> getCustomerBalance(String customerId) async {
    try {
      return await _ledgerService.getCustomerBalance(customerId);
    } catch (e) {
      return 0;
    }
  }
}
