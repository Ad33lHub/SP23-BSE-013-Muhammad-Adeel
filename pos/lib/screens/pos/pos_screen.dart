import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/product_quick_card.dart';
import 'checkout_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPriceOverrideDialog(CartItem item) {
    final TextEditingController priceController = TextEditingController(
      text: item.hasCustomPrice ? item.customPrice!.toString() : item.product.price.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Override Price', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original: \$${item.product.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Price',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixText: '\$',
                prefixStyle: const TextStyle(color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CartProvider>().setCustomPrice(item.product.id, null);
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price > 0) {
                context.read<CartProvider>().setCustomPrice(item.product.id, price);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid price'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(CartItem item) {
    final TextEditingController discountController = TextEditingController(
      text: item.discount > 0 ? item.discount.toString() : '',
    );
    DiscountType selectedType = item.discountType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Apply Discount', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DiscountType>(
                      title: const Text('%', style: TextStyle(color: Colors.white)),
                      value: DiscountType.percentage,
                      groupValue: selectedType,
                      onChanged: (value) => setState(() => selectedType = value!),
                      activeColor: Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DiscountType>(
                      title: const Text('\$', style: TextStyle(color: Colors.white)),
                      value: DiscountType.fixed,
                      groupValue: selectedType,
                      onChanged: (value) => setState(() => selectedType = value!),
                      activeColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: selectedType == DiscountType.percentage ? 'Percentage' : 'Amount',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixText: selectedType == DiscountType.percentage ? '' : '\$',
                  suffixText: selectedType == DiscountType.percentage ? '%' : '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<CartProvider>().applyItemDiscount(item.product.id, 0, selectedType);
                Navigator.pop(ctx);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.orange)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                final discount = double.tryParse(discountController.text) ?? 0;
                try {
                  context.read<CartProvider>().applyItemDiscount(item.product.id, discount, selectedType);
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartDiscountDialog() {
    final cartProvider = context.read<CartProvider>();
    final TextEditingController discountController = TextEditingController(
      text: cartProvider.cartDiscount > 0 ? cartProvider.cartDiscount.toString() : '',
    );
    DiscountType selectedType = cartProvider.cartDiscountType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cart Discount', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DiscountType>(
                      title: const Text('%', style: TextStyle(color: Colors.white)),
                      value: DiscountType.percentage,
                      groupValue: selectedType,
                      onChanged: (value) => setState(() => selectedType = value!),
                      activeColor: Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DiscountType>(
                      title: const Text('\$', style: TextStyle(color: Colors.white)),
                      value: DiscountType.fixed,
                      groupValue: selectedType,
                      onChanged: (value) => setState(() => selectedType = value!),
                      activeColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: selectedType == DiscountType.percentage ? 'Percentage' : 'Amount',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixText: selectedType == DiscountType.percentage ? '' : '\$',
                  suffixText: selectedType == DiscountType.percentage ? '%' : '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<CartProvider>().clearCartDiscount();
                Navigator.pop(ctx);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.orange)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                final discount = double.tryParse(discountController.text) ?? 0;
                try {
                  context.read<CartProvider>().applyCartDiscount(discount, selectedType);
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left Panel - Products
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'POS - Billing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: 50,
                        borderRadius: 12,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            context.read<ProductProvider>().setSearchQuery(value);
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category filter
                    Consumer<ProductProvider>(
                      builder: (context, provider, _) {
                        final categories = provider.categories;
                        return SizedBox(
                          height: 35,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected =  _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedCategory = category);
                                    provider.setCategory(category);
                                  },
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  selectedColor: Colors.purple.withOpacity(0.5),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isSelected 
                                          ? Colors.purple.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Products grid
                    Expanded(
                      child: Consumer<ProductProvider>(
                        builder: (context, provider, _) {
                          final products = provider.filteredProducts;
                          
                          if (products.isEmpty) {
                            return Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductQuickCard(
                                product: product,
                                onTap: () {
                                  if (product.stockQuantity > 0) {
                                    context.read<CartProvider>().addItem(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart'),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Out of stock'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              //Right Panel - Cart
              Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E).withOpacity(0.9),
                      const Color(0xFF0F2027).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return Column(
                      children: [
                        // Cart header
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (cart.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => cart.clearCart(),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  label: const Text('Clear', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),

                        // Cart items
                        Expanded(
                          child: cart.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart_outlined, 
                                          size: 64, color: Colors.white.withOpacity(0.3)),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Cart is empty',
                                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: cart.items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = cart.items[index];
                                    return CartItemCard(
                                      item: item,
                                      onIncrement: () {
                                        try {
                                          cart.incrementQuantity(item.product.id);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(e.toString()), 
                                                     backgroundColor: Colors.red),
                                          );
                                        }
                                      },
                                      onDecrement: () => cart.decrementQuantity(item.product.id),
                                      onRemove: () => cart.removeItem(item.product.id),
                                      onPriceEdit: () => _showPriceOverrideDialog(item),
                                      onDiscountEdit: () => _showDiscountDialog(item),
                                    );
                                  },
                                ),
                        ),

                        // Cart summary
                        if (cart.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Subtotal
                                _buildSummaryRow('Subtotal', cart.subtotal),
                                
                                // Cart discount
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Cart Discount',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.purple[300], size: 16),
                                          onPressed: _showCartDiscountDialog,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      cart.cartDiscountAmount > 0 
                                          ? '-\$${cart.cartDiscountAmount.toStringAsFixed(2)}'
                                          : '\$0.00',
                                      style: TextStyle(
                                        color: cart.cartDiscountAmount > 0 
                                            ? Colors.purple[300] 
                                            : Colors.white.withOpacity(0.5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white24, height: 24),
                                
                                // Tax
                                _buildSummaryRow('Tax (${cart.taxRate}%)', cart.taxAmount),
                                const Divider(color: Colors.white24, height: 24),
                                
                                // Total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\$${cart.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Checkout button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const CheckoutScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Checkout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
