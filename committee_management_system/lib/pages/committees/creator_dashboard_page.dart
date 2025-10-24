import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../models/cycle.dart';
import '../../models/payment_proof.dart';
import '../../models/winner.dart';
import '../../models/committee_member.dart';
import '../../models/user.dart';
import '../../services/payment_proof_service.dart';
import '../../services/winner_selection_service.dart';
import '../../services/auth_service.dart';
import '../../database/database_helper.dart';
import 'verify_payments_page.dart';
import 'winner_selection_page.dart';
import 'winner_history_page.dart';

class CreatorDashboardPage extends StatefulWidget {
  final Committee committee;

  const CreatorDashboardPage({
    super.key,
    required this.committee,
  });

  @override
  State<CreatorDashboardPage> createState() => _CreatorDashboardPageState();
}

class _CreatorDashboardPageState extends State<CreatorDashboardPage> {
  final PaymentProofService _paymentService = PaymentProofService();
  final WinnerSelectionService _winnerService = WinnerSelectionService();
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Cycle> _cycles = [];
  List<PaymentProof> _pendingProofs = [];
  List<PaymentProof> _allProofs = [];
  List<Winner> _winners = [];
  List<CommitteeMember> _members = [];
  List<User> _memberUsers = [];
  Map<String, dynamic> _currentCycleStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Load cycles
      final cycles = await _dbHelper.getCyclesByCommittee(widget.committee.id);
      
      // Load pending payment proofs
      final pendingProofs = await _paymentService.getPendingProofs(widget.committee.id);
      
      // Load all payment proofs
      final allProofs = await _dbHelper.getPaymentProofsByCommittee(widget.committee.id);
      
      // Load winners
      final winners = await _winnerService.getCommitteeWinners(widget.committee.id);
      
      // Load members
      final members = await _dbHelper.getCommitteeMembers(widget.committee.id);
      
      // Load member user details
      final memberUsers = <User>[];
      for (final member in members) {
        final user = await _dbHelper.getUserById(member.userId);
        if (user != null) {
          memberUsers.add(user);
        }
      }
      
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
        _pendingProofs = pendingProofs;
        _allProofs = allProofs;
        _winners = winners;
        _members = members;
        _memberUsers = memberUsers;
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

  Future<void> _navigateToVerifyPayments() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyPaymentsPage(committee: widget.committee),
      ),
    ).then((_) => _loadDashboardData()); // Refresh data after returning
  }

  Future<void> _navigateToWinnerSelection() async {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WinnerSelectionPage(
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
        title: Text('${widget.committee.name} - Creator'),
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

                    // Pending Actions Card
                    if (_pendingProofs.isNotEmpty) ...[
                      _buildPendingActionsCard(),
                      const SizedBox(height: 16),
                    ],

                    // Members Status Card
                    _buildMembersStatusCard(),
                    const SizedBox(height: 16),

                    // Payment Summary Card
                    _buildPaymentSummaryCard(),
                    const SizedBox(height: 16),

                    // Winners Summary Card
                    _buildWinnersSummaryCard(),
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
    final totalCollected = _allProofs
        .where((p) => p.status == 'approved')
        .fold(0.0, (sum, p) => sum + p.amount);
    
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
                  Icons.admin_panel_settings,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Creator Dashboard',
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
                    'Collected',
                    '\$${totalCollected.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    '$completedCycles cycles',
                    Icons.check_circle,
                    Colors.orange,
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
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Pot Amount',
                    '\$${potAmount.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Eligible',
                    '${eligibleMembers.length} members',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
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
              const SizedBox(height: 12),
            ],
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canSelectWinner 
                    ? Colors.green[50] 
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canSelectWinner 
                      ? Colors.green[200]! 
                      : Colors.orange[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    canSelectWinner 
                        ? Icons.check_circle 
                        : Icons.schedule,
                    color: canSelectWinner 
                        ? Colors.green[600] 
                        : Colors.orange[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      canSelectWinner 
                          ? 'Ready to select winner!' 
                          : 'Waiting for deadline or payments',
                      style: TextStyle(
                        color: canSelectWinner 
                            ? Colors.green[600] 
                            : Colors.orange[600],
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildPendingActionsCard() {
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
                  Icons.pending_actions,
                  color: Colors.red[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pending Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pendingProofs.length}',
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
            Text(
              'You have ${_pendingProofs.length} payment(s) waiting for verification',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToVerifyPayments,
                icon: const Icon(Icons.verified_user),
                label: const Text('Verify Payments'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersStatusCard() {
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
                  Icons.people,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Members Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._members.map((member) {
              final user = _memberUsers.firstWhere(
                (u) => u.id == member.userId,
                orElse: () => User(
                  id: '',
                  name: 'Unknown User',
                  email: '',
                  phone: '',
                  password: '',
                  createdAt: DateTime.now(),
                ),
              );
              
              final activeCycle = _cycles.where((c) => c.status == 'active').firstOrNull;
              final userPayment = activeCycle != null
                  ? _allProofs.where((p) => p.cycleId == activeCycle.id && p.userId == member.userId).firstOrNull
                  : null;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMemberStatusColor(member.status, userPayment?.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getMemberStatusColor(member.status, userPayment?.status)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getMemberStatusColor(member.status, userPayment?.status),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Status: ${member.status.toUpperCase()}',
                            style: TextStyle(
                              color: _getMemberStatusColor(member.status, userPayment?.status),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (userPayment != null) ...[
                            Text(
                              'Payment: ${userPayment.status.toUpperCase()}',
                              style: TextStyle(
                                color: _getPaymentStatusColor(userPayment.status),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _getMemberStatusIcon(member.status, userPayment?.status),
                      color: _getMemberStatusColor(member.status, userPayment?.status),
                      size: 20,
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

  Widget _buildPaymentSummaryCard() {
    final approvedPayments = _allProofs.where((p) => p.status == 'approved').length;
    final pendingPayments = _allProofs.where((p) => p.status == 'pending').length;
    final rejectedPayments = _allProofs.where((p) => p.status == 'rejected').length;
    final totalAmount = _allProofs.where((p) => p.status == 'approved').fold(0.0, (sum, p) => sum + p.amount);

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
                  Icons.payment,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Payment Summary',
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
                    'Approved',
                    '$approvedPayments',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    '$pendingPayments',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Rejected',
                    '$rejectedPayments',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '\$${totalAmount.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnersSummaryCard() {
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
                  'Winners Summary',
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
                
                final user = _memberUsers.firstWhere(
                  (u) => u.id == winner.userId,
                  orElse: () => User(
                    id: '',
                    name: 'Unknown User',
                    email: '',
                    phone: '',
                    password: '',
                    createdAt: DateTime.now(),
                  ),
                );
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cycle ${cycle.cycleNumber} - ${user.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
    final canSelectWinner = _currentCycleStatus['canSelectWinner'] as bool? ?? false;

    return Column(
      children: [
        if (_pendingProofs.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToVerifyPayments,
              icon: const Icon(Icons.verified_user),
              label: Text('Verify ${_pendingProofs.length} Payment(s)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (activeCycle != null && canSelectWinner) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToWinnerSelection,
              icon: const Icon(Icons.casino),
              label: const Text('Select Winner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
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

  Color _getMemberStatusColor(String memberStatus, String? paymentStatus) {
    if (memberStatus != 'joined') return Colors.grey;
    if (paymentStatus == 'approved') return Colors.green;
    if (paymentStatus == 'pending') return Colors.orange;
    if (paymentStatus == 'rejected') return Colors.red;
    return Colors.blue;
  }

  IconData _getMemberStatusIcon(String memberStatus, String? paymentStatus) {
    if (memberStatus != 'joined') return Icons.person_off;
    if (paymentStatus == 'approved') return Icons.check_circle;
    if (paymentStatus == 'pending') return Icons.schedule;
    if (paymentStatus == 'rejected') return Icons.cancel;
    return Icons.person;
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
