import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  stockIn,
  stockOut,
}

class StockTransaction {
  final String id;
  final String productId;
  final String productName;
  final TransactionType type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String notes;
  final DateTime createdAt;
  final String createdBy;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  // Get transaction type as string for Firestore
  String get typeString => 
      type == TransactionType.stockIn ? 'stock_in' : 'stock_out';

  // Get stock change (positive for in, negative for out)
  int get stockChange => 
      type == TransactionType.stockIn ? quantity : -quantity;

  // Create from Firestore document
  factory StockTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockTransaction(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      type: data['type'] == 'stock_in' 
          ? TransactionType.stockIn 
          : TransactionType.stockOut,
      quantity: data['quantity'] ?? 0,
      previousStock: data['previousStock'] ?? 0,
      newStock: data['newStock'] ?? 0,
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'type': typeString,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  // Create a copy with updated fields
  StockTransaction copyWith({
    String? id,
    String? productId,
    String? productName,
    TransactionType? type,
    int? quantity,
    int? previousStock,
    int? newStock,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return StockTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
