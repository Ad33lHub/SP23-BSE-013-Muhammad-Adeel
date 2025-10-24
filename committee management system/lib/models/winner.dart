class Winner {
  final String id;
  final String committeeId;
  final String cycleId;
  final String userId;
  final int cycleNumber;
  final double amountWon;
  final DateTime wonAt;
  final String randomSeed; // For audit trail
  final List<String> eligibleMembers; // List of member IDs who were eligible
  final String? transferProof; // Proof of payment to winner
  final DateTime? transferDate;
  final String? transferTransactionId;

  Winner({
    required this.id,
    required this.committeeId,
    required this.cycleId,
    required this.userId,
    required this.cycleNumber,
    required this.amountWon,
    required this.wonAt,
    required this.randomSeed,
    required this.eligibleMembers,
    this.transferProof,
    this.transferDate,
    this.transferTransactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committee_id': committeeId,
      'cycle_id': cycleId,
      'user_id': userId,
      'cycle_number': cycleNumber,
      'amount_won': amountWon,
      'won_at': wonAt.toIso8601String(),
      'random_seed': randomSeed,
      'eligible_members': eligibleMembers.join(','), // Store as comma-separated string
      'transfer_proof': transferProof,
      'transfer_date': transferDate?.toIso8601String(),
      'transfer_transaction_id': transferTransactionId,
    };
  }

  factory Winner.fromMap(Map<String, dynamic> map) {
    return Winner(
      id: map['id'],
      committeeId: map['committee_id'],
      cycleId: map['cycle_id'],
      userId: map['user_id'],
      cycleNumber: map['cycle_number'],
      amountWon: map['amount_won'].toDouble(),
      wonAt: DateTime.parse(map['won_at']),
      randomSeed: map['random_seed'],
      eligibleMembers: map['eligible_members']?.split(',') ?? [],
      transferProof: map['transfer_proof'],
      transferDate: map['transfer_date'] != null ? DateTime.parse(map['transfer_date']) : null,
      transferTransactionId: map['transfer_transaction_id'],
    );
  }

  Winner copyWith({
    String? id,
    String? committeeId,
    String? cycleId,
    String? userId,
    int? cycleNumber,
    double? amountWon,
    DateTime? wonAt,
    String? randomSeed,
    List<String>? eligibleMembers,
    String? transferProof,
    DateTime? transferDate,
    String? transferTransactionId,
  }) {
    return Winner(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      cycleId: cycleId ?? this.cycleId,
      userId: userId ?? this.userId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      amountWon: amountWon ?? this.amountWon,
      wonAt: wonAt ?? this.wonAt,
      randomSeed: randomSeed ?? this.randomSeed,
      eligibleMembers: eligibleMembers ?? this.eligibleMembers,
      transferProof: transferProof ?? this.transferProof,
      transferDate: transferDate ?? this.transferDate,
      transferTransactionId: transferTransactionId ?? this.transferTransactionId,
    );
  }
}
