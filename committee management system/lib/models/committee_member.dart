class CommitteeMember {
  final String id;
  final String committeeId;
  final String userId;
  final String status; // 'invited', 'joined', 'left', 'removed'
  final DateTime joinedAt;
  final DateTime? leftAt;

  CommitteeMember({
    required this.id,
    required this.committeeId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.leftAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committee_id': committeeId,
      'user_id': userId,
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
    };
  }

  factory CommitteeMember.fromMap(Map<String, dynamic> map) {
    return CommitteeMember(
      id: map['id'],
      committeeId: map['committee_id'],
      userId: map['user_id'],
      status: map['status'],
      joinedAt: DateTime.parse(map['joined_at']),
      leftAt: map['left_at'] != null ? DateTime.parse(map['left_at']) : null,
    );
  }

  CommitteeMember copyWith({
    String? id,
    String? committeeId,
    String? userId,
    String? status,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) {
    return CommitteeMember(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
    );
  }
}
