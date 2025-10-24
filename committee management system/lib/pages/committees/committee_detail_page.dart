import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../models/committee_member.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';
import 'winner_selection_page.dart';
import 'winner_history_page.dart';
import 'verify_payments_page.dart';
import 'submit_payment_page.dart';
import 'member_dashboard_page.dart';
import 'creator_dashboard_page.dart';
import 'real_time_payment_dashboard.dart';
import 'invitation_management_page.dart';
import 'pending_requests_page.dart';
import '../../widgets/real_time_balance_widget.dart';

class CommitteeDetailPage extends StatefulWidget {
  final Committee committee;

  const CommitteeDetailPage({super.key, required this.committee});

  @override
  State<CommitteeDetailPage> createState() => _CommitteeDetailPageState();
}

class _CommitteeDetailPageState extends State<CommitteeDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  List<CommitteeMember> _members = [];
  bool _isLoading = true;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _dbHelper.getCommitteeMembers(widget.committee.id);
      final currentUser = _authService.currentUser;
      
      setState(() {
        _members = members;
        _isMember = members.any((m) => m.userId == currentUser?.id);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading members: $e')),
      );
    }
  }

  Future<void> _requestToJoin() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final memberId = DateTime.now().millisecondsSinceEpoch.toString();
      await _dbHelper.insertCommitteeMember(
        CommitteeMember(
          id: memberId,
          committeeId: widget.committee.id,
          userId: currentUser.id,
          status: 'invited',
          joinedAt: DateTime.now(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent to join committee')),
      );
      _loadMembers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting to join: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.committee.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Committee Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.committee.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.committee.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Real-time Balance Widget
                          RealTimeBalanceWidget(
                            committeeId: widget.committee.id,
                            backgroundColor: Colors.green[50],
                            textColor: Colors.green[700],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.attach_money,
                                  'Total Amount',
                                  '\$${widget.committee.contributionAmount.toStringAsFixed(0)} per cycle',
                                  Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.people,
                                  'Members',
                                  '${widget.committee.currentMembers}/${widget.committee.maxMembers}',
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.calendar_today,
                                  'Start Date',
                                  _formatDate(widget.committee.startDate),
                                  Colors.orange,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.event,
                                  'End Date',
                                  widget.committee.endDate != null 
                                      ? _formatDate(widget.committee.endDate!)
                                      : 'No end date',
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Members Section
                  Text(
                    'Members (${_members.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_members.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No members yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                member.userId.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text('Member ${member.userId.substring(0, 8)}'),
                            subtitle: Text('Joined: ${_formatDate(member.joinedAt)}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(member.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                member.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Action Button
                  if (!_isMember)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _requestToJoin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Request to Join',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        // Creator Actions
                        if (_authService.currentUser?.id == widget.committee.creatorId) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToCreatorDashboard(),
                              icon: const Icon(Icons.dashboard),
                              label: const Text('Creator Dashboard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToRealTimeDashboard(),
                              icon: const Icon(Icons.trending_up),
                              label: const Text('Real-time Dashboard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _navigateToPendingRequests(),
                                  icon: const Icon(Icons.pending_actions),
                                  label: const Text('Pending Requests'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _navigateToVerifyPayments(),
                                  icon: const Icon(Icons.verified_user),
                                  label: const Text('Verify'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToWinnerSelection(),
                              icon: const Icon(Icons.casino),
                              label: const Text('Select Winner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Member Actions
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToMemberDashboard(),
                              icon: const Icon(Icons.dashboard),
                              label: const Text('Member Dashboard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToSubmitPayment(),
                              icon: const Icon(Icons.payment),
                              label: const Text('Submit Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _navigateToPendingRequests() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PendingRequestsPage(committee: widget.committee),
      ),
    ).then((_) => _loadMembers()); // Refresh members after returning
  }

  Future<void> _navigateToInvitationManagement() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvitationManagementPage(committee: widget.committee),
      ),
    ).then((_) => _loadMembers()); // Refresh members after returning
  }

  Future<void> _navigateToRealTimeDashboard() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealTimePaymentDashboard(committee: widget.committee),
      ),
    );
  }

  Future<void> _navigateToCreatorDashboard() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatorDashboardPage(committee: widget.committee),
      ),
    );
  }

  Future<void> _navigateToMemberDashboard() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDashboardPage(committee: widget.committee),
      ),
    );
  }

  Future<void> _navigateToVerifyPayments() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyPaymentsPage(committee: widget.committee),
      ),
    );
  }

  Future<void> _navigateToWinnerHistory() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WinnerHistoryPage(committee: widget.committee),
      ),
    );
  }

  Future<void> _navigateToWinnerSelection() async {
    try {
      // Get current active cycle
      final cycles = await _dbHelper.getCyclesByCommittee(widget.committee.id);
      final activeCycle = cycles.where((c) => c.status == 'active').firstOrNull;
      
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
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error navigating to winner selection: $e')),
      );
    }
  }

  Future<void> _navigateToSubmitPayment() async {
    try {
      // Get current active cycle
      final cycles = await _dbHelper.getCyclesByCommittee(widget.committee.id);
      final activeCycle = cycles.where((c) => c.status == 'active').firstOrNull;
      
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
          builder: (context) => SubmitPaymentPage(
            committee: widget.committee,
            cycle: activeCycle,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error navigating to payment submission: $e')),
      );
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'joined':
        return Colors.green;
      case 'invited':
        return Colors.orange;
      case 'left':
        return Colors.red;
      case 'removed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
