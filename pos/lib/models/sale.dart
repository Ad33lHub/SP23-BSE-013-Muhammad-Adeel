import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

enum PaymentMethod {
  cash,
  card,
  credit, // Credit sale (unpaid)
}

class Sale {
  final String id;
  final String saleNumber;
  final List<CartItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double cartDiscount;
  final DiscountType cartDiscountType;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final double amountReceived;
  final double changeGiven;
  final String? customerId; // Customer reference
  final String? customerName; // Customer name
  final bool isPaid; // Payment status (false for credit sales)
  final DateTime createdAt;
  final String createdBy;

  Sale({
    required this.id,
    required this.saleNumber,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    this.cartDiscount = 0,
    this.cartDiscountType = DiscountType.percentage,
    required this.totalAmount,
    required this.paymentMethod,
    required this.amountReceived,
    required this.changeGiven,
    this.customerId,
    this.customerName,
    this.isPaid = true,
    required this.createdAt,
    required this.createdBy,
  });

  // Calculate cart discount amount
  double get cartDiscountAmount {
    if (cartDiscount == 0) return 0;
    
    if (cartDiscountType == DiscountType.percentage) {
      return subtotal * (cartDiscount / 100);
    } else {
      return cartDiscount;
    }
  }

  // Get subtotal after cart discount (before tax)
  double get subtotalAfterDiscount => subtotal - cartDiscountAmount;

  // Get total number of items
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'saleNumber': saleNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'cartDiscount': cartDiscount,
      'cartDiscountType': cartDiscountType.name,
      'cartDiscountAmount': cartDiscountAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'amountReceived': amountReceived,
      'changeGiven': changeGiven,
      'customerId': customerId,
      'customerName': customerName,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  // Create from Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleNumber': saleNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'cartDiscount': cartDiscount,
      'cartDiscountType': cartDiscountType.name,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'amountReceived': amountReceived,
      'changeGiven': changeGiven,
      'customerId': customerId,
      'customerName': customerName,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    PaymentMethod method = PaymentMethod.cash;
    if (data['paymentMethod'] == 'card') {
      method = PaymentMethod.card;
    } else if (data['paymentMethod'] == 'credit') {
      method = PaymentMethod.credit;
    }
    
    return Sale(
      id: doc.id,
      saleNumber: data['saleNumber'] ?? '',
      items: [], // Items are stored as maps, not full CartItem objects
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      taxRate: (data['taxRate'] ?? 0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      cartDiscount: (data['cartDiscount'] ?? 0).toDouble(),
      cartDiscountType: data['cartDiscountType'] == 'fixed' 
          ? DiscountType.fixed 
          : DiscountType.percentage,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: method,
      amountReceived: (data['amountReceived'] ?? 0).toDouble(),
      changeGiven: (data['changeGiven'] ?? 0).toDouble(),
      customerId: data['customerId'],
      customerName: data['customerName'],
      isPaid: data['isPaid'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Create a copy with updated values
  Sale copyWith({
    String? id,
    String? saleNumber,
    List<CartItem>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? cartDiscount,
    DiscountType? cartDiscountType,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    double? amountReceived,
    double? changeGiven,
    String? customerId,
    String? customerName,
    bool? isPaid,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Sale(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      cartDiscount: cartDiscount ?? this.cartDiscount,
      cartDiscountType: cartDiscountType ?? this.cartDiscountType,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: amountReceived ?? this.amountReceived,
      changeGiven: changeGiven ?? this.changeGiven,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
