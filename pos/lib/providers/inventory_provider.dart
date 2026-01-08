import 'package:flutter/foundation.dart';
import '../models/stock_transaction.dart';
import '../services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  
  List<StockTransaction> _transactions = [];
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _filterType;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StockTransaction> get transactions => _transactions;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TransactionType? get filterType => _filterType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get filtered transactions
  List<StockTransaction> get filteredTransactions {
    var filtered = _transactions;

    // Filter by type
    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    return filtered;
  }

  // Set date range filter
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
    if (start != null && end != null) {
      loadTransactionsByDateRange(start, end);
    } else {
      loadAllTransactions();
    }
  }

  // Set type filter
  void setTypeFilter(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  // Load all transactions
  void loadAllTransactions() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _inventoryService.getAllStockHistory().listen(
      (transactions) {
        _transactions = transactions;
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

  // Load transactions for a specific product
  void loadProductTransactions(String productId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _inventoryService.getStockHistory(productId).listen(
      (transactions) {
        _transactions = transactions;
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

  // Load transactions by date range
  void loadTransactionsByDateRange(DateTime start, DateTime end) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _inventoryService.getStockHistoryByDateRange(
      startDate: start,
      endDate: end,
    ).listen(
      (transactions) {
        _transactions = transactions;
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

  // Stock in
  Future<bool> stockIn({
    required String productId,
    required int quantity,
    String notes = '',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _inventoryService.stockIn(
        productId: productId,
        quantity: quantity,
        notes: notes,
      );
      
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

  // Stock out
  Future<bool> stockOut({
    required String productId,
    required int quantity,
    String notes = '',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _inventoryService.stockOut(
        productId: productId,
        quantity: quantity,
        notes: notes,
      );
      
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _filterType = null;
    notifyListeners();
    loadAllTransactions();
  }
}
