import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/committee.dart';
import '../../models/cycle.dart';
import '../../models/committee_member.dart';
import '../../models/user.dart';
import '../../services/winner_selection_service.dart';
import '../../services/auth_service.dart';
import '../../database/database_helper.dart';

class WinnerSelectionPage extends StatefulWidget {
  final Committee committee;
  final Cycle cycle;

  const WinnerSelectionPage({
    super.key,
    required this.committee,
    required this.cycle,
  });

  @override
  State<WinnerSelectionPage> createState() => _WinnerSelectionPageState();
}

class _WinnerSelectionPageState extends State<WinnerSelectionPage>
    with TickerProviderStateMixin {
  final WinnerSelectionService _winnerService = WinnerSelectionService();
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late AnimationController _spinnerController;
  late AnimationController _pulseController;
  late Animation<double> _spinnerAnimation;
  late Animation<double> _pulseAnimation;

  List<CommitteeMember> _eligibleMembers = [];
  List<User> _memberUsers = [];
  double _potAmount = 0.0;
  bool _isLoading = true;
  bool _isSelecting = false;
  bool _canSelect = false;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCycleStatus();
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _spinnerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _spinnerAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _spinnerController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadCycleStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await _winnerService.getCycleStatus(
        widget.committee.id,
        widget.cycle.id,
      );

      if (status.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status['error'])),
        );
        return;
      }

      final eligibleMembers = status['eligibleMembers'] as List<CommitteeMember>;
      final potAmount = status['potAmount'] as double;
      final canSelect = status['canSelectWinner'] as bool;
      final deadline = status['deadline'] as DateTime;

      // Get user details for eligible members
      final memberUsers = <User>[];
      for (final member in eligibleMembers) {
        final user = await _dbHelper.getUserById(member.userId);
        if (user != null) {
          memberUsers.add(user);
        }
      }

      setState(() {
        _eligibleMembers = eligibleMembers;
        _memberUsers = memberUsers;
        _potAmount = potAmount;
        _canSelect = canSelect;
        _deadline = deadline;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cycle status: $e')),
      );
    }
  }

  Future<void> _selectWinner() async {
    if (!_canSelect) return;

    setState(() => _isSelecting = true);

    // Start spinner animation
    _spinnerController.forward();

    // Simulate selection process
    await Future.delayed(const Duration(seconds: 3));

    try {
      final result = await _winnerService.selectWinner(
        widget.committee.id,
        widget.cycle.id,
      );

      _spinnerController.stop();

      if (result['success']) {
        final winner = result['winner'] as CommitteeMember;
        final potAmount = result['potAmount'] as double;
        final seed = result['seed'] as int;

        _showWinnerDialog(winner, potAmount, seed);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _spinnerController.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting winner: $e')),
      );
    } finally {
      setState(() => _isSelecting = false);
    }
  }

  void _showWinnerDialog(CommitteeMember winner, double potAmount, int seed) {
    final winnerUser = _memberUsers.firstWhere(
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Winner Selected!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    winnerUser.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        '\$${potAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Audit Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Random Seed: $seed',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Eligible Members: ${_eligibleMembers.length}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Winner'),
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
                  // Cycle Info Card
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
                            'Cycle ${widget.cycle.cycleNumber}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.committee.name,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Pot Amount: \$${_potAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.people, size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Eligible: ${_eligibleMembers.length}',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_deadline != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.timer, size: 16, color: Colors.orange[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Deadline: ${_formatDate(_deadline!)}',
                                  style: TextStyle(
                                    color: Colors.orange[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Eligible Members
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
                          const Text(
                            'Eligible Members',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_eligibleMembers.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No eligible members',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._eligibleMembers.map((member) {
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
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Winner Selection Button
                  Center(
                    child: Column(
                      children: [
                        if (_isSelecting) ...[
                          // Spinner Animation
                          AnimatedBuilder(
                            animation: _spinnerAnimation,
                            builder: (context, child) {
                              return AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Transform.rotate(
                                      angle: _spinnerAnimation.value,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).primaryColor,
                                              Colors.amber,
                                              Theme.of(context).primaryColor,
                                            ],
                                            stops: const [0.0, 0.5, 1.0],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.casino,
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Selecting Winner...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _canSelect ? _selectWinner : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canSelect 
                                    ? Theme.of(context).primaryColor 
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _canSelect 
                                    ? 'Select Winner' 
                                    : 'Cannot Select Winner',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (!_canSelect) ...[
                            const SizedBox(height: 8),
                            Text(
                              _eligibleMembers.isEmpty 
                                  ? 'No eligible members found'
                                  : 'Payment deadline has not passed',
                              style: TextStyle(
                                color: Colors.grey[600],
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
