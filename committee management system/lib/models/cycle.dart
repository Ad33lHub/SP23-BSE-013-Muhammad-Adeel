class Cycle {
  final String id;
  final String committeeId;
  final int cycleNumber; // 1-based cycle number
  final DateTime startDate;
  final DateTime endDate;
  final DateTime paymentDeadline;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime createdAt;
  final String? winnerId; // ID of the winner for this cycle
  final double totalCollected; // Total amount collected in this cycle
  final int membersPaid; // Number of members who paid
  final bool isRandomized; // Whether winner selection has been performed

  Cycle({
    required this.id,
    required this.committeeId,
    required this.cycleNumber,
    required this.startDate,
    required this.endDate,
    required this.paymentDeadline,
    required this.status,
    required this.createdAt,
    this.winnerId,
    this.totalCollected = 0.0,
    this.membersPaid = 0,
    this.isRandomized = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committee_id': committeeId,
      'cycle_number': cycleNumber,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'payment_deadline': paymentDeadline.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'winner_id': winnerId,
      'total_collected': totalCollected,
      'members_paid': membersPaid,
      'is_randomized': isRandomized ? 1 : 0,
    };
  }

  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      id: map['id'],
      committeeId: map['committee_id'],
      cycleNumber: map['cycle_number'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      paymentDeadline: DateTime.parse(map['payment_deadline']),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      winnerId: map['winner_id'],
      totalCollected: map['total_collected']?.toDouble() ?? 0.0,
      membersPaid: map['members_paid'] ?? 0,
      isRandomized: map['is_randomized'] == 1,
    );
  }

  Cycle copyWith({
    String? id,
    String? committeeId,
    int? cycleNumber,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? paymentDeadline,
    String? status,
    DateTime? createdAt,
    String? winnerId,
    double? totalCollected,
    int? membersPaid,
    bool? isRandomized,
  }) {
    return Cycle(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentDeadline: paymentDeadline ?? this.paymentDeadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      winnerId: winnerId ?? this.winnerId,
      totalCollected: totalCollected ?? this.totalCollected,
      membersPaid: membersPaid ?? this.membersPaid,
      isRandomized: isRandomized ?? this.isRandomized,
    );
  }
}
