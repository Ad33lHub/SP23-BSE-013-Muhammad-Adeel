class PaymentProof {
  final String id;
  final String committeeId;
  final String cycleId;
  final String userId;
  final double amount;
  final String description;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? receiptImagePath;
  final String? transactionId;
  final String? payerName;
  final DateTime paymentDate;
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final bool isLate; // Whether payment was submitted after deadline
  final bool isPartial; // Whether amount is less than required

  PaymentProof({
    required this.id,
    required this.committeeId,
    required this.cycleId,
    required this.userId,
    required this.amount,
    required this.description,
    required this.status,
    this.rejectionReason,
    this.receiptImagePath,
    this.transactionId,
    this.payerName,
    required this.paymentDate,
    required this.submittedAt,
    this.verifiedAt,
    this.verifiedBy,
    this.isLate = false,
    this.isPartial = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committee_id': committeeId,
      'cycle_id': cycleId,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'status': status,
      'rejection_reason': rejectionReason,
      'receipt_image_path': receiptImagePath,
      'transaction_id': transactionId,
      'payer_name': payerName,
      'payment_date': paymentDate.toIso8601String(),
      'submitted_at': submittedAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'is_late': isLate ? 1 : 0,
      'is_partial': isPartial ? 1 : 0,
    };
  }

  factory PaymentProof.fromMap(Map<String, dynamic> map) {
    return PaymentProof(
      id: map['id'],
      committeeId: map['committee_id'],
      cycleId: map['cycle_id'],
      userId: map['user_id'],
      amount: map['amount'].toDouble(),
      description: map['description'],
      status: map['status'],
      rejectionReason: map['rejection_reason'],
      receiptImagePath: map['receipt_image_path'],
      transactionId: map['transaction_id'],
      payerName: map['payer_name'],
      paymentDate: DateTime.parse(map['payment_date']),
      submittedAt: DateTime.parse(map['submitted_at']),
      verifiedAt: map['verified_at'] != null ? DateTime.parse(map['verified_at']) : null,
      verifiedBy: map['verified_by'],
      isLate: map['is_late'] == 1,
      isPartial: map['is_partial'] == 1,
    );
  }

  PaymentProof copyWith({
    String? id,
    String? committeeId,
    String? cycleId,
    String? userId,
    double? amount,
    String? description,
    String? status,
    String? rejectionReason,
    String? receiptImagePath,
    String? transactionId,
    String? payerName,
    DateTime? paymentDate,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    bool? isLate,
    bool? isPartial,
  }) {
    return PaymentProof(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      cycleId: cycleId ?? this.cycleId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      transactionId: transactionId ?? this.transactionId,
      payerName: payerName ?? this.payerName,
      paymentDate: paymentDate ?? this.paymentDate,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      isLate: isLate ?? this.isLate,
      isPartial: isPartial ?? this.isPartial,
    );
  }
}
