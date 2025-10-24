import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/committee.dart';
import '../../models/committee_member.dart';
import '../../models/cycle.dart';
import '../../models/audit_log.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';

class CreateCommitteePage extends StatefulWidget {
  const CreateCommitteePage({super.key});

  @override
  State<CreateCommitteePage> createState() => _CreateCommitteePageState();
}

class _CreateCommitteePageState extends State<CreateCommitteePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contributionAmountController = TextEditingController();
  final _maxMembersController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _paymentDeadlineController = TextEditingController();
  final _rulesController = TextEditingController();
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;
  int _cycleLengthDays = 7; // Default to weekly
  int _paymentDeadlineDays = 3; // Default to 3 days after cycle start
  bool _allowLatePayments = false;
  bool _allowPartialPayments = false;
  bool _noRepeatUntilAllWin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contributionAmountController.dispose();
    _maxMembersController.dispose();
    _cycleLengthController.dispose();
    _paymentDeadlineController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createCommittee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create committee')),
        );
        return;
      }

      // Generate unique invite code
      final inviteCode = _generateInviteCode();

      final committee = Committee(
        id: _uuid.v4(),
        creatorId: currentUser.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        contributionAmount: double.parse(_contributionAmountController.text),
        maxMembers: int.parse(_maxMembersController.text),
        cycleLengthDays: _cycleLengthDays,
        paymentDeadlineDays: _paymentDeadlineDays,
        startDate: _startDate,
        endDate: _endDate,
        status: 'active',
        createdAt: DateTime.now(),
        currentMembers: 1, // Creator is automatically a member
        inviteCode: inviteCode,
        rules: _rulesController.text.trim().isNotEmpty ? _rulesController.text.trim() : null,
        allowLatePayments: _allowLatePayments,
        allowPartialPayments: _allowPartialPayments,
        noRepeatUntilAllWin: _noRepeatUntilAllWin,
        currentCycle: 1,
      );

      await _dbHelper.insertCommittee(committee);

      // Add creator as a member
      await _dbHelper.insertCommitteeMember(
        CommitteeMember(
          id: _uuid.v4(),
          committeeId: committee.id,
          userId: currentUser.id,
          status: 'joined',
          joinedAt: DateTime.now(),
        ),
      );

      // Create first cycle
      final firstCycle = Cycle(
        id: _uuid.v4(),
        committeeId: committee.id,
        cycleNumber: 1,
        startDate: _startDate,
        endDate: _startDate.add(Duration(days: _cycleLengthDays)),
        paymentDeadline: _startDate.add(Duration(days: _paymentDeadlineDays)),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertCycle(firstCycle);

      // Log committee creation
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committee.id,
          userId: currentUser.id,
          action: 'created',
          description: 'Committee "${committee.name}" created',
          metadata: {
            'contribution_amount': committee.contributionAmount,
            'max_members': committee.maxMembers,
            'cycle_length_days': committee.cycleLengthDays,
            'invite_code': committee.inviteCode,
          },
          timestamp: DateTime.now(),
        ),
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Committee created successfully! Invite code: $inviteCode'),
          duration: const Duration(seconds: 5),
        ),
      );

      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      _contributionAmountController.clear();
      _maxMembersController.clear();
      _cycleLengthController.clear();
      _paymentDeadlineController.clear();
      _rulesController.clear();
      setState(() {
        _startDate = DateTime.now().add(const Duration(days: 1));
        _endDate = null;
        _cycleLengthDays = 7;
        _paymentDeadlineDays = 3;
        _allowLatePayments = false;
        _allowPartialPayments = false;
        _noRepeatUntilAllWin = true;
      });

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating committee: $e')),
      );
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();
    
    for (int i = 0; i < 6; i++) {
      code.write(chars[(random + i) % chars.length]);
    }
    
    return code.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Committee'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                        'Committee Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Committee Name',
                          prefixIcon: const Icon(Icons.group_work),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter committee name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Contribution Amount Field
                      TextFormField(
                        controller: _contributionAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Contribution Amount (per cycle)',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contribution amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Members Field
                      TextFormField(
                        controller: _maxMembersController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Maximum Members',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum members';
                          }
                          final members = int.tryParse(value);
                          if (members == null || members < 2) {
                            return 'Please enter valid number (minimum 2)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Cycle Length Field
                      DropdownButtonFormField<int>(
                        value: _cycleLengthDays,
                        decoration: InputDecoration(
                          labelText: 'Cycle Length',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 7, child: Text('Weekly (7 days)')),
                          DropdownMenuItem(value: 14, child: Text('Bi-weekly (14 days)')),
                          DropdownMenuItem(value: 30, child: Text('Monthly (30 days)')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _cycleLengthDays = value ?? 7;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Payment Deadline Field
                      DropdownButtonFormField<int>(
                        value: _paymentDeadlineDays,
                        decoration: InputDecoration(
                          labelText: 'Payment Deadline',
                          prefixIcon: const Icon(Icons.timer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 day after cycle start')),
                          DropdownMenuItem(value: 2, child: Text('2 days after cycle start')),
                          DropdownMenuItem(value: 3, child: Text('3 days after cycle start')),
                          DropdownMenuItem(value: 5, child: Text('5 days after cycle start')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentDeadlineDays = value ?? 3;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Rules Field
                      TextFormField(
                        controller: _rulesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Rules (Optional)',
                          prefixIcon: const Icon(Icons.rule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings Card
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
                        'Committee Rules',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Allow Late Payments
                      CheckboxListTile(
                        title: const Text('Allow Late Payments'),
                        subtitle: const Text('Members can submit payments after deadline'),
                        value: _allowLatePayments,
                        onChanged: (value) {
                          setState(() {
                            _allowLatePayments = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      
                      // Allow Partial Payments
                      CheckboxListTile(
                        title: const Text('Allow Partial Payments'),
                        subtitle: const Text('Members can pay less than required amount'),
                        value: _allowPartialPayments,
                        onChanged: (value) {
                          setState(() {
                            _allowPartialPayments = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      
                      // No Repeat Until All Win
                      CheckboxListTile(
                        title: const Text('No Repeat Winners'),
                        subtitle: const Text('Winners cannot win again until all members have won'),
                        value: _noRepeatUntilAllWin,
                        onChanged: (value) {
                          setState(() {
                            _noRepeatUntilAllWin = value ?? true;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date Selection Card
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
                        'Schedule',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Start Date
                      InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // End Date (Optional)
                      InkWell(
                        onTap: _selectEndDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'End Date (Optional)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _endDate != null 
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                        : 'No end date set',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCommittee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Committee',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
