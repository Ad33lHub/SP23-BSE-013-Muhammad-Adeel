class Committee {
  final String id;
  final String creatorId;
  final String name;
  final String description;
  final double contributionAmount; // Amount each member pays per cycle
  final int maxMembers;
  final int cycleLengthDays; // How often payments are due (e.g., 7 for weekly)
  final int paymentDeadlineDays; // Days after cycle start to submit payment
  final DateTime startDate;
  final DateTime? endDate; // Optional end date
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime createdAt;
  final int currentMembers;
  final String inviteCode; // Unique code for joining
  final String? rules; // Optional rules text
  final bool allowLatePayments;
  final bool allowPartialPayments;
  final bool noRepeatUntilAllWin; // Winner can't win again until all members win
  final int currentCycle; // Current cycle number (1-based)

  Committee({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.contributionAmount,
    required this.maxMembers,
    required this.cycleLengthDays,
    required this.paymentDeadlineDays,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.createdAt,
    this.currentMembers = 0,
    required this.inviteCode,
    this.rules,
    this.allowLatePayments = false,
    this.allowPartialPayments = false,
    this.noRepeatUntilAllWin = true,
    this.currentCycle = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'contribution_amount': contributionAmount,
      'max_members': maxMembers,
      'cycle_length_days': cycleLengthDays,
      'payment_deadline_days': paymentDeadlineDays,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'current_members': currentMembers,
      'invite_code': inviteCode,
      'rules': rules,
      'allow_late_payments': allowLatePayments ? 1 : 0,
      'allow_partial_payments': allowPartialPayments ? 1 : 0,
      'no_repeat_until_all_win': noRepeatUntilAllWin ? 1 : 0,
      'current_cycle': currentCycle,
    };
  }

  factory Committee.fromMap(Map<String, dynamic> map) {
    return Committee(
      id: map['id'],
      creatorId: map['creator_id'],
      name: map['name'],
      description: map['description'],
      contributionAmount: map['contribution_amount'].toDouble(),
      maxMembers: map['max_members'],
      cycleLengthDays: map['cycle_length_days'],
      paymentDeadlineDays: map['payment_deadline_days'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      currentMembers: map['current_members'] ?? 0,
      inviteCode: map['invite_code'],
      rules: map['rules'],
      allowLatePayments: map['allow_late_payments'] == 1,
      allowPartialPayments: map['allow_partial_payments'] == 1,
      noRepeatUntilAllWin: map['no_repeat_until_all_win'] == 1,
      currentCycle: map['current_cycle'] ?? 1,
    );
  }

  Committee copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    double? contributionAmount,
    int? maxMembers,
    int? cycleLengthDays,
    int? paymentDeadlineDays,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    int? currentMembers,
    String? inviteCode,
    String? rules,
    bool? allowLatePayments,
    bool? allowPartialPayments,
    bool? noRepeatUntilAllWin,
    int? currentCycle,
  }) {
    return Committee(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      maxMembers: maxMembers ?? this.maxMembers,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      paymentDeadlineDays: paymentDeadlineDays ?? this.paymentDeadlineDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      currentMembers: currentMembers ?? this.currentMembers,
      inviteCode: inviteCode ?? this.inviteCode,
      rules: rules ?? this.rules,
      allowLatePayments: allowLatePayments ?? this.allowLatePayments,
      allowPartialPayments: allowPartialPayments ?? this.allowPartialPayments,
      noRepeatUntilAllWin: noRepeatUntilAllWin ?? this.noRepeatUntilAllWin,
      currentCycle: currentCycle ?? this.currentCycle,
    );
  }
}
