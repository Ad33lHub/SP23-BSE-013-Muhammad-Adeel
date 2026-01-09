import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  String _searchQuery = '';
  CustomerType? _filterType;
  String? _error;
  bool _isLoading = false;

  // Getters
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  String get searchQuery => _searchQuery;
  CustomerType? get filterType => _filterType;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Get filtered customers
  List<Customer> get filteredCustomers {
    var filtered = _customers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) =>
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.phone.contains(_searchQuery)).toList();
    }

    if (_filterType != null) {
      filtered = filtered.where((customer) => customer.customerType == _filterType).toList();
    }

    return filtered;
  }

  // Get customers with outstanding balance
  List<Customer>get customersWithBalance {
    return _customers.where((c) => c.hasBalance).toList()
      ..sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));
  }

  // Load customers
  void loadCustomers() {
    _customerService.getCustomers().listen(
      (customers) {
        _customers = customers;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set filter type
  void setFilterType(CustomerType? type) {
    _filterType = type;
    notifyListeners();
  }

  // Select customer (for POS)
  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Clear selected customer
  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // Add customer
  Future<bool> addCustomer(Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _customerService.addCustomer(customer);
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

  // Update customer
  Future<bool> updateCustomer(Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _customerService.updateCustomer(customer);
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

  // Delete customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      await _customerService.deleteCustomer(customerId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get customer
  Future<Customer?> getCustomer(String customerId) async {
    try {
      return await _customerService.getCustomer(customerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get customer purchase history
  Future<List<Sale>> getCustomerPurchaseHistory(String customerId) async {
    try {
      return await _customerService.getCustomerSales(customerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
}
