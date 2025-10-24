import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../services/payment_notification_service.dart';
import '../../services/payment_balance_service.dart';
import '../../database/database_helper.dart';
import 'package:intl/intl.dart';

class RealTimePaymentDashboard extends StatefulWidget {
  final Committee committee;

  const RealTimePaymentDashboard({
    super.key,
    required this.committee,
  });

  @override
  State<RealTimePaymentDashboard> createState() => _RealTimePaymentDashboardState();
}

class _RealTimePaymentDashboardState extends State<RealTimePaymentDashboard> {
  final PaymentNotificationService _notificationService = PaymentNotificationService();
  final PaymentBalanceService _balanceService = PaymentBalanceService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  Map<String, dynamic> _paymentStatus = {};
  Map<String, dynamic> _paymentStats = {};
  double _currentBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealTimeData();
    // Refresh data every 30 seconds
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadRealTimeData();
        _startPeriodicRefresh();
      }
    });
  }

  Future<void> _loadRealTimeData() async {
    try {
      final paymentStatus = await _notificationService.getRealTimePaymentStatus(widget.committee.id);
      final paymentStats = await _balanceService.getPaymentStatistics(widget.committee.id);
      final currentBalance = await _balanceService.getTotalCommitteeBalance(widget.committee.id);
      
      if (mounted) {
        setState(() {
          _paymentStatus = paymentStatus;
          _paymentStats = paymentStats;
          _currentBalance = currentBalance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading real-time data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Dashboard - ${widget.committee.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRealTimeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRealTimeData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Real-time Status Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Real-time Status',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _paymentStatus['hasPendingPayments'] ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _paymentStatus['hasPendingPayments'] ? 'Pending' : 'All Clear',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatusItem(
                                    'Pending',
                                    _paymentStatus['pendingPayments']?.toString() ?? '0',
                                    Colors.orange,
                                    Icons.pending_actions,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatusItem(
                                    'Approved',
                                    _paymentStatus['approvedPayments']?.toString() ?? '0',
                                    Colors.green,
                                    Icons.check_circle,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatusItem(
                                    'Rejected',
                                    _paymentStatus['rejectedPayments']?.toString() ?? '0',
                                    Colors.red,
                                    Icons.cancel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Balance Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Committee Balance',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBalanceItem(
                                    'Total Balance',
                                    '\$${_currentBalance.toStringAsFixed(0)}',
                                    Colors.green,
                                  ),
                                ),
                                Expanded(
                                  child: _buildBalanceItem(
                                    'Pending Amount',
                                    '\$${(_paymentStatus['totalPendingAmount'] ?? 0.0).toStringAsFixed(0)}',
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBalanceItem(
                                    'Approved Amount',
                                    '\$${(_paymentStatus['totalApprovedAmount'] ?? 0.0).toStringAsFixed(0)}',
                                    Colors.blue,
                                  ),
                                ),
                                Expanded(
                                  child: _buildBalanceItem(
                                    'Approval Rate',
                                    '${(_paymentStats['approvalRate'] ?? 0.0).toStringAsFixed(1)}%',
                                    Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Statistics Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Payment Statistics',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow('Total Payments', _paymentStats['totalPayments']?.toString() ?? '0'),
                            _buildStatRow('Approved Payments', _paymentStats['approvedPayments']?.toString() ?? '0'),
                            _buildStatRow('Pending Payments', _paymentStats['pendingPayments']?.toString() ?? '0'),
                            _buildStatRow('Rejected Payments', _paymentStats['rejectedPayments']?.toString() ?? '0'),
                            const Divider(),
                            _buildStatRow('Total Amount', '\$${(_paymentStats['totalAmount'] ?? 0.0).toStringAsFixed(0)}'),
                            _buildStatRow('Approved Amount', '\$${(_paymentStats['approvedAmount'] ?? 0.0).toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last Updated
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.update, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Last updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
