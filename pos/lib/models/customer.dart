import 'package:cloud_firestore/cloud_firestore.dart';

enum CustomerType {
  walkIn,
  regular,
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final CustomerType customerType;
  final double totalPurchases;
  final int totalOrders;
  final double outstandingBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.customerType = CustomerType.regular,
    this.totalPurchases = 0,
    this.totalOrders = 0,
    this.outstandingBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if customer has outstanding balance
  bool get hasBalance => outstandingBalance > 0;

  // Get customer type display string
  String get customerTypeString {
    return customerType == CustomerType.walkIn ? 'Walk-in' : 'Regular';
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'customerType': customerType.name,
      'totalPurchases': totalPurchases,
      'totalOrders': totalOrders,
      'outstandingBalance': outstandingBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      address: data['address'],
      customerType: data['customerType'] == 'walkIn' 
          ? CustomerType.walkIn 
          : CustomerType.regular,
      totalPurchases: (data['totalPurchases'] ?? 0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      outstandingBalance: (data['outstandingBalance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create a copy with updated values
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    CustomerType? customerType,
    double? totalPurchases,
    int? totalOrders,
    double? outstandingBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalOrders: totalOrders ?? this.totalOrders,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, balance: \$${outstandingBalance.toStringAsFixed(2)})';
  }
}
