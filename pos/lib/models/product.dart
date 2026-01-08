import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final double cost;
  final String category;
  final String? barcode;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.category,
    this.barcode,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Check if product is low on stock
  bool get isLowStock => stockQuantity <= lowStockThreshold;

  // Calculate profit margin
  double get profitMargin => price - cost;

  // Calculate profit percentage
  double get profitPercentage => 
      cost > 0 ? ((price - cost) / cost) * 100 : 0;

  // Create from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      sku: data['sku'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      barcode: data['barcode'],
      stockQuantity: data['stockQuantity'] ?? 0,
      lowStockThreshold: data['lowStockThreshold'] ?? 10,
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'category': category,
      'barcode': barcode,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  // Create a copy with updated fields
  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    double? price,
    double? cost,
    String? category,
    String? barcode,
    int? stockQuantity,
    int? lowStockThreshold,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
