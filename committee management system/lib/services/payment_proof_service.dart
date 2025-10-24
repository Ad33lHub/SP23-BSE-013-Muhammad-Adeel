import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/payment_proof.dart';
import '../models/audit_log.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';
import 'payment_balance_service.dart';
import 'member_confirmation_service.dart';

class PaymentProofService {
  static final PaymentProofService _instance = PaymentProofService._internal();
  factory PaymentProofService() => _instance;
  PaymentProofService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final PaymentBalanceService _balanceService = PaymentBalanceService();
  final MemberConfirmationService _confirmationService = MemberConfirmationService();
  final Uuid _uuid = const Uuid();

  Future<bool> submitPaymentProof({
    required String committeeId,
    required String cycleId,
    required double amount,
    required String description,
    required File? receiptImage,
    String? transactionId,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      // Get committee and cycle details
      final committee = await _dbHelper.getCommitteeById(committeeId);
      final cycle = await _dbHelper.getCycleById(cycleId);
      
      if (committee == null || cycle == null) return false;

      // Check if user is eligible to make payments (must be active member)
      final isEligible = await _confirmationService.isUserEligibleForCommittee(currentUser.id, committeeId);
      if (!isEligible) {
        print('User ${currentUser.id} is not an active member of committee $committeeId');
        return false; // User is not an active member
      }

      // Check if user already has a pending or approved payment for this cycle
      final existingProof = await _dbHelper.getUserCyclePaymentProof(currentUser.id, cycleId);
      if (existingProof != null && existingProof.status != 'rejected') {
        print('User ${currentUser.id} already has a ${existingProof.status} payment for cycle $cycleId');
        return false; // User already has a payment for this cycle
      }

      // Check if payment deadline has passed
      final deadline = cycle.startDate.add(Duration(days: committee.paymentDeadlineDays));
      if (DateTime.now().isAfter(deadline) && !committee.allowLatePayments) {
        return false; // Payment deadline passed and late payments not allowed
      }

      // Check if amount matches required amount (unless partial payments allowed)
      if (amount != committee.contributionAmount && !committee.allowPartialPayments) {
        return false; // Amount doesn't match and partial payments not allowed
      }

      // Create payment proof
      final paymentProof = PaymentProof(
        id: _uuid.v4(),
        committeeId: committeeId,
        cycleId: cycleId,
        userId: currentUser.id,
        amount: amount,
        description: description,
        receiptImagePath: receiptImage?.path,
        transactionId: transactionId,
        payerName: currentUser.name,
        paymentDate: DateTime.now(),
        status: 'pending',
        submittedAt: DateTime.now(),
        isLate: DateTime.now().isAfter(deadline),
        isPartial: amount < committee.contributionAmount,
      );

      await _dbHelper.insertPaymentProof(paymentProof);

      // Log the submission
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'payment_submitted',
          description: '${currentUser.name} submitted payment proof for cycle ${cycle.cycleNumber}',
          metadata: {
            'amount': amount,
            'cycle_id': cycleId,
            'transaction_id': transactionId,
            'is_late': DateTime.now().isAfter(deadline),
            'is_partial': amount < committee.contributionAmount,
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error submitting payment proof: $e');
      return false;
    }
  }

  Future<bool> verifyPaymentProof({
    required String paymentProofId,
    required bool approved,
    String? rejectionReason,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final paymentProof = await _dbHelper.getPaymentProofById(paymentProofId);
      if (paymentProof == null) return false;

      // Get committee to check if user is creator
      final committee = await _dbHelper.getCommitteeById(paymentProof.committeeId);
      if (committee == null || committee.creatorId != currentUser.id) return false;

      // Update payment proof status
      final updatedProof = paymentProof.copyWith(
        status: approved ? 'approved' : 'rejected',
        verifiedAt: DateTime.now(),
        verifiedBy: currentUser.id,
        rejectionReason: rejectionReason,
      );

      await _dbHelper.updatePaymentProof(updatedProof);

      // Update committee balance in real-time if payment is approved
      if (approved) {
        await _balanceService.updateCommitteeBalanceRealTime(
          paymentProof.committeeId,
          paymentProof.cycleId,
          paymentProof.amount,
        );
      }

      // Log the verification
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: paymentProof.committeeId,
          userId: currentUser.id,
          action: approved ? 'payment_approved' : 'payment_rejected',
          description: '${currentUser.name} ${approved ? 'approved' : 'rejected'} payment proof from ${paymentProof.userId}',
          metadata: {
            'payment_proof_id': paymentProofId,
            'amount': paymentProof.amount,
            'rejection_reason': rejectionReason,
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error verifying payment proof: $e');
      return false;
    }
  }

  Future<List<PaymentProof>> getPendingProofs(String committeeId) async {
    try {
      final proofs = await _dbHelper.getPaymentProofsByCommittee(committeeId);
      return proofs.where((p) => p.status == 'pending').toList();
    } catch (e) {
      print('Error getting pending proofs: $e');
      return [];
    }
  }

  Future<List<PaymentProof>> getUserPaymentProofs(String userId, String committeeId) async {
    try {
      final proofs = await _dbHelper.getPaymentProofsByCommittee(committeeId);
      return proofs.where((p) => p.userId == userId).toList();
    } catch (e) {
      print('Error getting user payment proofs: $e');
      return [];
    }
  }

  Future<List<PaymentProof>> getCyclePaymentProofs(String cycleId) async {
    try {
      final proofs = await _dbHelper.getPaymentProofsByCommittee('');
      return proofs.where((p) => p.cycleId == cycleId).toList();
    } catch (e) {
      print('Error getting cycle payment proofs: $e');
      return [];
    }
  }

  Future<bool> canSubmitPayment(String committeeId, String cycleId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      // Check if user is a member of the committee
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == currentUser.id).firstOrNull;
      if (member == null || member.status != 'joined') return false;

      // Check if cycle is active
      final cycle = await _dbHelper.getCycleById(cycleId);
      if (cycle == null || cycle.status != 'active') return false;

      // Check if user already submitted payment for this cycle
      final existingProofs = await getCyclePaymentProofs(cycleId);
      final userProof = existingProofs.where((p) => p.userId == currentUser.id).firstOrNull;
      if (userProof != null) return false; // Already submitted

      return true;
    } catch (e) {
      print('Error checking payment submission eligibility: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String committeeId, String cycleId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return {};

      final proofs = await getCyclePaymentProofs(cycleId);
      final userProof = proofs.where((p) => p.userId == currentUser.id).firstOrNull;

      return {
        'hasSubmitted': userProof != null,
        'status': userProof?.status ?? 'not_submitted',
        'amount': userProof?.amount ?? 0.0,
        'submittedAt': userProof?.submittedAt,
        'verifiedAt': userProof?.verifiedAt,
        'rejectionReason': userProof?.rejectionReason,
      };
    } catch (e) {
      print('Error getting payment status: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getCommitteePaymentSummary(String committeeId) async {
    try {
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null) return [];

      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final activeMembers = members.where((m) => m.status == 'joined').toList();
      
      final summary = <Map<String, dynamic>>[];
      
      for (final member in activeMembers) {
        final user = await _dbHelper.getUserById(member.userId);
        if (user == null) continue;

        // Get current cycle
        final cycles = await _dbHelper.getCyclesByCommittee(committeeId);
        final currentCycle = cycles.where((c) => c.status == 'active').firstOrNull;
        
        if (currentCycle == null) continue;

        final paymentStatus = await getPaymentStatus(committeeId, currentCycle.id);
        
        summary.add({
          'userId': member.userId,
          'userName': user.name,
          'userEmail': user.email,
          'hasSubmitted': paymentStatus['hasSubmitted'] ?? false,
          'status': paymentStatus['status'] ?? 'not_submitted',
          'amount': paymentStatus['amount'] ?? 0.0,
          'submittedAt': paymentStatus['submittedAt'],
          'verifiedAt': paymentStatus['verifiedAt'],
          'rejectionReason': paymentStatus['rejectionReason'],
        });
      }

      return summary;
    } catch (e) {
      print('Error getting committee payment summary: $e');
      return [];
    }
  }
}
