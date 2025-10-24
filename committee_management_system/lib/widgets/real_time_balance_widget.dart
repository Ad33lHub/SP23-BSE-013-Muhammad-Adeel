import 'package:flutter/material.dart';
import '../../services/payment_balance_service.dart';

class RealTimeBalanceWidget extends StatefulWidget {
  final String committeeId;
  final String? cycleId;
  final bool showLabel;
  final Color? backgroundColor;
  final Color? textColor;

  const RealTimeBalanceWidget({
    super.key,
    required this.committeeId,
    this.cycleId,
    this.showLabel = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<RealTimeBalanceWidget> createState() => _RealTimeBalanceWidgetState();
}

class _RealTimeBalanceWidgetState extends State<RealTimeBalanceWidget> {
  final PaymentBalanceService _balanceService = PaymentBalanceService();
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      double balance;
      if (widget.cycleId != null) {
        balance = await _balanceService.getCommitteeBalanceRealTime(widget.committeeId, widget.cycleId!);
      } else {
        balance = await _balanceService.getTotalCommitteeBalanceRealTime(widget.committeeId);
      }

      if (mounted) {
        setState(() {
          _balance = balance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.backgroundColor ?? Colors.green[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 16,
            color: widget.textColor ?? Colors.green[700],
          ),
          const SizedBox(width: 4),
          if (widget.showLabel) ...[
            Text(
              'Balance: ',
              style: TextStyle(
                color: widget.textColor ?? Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Text(
            '\$${_balance.toStringAsFixed(0)}',
            style: TextStyle(
              color: widget.textColor ?? Colors.green[700],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
