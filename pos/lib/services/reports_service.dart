import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/customer.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Daily Sales Report
  Future<Map<String, dynamic>> getDailySalesReport(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double totalRevenue = 0;
      int totalOrders = snapshot.docs.length;
      int totalItems = 0;
      Map<String, int> itemCounts = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();
        
        final items = data['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final qty = (item['quantity'] ?? 0) as num;
          totalItems += qty.toInt();
          
          final productName = item['productName'] ?? 'Unknown';
          itemCounts[productName] = (itemCounts[productName] ?? 0) + qty.toInt();
        }
      }

      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

      // Get top selling items
      final topItems = itemCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'date': date,
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalItems': totalItems,
        'averageOrderValue': averageOrderValue,
        'topItems': topItems.take(5).toList(),
      };
    } catch (e) {
      return {
        'date': date,
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'totalItems': 0,
        'averageOrderValue': 0.0,
        'topItems': [],
      };
    }
  }

  // Today's Sales Report
  Future<Map<String, dynamic>> getTodaySalesReport() async {
    return getDailySalesReport(DateTime.now());
  }

  // Monthly Sales Report
  Future<Map<String, dynamic>> getMonthlySalesReport(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double totalRevenue = 0;
      int totalOrders = snapshot.docs.length;
      int totalItems = 0;
      Map<int, double> dailyRevenue = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] ?? 0).toDouble();
        totalRevenue += amount;

        final timestamp = (data['createdAt'] as Timestamp).toDate();
        final day = timestamp.day;
        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + amount;

        final items = data['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final qty = item['quantity'];
          totalItems += (qty is num ? qty.toInt() : 0);
        }
      }

      return {
        'year': year,
        'month': month,
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalItems': totalItems,
        'dailyBreakdown': dailyRevenue,
        'averageDaily': totalRevenue / DateTime(year, month + 1, 0).day,
      };
    } catch (e) {
      return {
        'year': year,
        'month': month,
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'totalItems': 0,
        'dailyBreakdown': {},
        'averageDaily': 0.0,
      };
    }
  }

  // Current Month Report
  Future<Map<String, dynamic>> getCurrentMonthReport() async {
    final now = DateTime.now();
    return getMonthlySalesReport(now.year, now.month);
  }

  // Date Range Report
  Future<Map<String, dynamic>> getSalesReportByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double totalRevenue = 0;
      int totalOrders = snapshot.docs.length;
      int totalItems = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();

        final items = data['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final qty = item['quantity'];
          totalItems += (qty is num ? qty.toInt() : 0);
        }
      }

      return {
        'startDate': start,
        'endDate': end,
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalItems': totalItems,
      };
    } catch (e) {
      return {
        'startDate': start,
        'endDate': end,
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'totalItems': 0,
      };
    }
  }

  // Low Stock Report
  Future<List<Product>> getLowStockReport() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('quantity', isLessThan: 10)
          .orderBy('quantity')
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Stock Value Report
  Future<Map<String, dynamic>> getStockValueReport() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      double totalValue = 0;
      int totalProducts = snapshot.docs.length;
      int totalQuantity = 0;
      Map<String, double> categoryValues = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final quantityDynamic = data['quantity'];
        final quantity = (quantityDynamic is num ? quantityDynamic.toInt() : 0);
        final costPrice = (data['costPrice'] ?? 0).toDouble();
        final category = data['category'] ?? 'Uncategorized';

        final value = quantity * costPrice;
        totalValue += value;
        totalQuantity += quantity;
        categoryValues[category] = (categoryValues[category] ?? 0) + value;
      }

      return {
        'totalValue': totalValue,
        'totalProducts': totalProducts,
        'totalQuantity': totalQuantity,
        'categoryValues': categoryValues,
        'averageValue': totalProducts > 0 ? totalValue / totalProducts : 0,
      };
    } catch (e) {
      return {
        'totalValue': 0.0,
        'totalProducts': 0,
        'totalQuantity': 0,
        'categoryValues': {},
        'averageValue': 0.0,
      };
    }
  }

  // Top Customers Report
  Future<List<Map<String, dynamic>>> getTopCustomersReport({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .orderBy('totalPurchases', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'totalPurchases': (data['totalPurchases'] ?? 0).toDouble(),
          'totalOrders': data['totalOrders'] ?? 0,
          'outstandingBalance': (data['outstandingBalance'] ?? 0).toDouble(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Customer Outstanding Report
  Future<Map<String, dynamic>> getCustomerOutstandingReport() async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .where('outstandingBalance', isGreaterThan: 0)
          .get();

      double totalOutstanding = 0;
      int customersWithBalance = snapshot.docs.length;

      for (final doc in snapshot.docs) {
        totalOutstanding += (doc.data()['outstandingBalance'] ?? 0).toDouble();
      }

      return {
        'totalOutstanding': totalOutstanding,
        'customersWithBalance': customersWithBalance,
        'averageBalance': customersWithBalance > 0 ? totalOutstanding / customersWithBalance : 0,
      };
    } catch (e) {
      return {
        'totalOutstanding': 0.0,
        'customersWithBalance': 0,
        'averageBalance': 0.0,
      };
    }
  }

  // Customer Activity Report
  Future<Map<String, dynamic>> getCustomerActivityReport() async {
    try {
      final allCustomers = await _firestore.collection('customers').get();
      final totalCustomers = allCustomers.docs.length;

      // Customers with orders
      final activeCustomers = allCustomers.docs
          .where((doc) => (doc.data()['totalOrders'] ?? 0) > 0)
          .length;

      // New customers this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final newCustomers = allCustomers.docs
          .where((doc) {
            final createdAt = (doc.data()['createdAt'] as Timestamp?)?.toDate();
            return createdAt != null && createdAt.isAfter(startOfMonth);
          })
          .length;

      return {
        'totalCustomers': totalCustomers,
        'activeCustomers': activeCustomers,
        'newCustomersThisMonth': newCustomers,
        'inactiveCustomers': totalCustomers - activeCustomers,
      };
    } catch (e) {
      return {
        'totalCustomers': 0,
        'activeCustomers': 0,
        'newCustomersThisMonth': 0,
        'inactiveCustomers': 0,
      };
    }
  }
}
