import 'package:flutter/material.dart';
import '../../services/member_confirmation_service.dart';
import '../../services/payment_proof_service.dart';
import '../../services/auth_service.dart';
import '../../models/committee.dart';
import '../../models/cycle.dart';

class PaymentEligibilityWidget extends StatefulWidget {
  final Committee committee;
  final Cycle cycle;

  const PaymentEligibilityWidget({
    super.key,
    required this.committee,
    required this.cycle,
  });

  @override
  State<PaymentEligibilityWidget> createState() => _PaymentEligibilityWidgetState();
}

class _PaymentEligibilityWidgetState extends State<PaymentEligibilityWidget> {
  final MemberConfirmationService _confirmationService = MemberConfirmationService();
  final PaymentProofService _paymentService = PaymentProofService();
  final AuthService _authService = AuthService();
  
  bool _isEligible = false;
  bool _isLoading = true;
  String _eligibilityMessage = '';

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _isEligible = false;
          _eligibilityMessage = 'Please log in to submit payments';
          _isLoading = false;
        });
        return;
      }

      // Check if user is an active member
      final isActiveMember = await _confirmationService.isUserEligibleForCommittee(
        currentUser.id, 
        widget.committee.id,
      );

      if (!isActiveMember) {
        setState(() {
          _isEligible = false;
          _eligibilityMessage = 'You are not an active member of this committee';
          _isLoading = false;
        });
        return;
      }

      // Check if user can submit payment for this cycle
      final canSubmit = await _paymentService.canSubmitPayment(
        widget.committee.id,
        widget.cycle.id,
      );

      if (!canSubmit) {
        setState(() {
          _isEligible = false;
          _eligibilityMessage = 'You already have a payment for this cycle';
          _isLoading = false;
        });
        return;
      }

      // Check payment deadline
      final deadline = widget.cycle.startDate.add(
        Duration(days: widget.committee.paymentDeadlineDays),
      );
      final isLate = DateTime.now().isAfter(deadline);

      if (isLate && !widget.committee.allowLatePayments) {
        setState(() {
          _isEligible = false;
          _eligibilityMessage = 'Payment deadline has passed';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isEligible = true;
        _eligibilityMessage = isLate 
            ? 'Payment deadline passed, but late payments are allowed'
            : 'You are eligible to submit payment';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isEligible = false;
        _eligibilityMessage = 'Error checking eligibility: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Checking eligibility...'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEligible ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isEligible ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isEligible ? Icons.check_circle : Icons.cancel,
            color: _isEligible ? Colors.green[600] : Colors.red[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEligible ? 'Payment Eligible' : 'Payment Not Eligible',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isEligible ? Colors.green[700] : Colors.red[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _eligibilityMessage,
                  style: TextStyle(
                    color: _isEligible ? Colors.green[600] : Colors.red[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_isEligible)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
