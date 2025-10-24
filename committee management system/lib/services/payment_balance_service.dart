import 'package:uuid/uuid.dart';
import '../models/audit_log.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class PaymentBalanceService {
  static final PaymentBalanceService _instance = PaymentBalanceService._internal();
  factory PaymentBalanceService() => _instance;
  PaymentBalanceService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();

  /// Updates committee balance when payment is approved (real-time)
  Future<bool> updateCommitteeBalanceRealTime(String committeeId, String cycleId, double amount) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      // Get current committee
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null) return false;

      // Log the balance update
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'balance_updated_realtime',
          description: 'Committee balance updated by \$${amount.toStringAsFixed(0)} after payment confirmation',
          metadata: {
            'cycle_id': cycleId,
            'amount_added': amount,
            'updated_by': currentUser.id,
            'update_type': 'payment_confirmation',
            'timestamp': DateTime.now().toIso8601String(),
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error updating committee balance in real-time: $e');
      return false;
    }
  }

  /// Gets current committee balance for a specific cycle (real-time)
  Future<double> getCommitteeBalanceRealTime(String committeeId, String cycleId) async {
    try {
      final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycleId);
      final approvedPayments = paymentProofs.where((p) => p.status == 'approved').toList();
      
      double total = 0.0;
      for (final payment in approvedPayments) {
        total += payment.amount;
      }
      return total;
    } catch (e) {
      print('Error getting committee balance in real-time: $e');
      return 0.0;
    }
  }

  /// Gets total committee balance across all cycles (real-time)
  Future<double> getTotalCommitteeBalanceRealTime(String committeeId) async {
    try {
      final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
      double totalBalance = 0.0;
      
      for (final cycle in cycles) {
        final cycleBalance = await getCommitteeBalanceRealTime(committeeId, cycle.id);
        totalBalance += cycleBalance;
      }
      
      return totalBalance;
    } catch (e) {
      print('Error getting total committee balance in real-time: $e');
      return 0.0;
    }
  }

  /// Gets current committee balance for a specific cycle
  Future<double> getCommitteeBalance(String committeeId, String cycleId) async {
    try {
      final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycleId);
      final approvedPayments = paymentProofs.where((p) => p.status == 'approved').toList();
      
      double total = 0.0;
      for (final payment in approvedPayments) {
        total += payment.amount;
      }
      return total;
    } catch (e) {
      print('Error getting committee balance: $e');
      return 0.0;
    }
  }

  /// Gets total committee balance across all cycles
  Future<double> getTotalCommitteeBalance(String committeeId) async {
    try {
      final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
      double totalBalance = 0.0;
      
      for (final cycle in cycles) {
        final cycleBalance = await getCommitteeBalance(committeeId, cycle.id);
        totalBalance += cycleBalance;
      }
      
      return totalBalance;
    } catch (e) {
      print('Error getting total committee balance: $e');
      return 0.0;
    }
  }

  /// Gets pending payments count for real-time notifications
  Future<int> getPendingPaymentsCount(String committeeId) async {
    try {
      final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
      int pendingCount = 0;
      
      for (final cycle in cycles) {
        final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycle.id);
        pendingCount += paymentProofs.where((p) => p.status == 'pending').length;
      }
      
      return pendingCount;
    } catch (e) {
      print('Error getting pending payments count: $e');
      return 0;
    }
  }

  /// Gets payment statistics for dashboard
  Future<Map<String, dynamic>> getPaymentStatistics(String committeeId) async {
    try {
      final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
      int totalPayments = 0;
      int approvedPayments = 0;
      int pendingPayments = 0;
      int rejectedPayments = 0;
      double totalAmount = 0.0;
      double approvedAmount = 0.0;

      for (final cycle in cycles) {
        final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycle.id);
        
        for (final payment in paymentProofs) {
          totalPayments++;
          totalAmount += payment.amount;
          
          switch (payment.status) {
            case 'approved':
              approvedPayments++;
              approvedAmount += payment.amount;
              break;
            case 'pending':
              pendingPayments++;
              break;
            case 'rejected':
              rejectedPayments++;
              break;
          }
        }
      }

      return {
        'totalPayments': totalPayments,
        'approvedPayments': approvedPayments,
        'pendingPayments': pendingPayments,
        'rejectedPayments': rejectedPayments,
        'totalAmount': totalAmount,
        'approvedAmount': approvedAmount,
        'approvalRate': totalPayments > 0 ? (approvedPayments / totalPayments) * 100 : 0.0,
      };
    } catch (e) {
      print('Error getting payment statistics: $e');
      return {
        'totalPayments': 0,
        'approvedPayments': 0,
        'pendingPayments': 0,
        'rejectedPayments': 0,
        'totalAmount': 0.0,
        'approvedAmount': 0.0,
        'approvalRate': 0.0,
      };
    }
  }
}
