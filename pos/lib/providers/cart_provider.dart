import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/sale.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  double _taxRate = 10.0; // Default 10% tax
  double _cartDiscount = 0;
  DiscountType _cartDiscountType = DiscountType.percentage;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  double get taxRate => _taxRate;
  double get cartDiscount => _cartDiscount;
  DiscountType get cartDiscountType => _cartDiscountType;

  // Get total number of items
  int get itemCount => _items.length;

  // Get total quantity of all items
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  // Calculate cart subtotal (sum of all item totals after their discounts)
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);

  // Calculate cart discount amount
  double get cartDiscountAmount {
    if (_cartDiscount == 0) return 0;
    
    if (_cartDiscountType == DiscountType.percentage) {
      return subtotal * (_cartDiscount / 100);
    } else {
      return _cartDiscount;
    }
  }

  // Get subtotal after cart discount
  double get subtotalAfterCartDiscount => subtotal - cartDiscountAmount;

  // Calculate tax amount (on subtotal after cart discount)
  double get taxAmount => subtotalAfterCartDiscount * (_taxRate / 100);

  // Calculate final total
  double get total => subtotalAfterCartDiscount + taxAmount;

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Check if cart has items
  bool get isNotEmpty => _items.isNotEmpty;

  // Add item to cart
  void addItem(Product product, {int quantity = 1}) {
    // Check if product already in cart
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(CartItem(
        product: product,
        quantity: quantity,
      ));
    }

    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      // Check stock availability
      if (newQuantity > _items[index].product.stockQuantity) {
        throw Exception('Not enough stock available');
      }

      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  // Increment quantity
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final newQuantity = _items[index].quantity + 1;
      
      // Check stock
      if (newQuantity > _items[index].product.stockQuantity) {
        throw Exception('Not enough stock available');
      }

      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  // Decrement quantity
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final newQuantity = _items[index].quantity - 1;
      
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        notifyListeners();
      }
    }
  }

  // Set custom price for item
  void setCustomPrice(String productId, double? price) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (price != null && price <= 0) {
        throw Exception('Price must be greater than 0');
      }

      _items[index] = _items[index].copyWith(
        customPrice: price,
        clearCustomPrice: price == null,
      );
      notifyListeners();
    }
  }

  // Apply discount to item
  void applyItemDiscount(String productId, double discount, DiscountType type) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (discount < 0) {
        throw Exception('Discount cannot be negative');
      }

      if (type == DiscountType.percentage && discount > 100) {
        throw Exception('Percentage discount cannot exceed 100%');
      }

      _items[index] = _items[index].copyWith(
        discount: discount,
        discountType: type,
      );
      notifyListeners();
    }
  }

  // Remove item from cart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Clear all items
  void clearCart() {
    _items.clear();
    _cartDiscount = 0;
    notifyListeners();
  }

  // Set tax rate
  void setTaxRate(double rate) {
    if (rate < 0) {
      throw Exception('Tax rate cannot be negative');
    }

    _taxRate = rate;
    notifyListeners();
  }

  // Apply cart-level discount
  void applyCartDiscount(double discount, DiscountType type) {
    if (discount < 0) {
      throw Exception('Discount cannot be negative');
    }

    if (type == DiscountType.percentage && discount > 100) {
      throw Exception('Percentage discount cannot exceed 100%');
    }

    _cartDiscount = discount;
    _cartDiscountType = type;
    notifyListeners();
  }

  // Clear cart discount
  void clearCartDiscount() {
    _cartDiscount = 0;
    notifyListeners();
  }

  // Get cart item by product ID
  CartItem? getItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Check if product is in cart
  bool hasProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get quantity of product in cart
  int getProductQuantity(String productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }
}
