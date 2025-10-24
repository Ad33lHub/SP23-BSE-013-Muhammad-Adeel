import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../models/user.dart';
import '../../models/committee_member.dart';
import '../../services/invite_service.dart';
import '../../services/auth_service.dart';
import '../../database/database_helper.dart';

class InvitationManagementPage extends StatefulWidget {
  final Committee committee;

  const InvitationManagementPage({
    super.key,
    required this.committee,
  });

  @override
  State<InvitationManagementPage> createState() => _InvitationManagementPageState();
}

class _InvitationManagementPageState extends State<InvitationManagementPage> {
  final InviteService _inviteService = InviteService();
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<User> _allUsers = [];
  List<CommitteeMember> _currentMembers = [];
  List<CommitteeMember> _pendingInvites = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load all users
      final users = await _dbHelper.getAllUsers();
      
      // Load current committee members
      final members = await _dbHelper.getCommitteeMembers(widget.committee.id);
      
      // Filter out current user (creator)
      final currentUserId = _authService.currentUser?.id;
      final filteredUsers = users.where((u) => u.id != currentUserId).toList();
      
      setState(() {
        _allUsers = filteredUsers;
        _currentMembers = members;
        _pendingInvites = members.where((m) => m.status == 'invited').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _sendInvitation(User user) async {
    try {
      // Check if user is already a member
      final isAlreadyMember = _currentMembers.any((m) => m.userId == user.id);
      
      if (isAlreadyMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} is already a member of this committee')),
        );
        return;
      }

      // Create invitation
      final memberId = DateTime.now().millisecondsSinceEpoch.toString();
      await _dbHelper.insertCommitteeMember(
        CommitteeMember(
          id: memberId,
          committeeId: widget.committee.id,
          userId: user.id,
          status: 'invited',
          joinedAt: DateTime.now(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation sent to ${user.name}'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending invitation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelInvitation(String memberId) async {
    try {
      await _dbHelper.deleteCommitteeMember(memberId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation cancelled'),
          backgroundColor: Colors.orange,
        ),
      );

      // Refresh data
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling invitation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    
    return _allUsers.where((user) {
      final isAlreadyMember = _currentMembers.any((m) => m.userId == user.id);
      if (isAlreadyMember) return false;
      
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Invitations'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Pending Invitations Section
                if (_pendingInvites.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.orange[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pending_actions, color: Colors.orange[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Pending Invitations (${_pendingInvites.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'These users have been invited but haven\'t responded yet.',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: _pendingInvites.length,
                      itemBuilder: (context, index) {
                        final invite = _pendingInvites[index];
                        return FutureBuilder<User?>(
                          future: _dbHelper.getUserById(invite.userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const ListTile(
                                leading: CircularProgressIndicator(),
                                title: Text('Loading...'),
                              );
                            }
                            
                            final user = snapshot.data;
                            if (user == null) return const SizedBox.shrink();
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange[100],
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'PENDING',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => _cancelInvitation(invite.id),
                                      tooltip: 'Cancel Invitation',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],

                // Available Users Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.people, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Available Users',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_filteredUsers.length}',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _filteredUsers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'No available users to invite'
                                          : 'No users found matching "$_searchQuery"',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_searchQuery.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try a different search term',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue[100],
                                        child: Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            color: Colors.blue[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(user.name),
                                      subtitle: Text(user.email),
                                      trailing: ElevatedButton.icon(
                                        onPressed: () => _sendInvitation(user),
                                        icon: const Icon(Icons.send, size: 16),
                                        label: const Text('Invite'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

