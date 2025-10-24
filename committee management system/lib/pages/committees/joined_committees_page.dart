import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';
import 'payment_page.dart';

class JoinedCommitteesPage extends StatefulWidget {
  const JoinedCommitteesPage({super.key});

  @override
  State<JoinedCommitteesPage> createState() => _JoinedCommitteesPageState();
}

class _JoinedCommitteesPageState extends State<JoinedCommitteesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  List<Committee> _joinedCommittees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoinedCommittees();
  }

  Future<void> _loadJoinedCommittees() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final memberships = await _dbHelper.getUserCommittees(currentUser.id);
      final committees = <Committee>[];

      // Only show committees where user is an ACTIVE member
      for (final membership in memberships) {
        if (membership.status == 'active') {
          final committee = await _dbHelper.getCommitteeById(membership.committeeId);
          if (committee != null) {
            committees.add(committee);
          }
        }
      }

      setState(() {
        _joinedCommittees = committees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading committees: $e')),
      );
    }
  }

  Future<double> _getTotalPaid(String committeeId) async {
    try {
      final payments = await _dbHelper.getCommitteePayments(committeeId);
      final currentUser = _authService.currentUser;
      if (currentUser == null) return 0.0;

      double total = 0.0;
      for (final payment in payments) {
        if (payment.userId == currentUser.id && payment.status == 'verified') {
          total += payment.amount;
        }
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  Future<int> _getDaysRemaining(DateTime? endDate) async {
    if (endDate == null) return 999; // No end date means ongoing
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Committees'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJoinedCommittees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _joinedCommittees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No committees joined',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Browse and join committees to get started!',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadJoinedCommittees,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _joinedCommittees.length,
                    itemBuilder: (context, index) {
                      final committee = _joinedCommittees[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(committee: committee),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        committee.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(committee.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        committee.status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  committee.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                
                                // Payment Progress
                                FutureBuilder<double>(
                                  future: _getTotalPaid(committee.id),
                                  builder: (context, snapshot) {
                                    final totalPaid = snapshot.data ?? 0.0;
                                    final progress = committee.contributionAmount > 0 
                                        ? totalPaid / committee.contributionAmount 
                                        : 0.0;
                                    
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Paid: \$${totalPaid.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                color: Colors.green[600],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Remaining: \$${(committee.contributionAmount - totalPaid).toStringAsFixed(0)}',
                                              style: TextStyle(
                                                color: Colors.red[600],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            progress >= 1.0 ? Colors.green : Colors.blue,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Timer
                                FutureBuilder<int>(
                                  future: _getDaysRemaining(committee.endDate),
                                  builder: (context, snapshot) {
                                    final daysRemaining = snapshot.data ?? 0;
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 16,
                                          color: daysRemaining <= 7 ? Colors.red : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          daysRemaining > 0 
                                              ? '$daysRemaining days remaining'
                                              : 'Committee ended',
                                          style: TextStyle(
                                            color: daysRemaining <= 7 ? Colors.red : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentPage(committee: committee),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('View Details & Pay'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
