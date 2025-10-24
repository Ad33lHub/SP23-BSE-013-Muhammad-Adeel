import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../models/cycle.dart';
import '../../models/payment_proof.dart';
import '../../models/winner.dart';
import '../../models/committee_member.dart';
import '../../services/payment_proof_service.dart';
import '../../services/winner_selection_service.dart';
import '../../services/auth_service.dart';
import '../../database/database_helper.dart';
import 'submit_payment_page.dart';
import 'winner_history_page.dart';

class MemberDashboardPage extends StatefulWidget {
  final Committee committee;

  const MemberDashboardPage({
    super.key,
    required this.committee,
  });

  @override
  State<MemberDashboardPage> createState() => _MemberDashboardPageState();
}

class _MemberDashboardPageState extends State<MemberDashboardPage> {
  final PaymentProofService _paymentService = PaymentProofService();
  final WinnerSelectionService _winnerService = WinnerSelectionService();
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Cycle> _cycles = [];
  List<PaymentProof> _paymentHistory = [];
  List<Winner> _winners = [];
  Map<String, dynamic> _currentCycleStatus = {};
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.id;
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Load cycles
      final cycles = await _dbHelper.getCyclesByCommittee(widget.committee.id);
      
      // Load payment history for current user
      final paymentHistory = await _paymentService.getUserPaymentProofs(
        _currentUserId!,
        widget.committee.id,
      );
      
      // Load winners
      final winners = await _winnerService.getCommitteeWinners(widget.committee.id);
      
      // Get current cycle status
      final activeCycle = cycles.where((c) => c.status == 'active').firstOrNull;
      Map<String, dynamic> cycleStatus = {};
      if (activeCycle != null) {
        cycleStatus = await _winnerService.getCycleStatus(
          widget.committee.id,
          activeCycle.id,
        );
      }

      setState(() {
        _cycles = cycles;
        _paymentHistory = paymentHistory;
        _winners = winners;
        _currentCycleStatus = cycleStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    }
  }

  Future<void> _navigateToSubmitPayment() async {
    final activeCycle = _cycles.where((c) => c.status == 'active').firstOrNull;
    if (activeCycle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active cycle found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is eligible to submit payment
    final canSubmit = await _paymentService.canSubmitPayment(
      widget.committee.id,
      activeCycle.id,
    );

    if (!canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not eligible to submit payment. You may not be an active member or already have a payment for this cycle.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitPaymentPage(
          committee: widget.committee,
          cycle: activeCycle,
        ),
      ),
    ).then((_) => _loadDashboardData()); // Refresh data after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.committee.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Committee Overview Card
                    _buildCommitteeOverviewCard(),
                    const SizedBox(height: 16),

                    // Current Cycle Status Card
                    if (_currentCycleStatus.isNotEmpty) ...[
                      _buildCurrentCycleCard(),
                      const SizedBox(height: 16),
                    ],

                    // Payment History Card
                    _buildPaymentHistoryCard(),
                    const SizedBox(height: 16),

                    // Winners History Card
                    _buildWinnersHistoryCard(),
                    const SizedBox(height: 16),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCommitteeOverviewCard() {
    final activeCycle = _cycles.where((c) => c.status == 'active').firstOrNull;
    final completedCycles = _cycles.where((c) => c.status == 'completed').length;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Committee Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Contribution',
                    '\$${widget.committee.contributionAmount.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Members',
                    '${widget.committee.currentMembers}/${widget.committee.maxMembers}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Cycle Length',
                    '${widget.committee.cycleLengthDays} days',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    '$completedCycles cycles',
                    Icons.check_circle,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            if (activeCycle != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current Cycle: ${activeCycle.cycleNumber}',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCycleCard() {
    final activeCycle = _cycles.where((c) => c.status == 'active').firstOrNull;
    if (activeCycle == null) return const SizedBox.shrink();

    final potAmount = _currentCycleStatus['potAmount'] as double? ?? 0.0;
    final eligibleMembers = _currentCycleStatus['eligibleMembers'] as List? ?? [];
    final deadline = _currentCycleStatus['deadline'] as DateTime?;
    final canSelectWinner = _currentCycleStatus['canSelectWinner'] as bool? ?? false;

    // Check user's payment status
    final userPayment = _paymentHistory
        .where((p) => p.cycleId == activeCycle.id)
        .firstOrNull;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Colors.amber[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Cycle Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pot Amount
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Pot Amount: \$${potAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Eligible Members
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Eligible: ${eligibleMembers.length} members',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Deadline
            if (deadline != null) ...[
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Deadline: ${_formatDate(deadline)}',
                    style: TextStyle(
                      color: Colors.orange[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // User Payment Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(userPayment?.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getPaymentStatusColor(userPayment?.status)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(userPayment?.status),
                    color: _getPaymentStatusColor(userPayment?.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPaymentStatusText(userPayment?.status),
                          style: TextStyle(
                            color: _getPaymentStatusColor(userPayment?.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userPayment != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Amount: \$${userPayment.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: _getPaymentStatusColor(userPayment.status),
                              fontSize: 12,
                            ),
                          ),
                          if (userPayment.submittedAt != null) ...[
                            Text(
                              'Submitted: ${_formatDate(userPayment.submittedAt!)}',
                              style: TextStyle(
                                color: _getPaymentStatusColor(userPayment.status),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.purple[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_paymentHistory.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.payment_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No payments submitted yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ..._paymentHistory.map((payment) {
                final cycle = _cycles.firstWhere(
                  (c) => c.id == payment.cycleId,
                  orElse: () => Cycle(
                    id: '',
                    committeeId: '',
                    cycleNumber: 0,
                    startDate: DateTime.now(),
                    endDate: DateTime.now(),
                    status: '',
                    createdAt: DateTime.now(),
                    paymentDeadline: DateTime.now(),
                  ),
                );
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(payment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPaymentStatusColor(payment.status)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentStatusIcon(payment.status),
                        color: _getPaymentStatusColor(payment.status),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cycle ${cycle.cycleNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Amount: \$${payment.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Status: ${payment.status.toUpperCase()}',
                              style: TextStyle(
                                color: _getPaymentStatusColor(payment.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(payment.submittedAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnersHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Winners History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WinnerHistoryPage(committee: widget.committee),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_winners.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No winners yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ..._winners.take(3).map((winner) {
                final cycle = _cycles.firstWhere(
                  (c) => c.id == winner.cycleId,
                  orElse: () => Cycle(
                    id: '',
                    committeeId: '',
                    cycleNumber: 0,
                    startDate: DateTime.now(),
                    endDate: DateTime.now(),
                    status: '',
                    createdAt: DateTime.now(),
                    paymentDeadline: DateTime.now(),
                  ),
                );
                
                final isCurrentUser = winner.userId == _currentUserId;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser 
                        ? Colors.amber[50] 
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentUser 
                          ? Colors.amber[300]! 
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: isCurrentUser 
                            ? Colors.amber[600] 
                            : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCurrentUser 
                                  ? 'You won!' 
                                  : 'Cycle ${cycle.cycleNumber} Winner',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCurrentUser 
                                    ? Colors.amber[700] 
                                    : Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Amount: \$${winner.amountWon.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(winner.wonAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final activeCycle = _cycles.where((c) => c.status == 'active').firstOrNull;
    final userPayment = activeCycle != null
        ? _paymentHistory.where((p) => p.cycleId == activeCycle.id).firstOrNull
        : null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: activeCycle != null && userPayment == null 
                ? _navigateToSubmitPayment 
                : null,
            icon: const Icon(Icons.payment),
            label: Text(
              userPayment == null 
                  ? 'Submit Payment' 
                  : 'Payment Submitted',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: userPayment == null 
                  ? Colors.green 
                  : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WinnerHistoryPage(committee: widget.committee),
                ),
              );
            },
            icon: const Icon(Icons.emoji_events),
            label: const Text('View All Winners'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Payment Approved';
      case 'pending':
        return 'Payment Pending Review';
      case 'rejected':
        return 'Payment Rejected';
      default:
        return 'No Payment Submitted';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
