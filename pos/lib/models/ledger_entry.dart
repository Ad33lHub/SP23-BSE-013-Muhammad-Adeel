import 'package:cloud_firestore/cloud_firestore.dart';

enum LedgerEntryType {
  debit,  // Customer owes money (credit sale)
  credit, // Customer paid money (payment)
}

class LedgerEntry {
  final String id;
  final String customerId;
  final String customerName;
  final LedgerEntryType type;
  final double amount;
  final double balance; // Running balance after this entry
  final String description;
  final String? saleId; // For debit entries (credit sales)
  final String? paymentMethod; // For credit entries (payments)
  final DateTime createdAt;
  final String createdBy;

  LedgerEntry({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.amount,
    required this.balance,
    required this.description,
    this.saleId,
    this.paymentMethod,
    required this.createdAt,
    required this.createdBy,
  });

  // Check if entry is debit (customer owes)
  bool get isDebit => type == LedgerEntryType.debit;

  // Check if entry is credit (customer paid)
  bool get isCredit => type == LedgerEntryType.credit;

  // Get display string for entry type
  String get typeString => isDebit ? 'Debit' : 'Credit';

  // Get signed amount (positive for debit, negative for credit)
  double get signedAmount => isDebit ? amount : -amount;

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'type': type.name,
      'amount': amount,
      'balance': balance,
      'description': description,
      'saleId': saleId,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  // Create from Firestore document
  factory LedgerEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return LedgerEntry(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      type: data['type'] == 'credit' 
          ? LedgerEntryType.credit 
          : LedgerEntryType.debit,
      amount: (data['amount'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      saleId: data['saleId'],
      paymentMethod: data['paymentMethod'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Create a copy with updated values
  LedgerEntry copyWith({
    String? id,
    String? customerId,
    String? customerName,
    LedgerEntryType? type,
    double? amount,
    double? balance,
    String? description,
    String? saleId,
    String? paymentMethod,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      saleId: saleId ?? this.saleId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'LedgerEntry($typeString: \$${amount.toStringAsFixed(2)}, balance: \$${balance.toStringAsFixed(2)})';
  }
}
