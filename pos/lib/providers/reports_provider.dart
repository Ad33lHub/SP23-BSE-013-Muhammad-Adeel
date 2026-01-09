import 'package:flutter/foundation.dart';
import '../services/reports_service.dart';
import '../models/product.dart';

class ReportsProvider with ChangeNotifier {
  final ReportsService _reportsService = ReportsService();

  // Daily Report
  Map<String, dynamic>? _todayReport;
  DateTime _selectedDate = DateTime.now();

  // Monthly Report
  Map<String, dynamic>? _monthlyReport;

  // Stock Report
  List<Product> _lowStockProducts = [];
  Map<String, dynamic>? _stockValueReport;

  // Customer Report
  List<Map<String, dynamic>> _topCustomers = [];
  Map<String, dynamic>? _customerOutstanding;
  Map<String, dynamic>? _customerActivity;

  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get todayReport => _todayReport;
  DateTime get selectedDate => _selectedDate;
  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  List<Product> get lowStockProducts => _lowStockProducts;
  Map<String, dynamic>? get stockValueReport => _stockValueReport;
  List<Map<String, dynamic>> get topCustomers => _topCustomers;
  Map<String, dynamic>? get customerOutstanding => _customerOutstanding;
  Map<String, dynamic>? get customerActivity => _customerActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load Today's Report
  Future<void> loadTodayReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayReport = await _reportsService.getTodaySalesReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Daily Report for specific date
  Future<void> loadDailyReport(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayReport = await _reportsService.getDailySalesReport(date);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Monthly Report
  Future<void> loadMonthlyReport([int? year, int? month]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (year != null && month != null) {
        _monthlyReport = await _reportsService.getMonthlySalesReport(year, month);
      } else {
        _monthlyReport = await _reportsService.getCurrentMonthReport();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Stock Reports
  Future<void> loadStockReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lowStockProducts = await _reportsService.getLowStockReport();
      _stockValueReport = await _reportsService.getStockValueReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Customer Reports
  Future<void> loadCustomerReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topCustomers = await _reportsService.getTopCustomersReport(limit: 10);
      _customerOutstanding = await _reportsService.getCustomerOutstandingReport();
      _customerActivity = await _reportsService.getCustomerActivityReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load All Reports
  Future<void> loadAllReports() async {
    await Future.wait([
      loadTodayReport(),
      loadMonthlyReport(),
      loadStockReports(),
      loadCustomerReports(),
    ]);
  }

  // Refresh Reports
  Future<void> refresh() async {
    await loadAllReports();
  }
}
