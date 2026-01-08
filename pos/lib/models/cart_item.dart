import 'product.dart';

enum DiscountType {
  percentage,
  fixed,
}

class CartItem {
  final Product product;
  int quantity;
  double? customPrice;
  double discount;
  DiscountType discountType;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.customPrice,
    this.discount = 0,
    this.discountType = DiscountType.percentage,
  });

  // Get the effective unit price (custom or product price)
  double get unitPrice => customPrice ?? product.price;

  // Calculate subtotal (before discount)
  double get subtotal => unitPrice * quantity;

  // Calculate discount amount
  double get discountAmount {
    if (discount == 0) return 0;
    
    if (discountType == DiscountType.percentage) {
      return subtotal * (discount / 100);
    } else {
      return discount;
    }
  }

  // Calculate total (after discount)
  double get total => subtotal - discountAmount;

  // Check if price has been overridden
  bool get hasCustomPrice => customPrice != null;

  // Check if discount is applied
  bool get hasDiscount => discount > 0;

  // Create a copy with updated values
  CartItem copyWith({
    Product? product,
    int? quantity,
    double? customPrice,
    bool clearCustomPrice = false,
    double? discount,
    DiscountType? discountType,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: clearCustomPrice ? null : (customPrice ?? this.customPrice),
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'sku': product.sku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'customPrice': customPrice,
      'discount': discount,
      'discountType': discountType.name,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'total': total,
    };
  }

  @override
  String toString() {
    return 'CartItem(${product.name}, qty: $quantity, total: \$${total.toStringAsFixed(2)})';
  }
}
