class Payment {
  final String id;
  final String committeeId;
  final String userId;
  final double amount;
  final String status; // 'pending', 'verified', 'rejected'
  final String description;
  final String? receiptImagePath;
  final DateTime paymentDate;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;

  Payment({
    required this.id,
    required this.committeeId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.description,
    this.receiptImagePath,
    required this.paymentDate,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committee_id': committeeId,
      'user_id': userId,
      'amount': amount,
      'status': status,
      'description': description,
      'receipt_image_path': receiptImagePath,
      'payment_date': paymentDate.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      committeeId: map['committee_id'],
      userId: map['user_id'],
      amount: map['amount'].toDouble(),
      status: map['status'],
      description: map['description'],
      receiptImagePath: map['receipt_image_path'],
      paymentDate: DateTime.parse(map['payment_date']),
      verifiedAt: map['verified_at'] != null ? DateTime.parse(map['verified_at']) : null,
      verifiedBy: map['verified_by'],
      rejectionReason: map['rejection_reason'],
    );
  }

  Payment copyWith({
    String? id,
    String? committeeId,
    String? userId,
    double? amount,
    String? status,
    String? description,
    String? receiptImagePath,
    DateTime? paymentDate,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? rejectionReason,
  }) {
    return Payment(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      paymentDate: paymentDate ?? this.paymentDate,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
