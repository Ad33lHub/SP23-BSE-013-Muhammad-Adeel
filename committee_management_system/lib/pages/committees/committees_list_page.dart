import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../models/committee_member.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';
import 'committee_detail_page.dart';
import 'pending_invites_page.dart';

class CommitteesListPage extends StatefulWidget {
  const CommitteesListPage({super.key});

  @override
  State<CommitteesListPage> createState() => _CommitteesListPageState();
}

class _CommitteesListPageState extends State<CommitteesListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  List<Committee> _committees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommittees();
  }

  Future<void> _loadCommittees() async {
    setState(() => _isLoading = true);
    try {
      final committees = await _dbHelper.getAllCommittees();
      setState(() {
        _committees = committees.where((c) => c.status == 'active').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading committees: $e')),
      );
    }
  }

  Future<bool> _isUserMember(String committeeId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;
      
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      return members.any((m) => m.userId == currentUser.id && m.status == 'joined');
    } catch (e) {
      return false;
    }
  }

  Future<void> _requestToJoin(String committeeId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Check if user is already a member
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final isAlreadyMember = members.any((m) => m.userId == currentUser.id);
      
      if (isAlreadyMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are already a member of this committee')),
        );
        return;
      }

      // Add member with 'requested' status
      final memberId = DateTime.now().millisecondsSinceEpoch.toString();
      await _dbHelper.insertCommitteeMember(
        CommitteeMember(
          id: memberId,
          committeeId: committeeId,
          userId: currentUser.id,
          status: 'requested',
          joinedAt: DateTime.now(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent to join committee. Creator will review your request.')),
      );
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
        title: const Text('Browse Committees'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PendingInvitesPage(),
                ),
              );
            },
            tooltip: 'Pending Invitations',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommittees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _committees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_work_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No committees available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to create a committee!',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCommittees,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _committees.length,
                    itemBuilder: (context, index) {
                      final committee = _committees[index];
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
                              builder: (context) => CommitteeDetailPage(committee: committee),
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '\$${committee.contributionAmount.toStringAsFixed(0)} per cycle',
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.blue[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${committee.currentMembers}/${committee.maxMembers}',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Starts: ${_formatDate(committee.startDate)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      committee.endDate != null 
                                          ? 'Ends: ${_formatDate(committee.endDate!)}'
                                          : 'No end date',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                 const SizedBox(height: 12),
                                 // Only show join button if user is not already a member
                                 FutureBuilder<bool>(
                                   future: _isUserMember(committee.id),
                                   builder: (context, snapshot) {
                                     if (snapshot.connectionState == ConnectionState.waiting) {
                                       return const SizedBox(
                                         height: 40,
                                         child: Center(child: CircularProgressIndicator()),
                                       );
                                     }
                                     
                                     final isMember = snapshot.data ?? false;
                                     if (isMember) {
                                       return Container(
                                         padding: const EdgeInsets.symmetric(vertical: 12),
                                         decoration: BoxDecoration(
                                           color: Colors.green[50],
                                           borderRadius: BorderRadius.circular(8),
                                           border: Border.all(color: Colors.green[200]!),
                                         ),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                             const SizedBox(width: 8),
                                             Text(
                                               'You are a member',
                                               style: TextStyle(
                                                 color: Colors.green[600],
                                                 fontWeight: FontWeight.bold,
                                               ),
                                             ),
                                           ],
                                         ),
                                       );
                                     }
                                     
                                     return SizedBox(
                                       width: double.infinity,
                                       child: ElevatedButton(
                                         onPressed: () => _requestToJoin(committee.id),
                                         style: ElevatedButton.styleFrom(
                                           backgroundColor: Theme.of(context).primaryColor,
                                           foregroundColor: Colors.white,
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(8),
                                           ),
                                         ),
                                         child: const Text('Request to Join'),
                                       ),
                                     );
                                   },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
