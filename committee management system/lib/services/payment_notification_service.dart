import 'package:flutter/material.dart';
import '../models/payment_proof.dart';
import '../database/database_helper.dart';

class PaymentNotificationService {
  static final PaymentNotificationService _instance = PaymentNotificationService._internal();
  factory PaymentNotificationService() => _instance;
  PaymentNotificationService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Shows real-time notification when payment is submitted
  Future<void> showPaymentSubmittedNotification(
    BuildContext context,
    PaymentProof paymentProof,
  ) async {
    try {
      final committee = await _dbHelper.getCommitteeById(paymentProof.committeeId);
      final user = await _dbHelper.getUserById(paymentProof.userId);
      
      if (committee != null && user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.payment, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'New Payment Submitted',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${user.name} submitted \$${paymentProof.amount.toStringAsFixed(0)} for ${committee.name}'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Verify',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to verification page
                Navigator.pushNamed(
                  context,
                  '/verify-payments',
                  arguments: {'committee': committee},
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error showing payment notification: $e');
    }
  }

  /// Shows notification when payment is verified
  Future<void> showPaymentVerifiedNotification(
    BuildContext context,
    PaymentProof paymentProof,
    bool approved,
  ) async {
    try {
      final committee = await _dbHelper.getCommitteeById(paymentProof.committeeId);
      final user = await _dbHelper.getUserById(paymentProof.userId);
      
      if (committee != null && user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  approved ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        approved ? 'Payment Approved' : 'Payment Rejected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${user.name}\'s payment of \$${paymentProof.amount.toStringAsFixed(0)} for ${committee.name}'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: approved ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error showing verification notification: $e');
    }
  }

  /// Shows balance update notification with real-time details
  Future<void> showBalanceUpdateNotification(
    BuildContext context,
    String committeeName,
    double amount,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Balance Updated!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${committeeName} balance increased by \$${amount.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Could navigate to balance details
          },
        ),
      ),
    );
  }

  /// Shows pending payments count in app bar
  Future<Widget> buildPendingPaymentsBadge(String committeeId) async {
    try {
      final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
      int pendingCount = 0;
      
      for (final cycle in cycles) {
        final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycle.id);
        pendingCount += paymentProofs.where((p) => p.status == 'pending').length;
      }
      
      if (pendingCount > 0) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$pendingCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      
      return const SizedBox.shrink();
    } catch (e) {
      print('Error building pending payments badge: $e');
      return const SizedBox.shrink();
    }
  }

  /// Gets real-time payment status for dashboard
  Future<Map<String, dynamic>> getRealTimePaymentStatus(String committeeId) async {
    try {
      final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
      int pendingPayments = 0;
      int approvedPayments = 0;
      int rejectedPayments = 0;
      double totalPendingAmount = 0.0;
      double totalApprovedAmount = 0.0;
      
      for (final cycle in cycles) {
        final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycle.id);
        
        for (final payment in paymentProofs) {
          switch (payment.status) {
            case 'pending':
              pendingPayments++;
              totalPendingAmount += payment.amount;
              break;
            case 'approved':
              approvedPayments++;
              totalApprovedAmount += payment.amount;
              break;
            case 'rejected':
              rejectedPayments++;
              break;
          }
        }
      }
      
      return {
        'pendingPayments': pendingPayments,
        'approvedPayments': approvedPayments,
        'rejectedPayments': rejectedPayments,
        'totalPendingAmount': totalPendingAmount,
        'totalApprovedAmount': totalApprovedAmount,
        'hasPendingPayments': pendingPayments > 0,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      print('Error getting real-time payment status: $e');
      return {
        'pendingPayments': 0,
        'approvedPayments': 0,
        'rejectedPayments': 0,
        'totalPendingAmount': 0.0,
        'totalApprovedAmount': 0.0,
        'hasPendingPayments': false,
        'lastUpdated': DateTime.now(),
      };
    }
  }
}
