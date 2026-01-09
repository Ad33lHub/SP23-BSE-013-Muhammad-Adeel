import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/report_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<ReportsProvider>().loadAllReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        context.read<ReportsProvider>().refresh();
                      },
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.purple,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                tabs: const [
                  Tab(text: 'Sales'),
                  Tab(text: 'Stock'),
                  Tab(text: 'Customers'),
                ],
              ),
              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSalesReport(),
                    _buildStockReport(),
                    _buildCustomerReport(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesReport() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final todayReport = provider.todayReport;
        final monthlyReport = provider.monthlyReport;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Sales
              Text(
                'Today\'s Sales',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Revenue',
                      value: '\$${(todayReport?['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Orders',
                      value: '${todayReport?['totalOrders'] ?? 0}',
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Items Sold',
                      value: '${todayReport?['totalItems'] ?? 0}',
                      icon: Icons.inventory,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Avg Order',
                      value: '\$${(todayReport?['averageOrderValue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top Selling Items Today
              Text(
                'Top Selling Items Today',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTopItemsList(todayReport?['topItems'] ?? []),
              const SizedBox(height: 24),

              // Monthly Overview
              Text(
                'This Month',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Monthly Revenue',
                      value: '\$${(monthlyReport?['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.calendar_today,
                      color: Colors.teal,
                      subtitle: '${monthlyReport?['totalOrders'] ?? 0} orders',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Daily Avg',
                      value: '\$${(monthlyReport?['averageDaily'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.show_chart,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockReport() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stockValue = provider.stockValueReport;
        final lowStock = provider.lowStockProducts;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Overview
              Text(
                'Inventory Overview',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Total Value',
                      value: '\$${(stockValue?['totalValue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Products',
                      value: '${stockValue?['totalProducts'] ?? 0}',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                      subtitle: '${stockValue?['totalQuantity'] ?? 0} units',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReportCard(
                title: 'Low Stock Items',
                value: '${lowStock.length}',
                icon: Icons.warning,
                color: lowStock.isEmpty ? Colors.green : Colors.orange,
                subtitle: lowStock.isEmpty ? 'All items stocked' : 'Need attention',
              ),
              const SizedBox(height: 24),

              // Low Stock Products
              if (lowStock.isNotEmpty) ...[
                Text(
                  'Low Stock Products',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...lowStock.map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLowStockItem(product),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerReport() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final topCustomers = provider.topCustomers;
        final outstanding = provider.customerOutstanding;
        final activity = provider.customerActivity;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Overview
              Text(
                'Customer Overview',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Total Customers',
                      value: '${activity?['totalCustomers'] ?? 0}',
                      icon: Icons.people,
                      color: Colors.blue,
                      subtitle: '${activity?['activeCustomers'] ?? 0} active',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'New This Month',
                      value: '${activity?['newCustomersThisMonth'] ?? 0}',
                      icon: Icons.person_add,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Outstanding',
                      value: '\$${(outstanding?['totalOutstanding'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.account_balance,
                      color: Colors.orange,
                      subtitle: '${outstanding?['customersWithBalance'] ?? 0} customers',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top Customers
              Text(
                'Top Customers',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...topCustomers.asMap().entries.map((entry) {
                final index = entry.key;
                final customer = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTopCustomerItem(index + 1, customer),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopItemsList(List<dynamic> items) {
    if (items.isEmpty) {
      return GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 12,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)],
        ),
        child: Text(
          'No sales today',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }

    return Column(
      children: items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 50,
            borderRadius: 12,
            blur: 15,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.key,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.value} sold',
                      style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLowStockItem(product) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange.withOpacity(0.5), Colors.orange.withOpacity(0.2)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.sku,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '${product.quantity} left',
              style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomerItem(int rank, Map<String, dynamic> customer) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 70,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rank <= 3 ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: rank <= 3 ? Colors.amber : Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    customer['name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${customer['totalOrders']} orders',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '\$${(customer['totalPurchases'] ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
