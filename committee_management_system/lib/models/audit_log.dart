class AuditLog {
  final String id;
  final String committeeId;
  final String? cycleId;
  final String userId; // User who performed the action
  final String action; // 'created', 'joined', 'payment_submitted', 'payment_approved', 'payment_rejected', 'winner_selected', 'cycle_completed'
  final String description;
  final Map<String, dynamic>? metadata; // Additional data specific to the action
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.committeeId,
    this.cycleId,
    required this.userId,
    required this.action,
    required this.description,
    this.metadata,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committee_id': committeeId,
      'cycle_id': cycleId,
      'user_id': userId,
      'action': action,
      'description': description,
      'metadata': metadata != null ? metadata.toString() : null,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'],
      committeeId: map['committee_id'],
      cycleId: map['cycle_id'],
      userId: map['user_id'],
      action: map['action'],
      description: map['description'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  AuditLog copyWith({
    String? id,
    String? committeeId,
    String? cycleId,
    String? userId,
    String? action,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return AuditLog(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      cycleId: cycleId ?? this.cycleId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
