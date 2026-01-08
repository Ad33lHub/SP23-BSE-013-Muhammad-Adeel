import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../../services/sales_service.dart';
import '../../models/sale.dart';
import '../../models/cart_item.dart';
import 'receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _amountController = TextEditingController();
  final SalesService _salesService = SalesService();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _completeSale() async {
    final cart = context.read<CartProvider>();

    if (_selectedMethod == PaymentMethod.cash) {
      final amountReceived = double.tryParse(_amountController.text) ?? 0;
      if (amountReceived < cart.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient amount received'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      // Generate sale number
      final saleNumber = await _salesService.generateSaleNumber();

      // Calculate change
      final amountReceived = _selectedMethod == PaymentMethod.cash
          ? double.parse(_amountController.text)
          : cart.total;
      final change = amountReceived - cart.total;

      // Create sale
      final sale = Sale(
        id: '',
        saleNumber: saleNumber,
        items: cart.items,
        subtotal: cart.subtotal,
        taxRate: cart.taxRate,
        taxAmount: cart.taxAmount,
        cartDiscount: cart.cartDiscount,
        cartDiscountType: cart.cartDiscountType,
        totalAmount: cart.total,
        paymentMethod: _selectedMethod,
        amountReceived: amountReceived,
        changeGiven: change,
        createdAt: DateTime.now(),
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      // Complete sale (saves to Firestore and updates stock)
      await _salesService.completeSale(sale);

      setState(() => _isProcessing = false);

      if (mounted) {
        // Navigate to receipt
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(sale: sale),
          ),
        );

        // Clear cart
        context.read<CartProvider>().clearCart();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete sale: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                      'Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Order Summary
                          GlassmorphicContainer(
                            width: double.infinity,
                            height: 80,
                            borderRadius: 16,
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildRow('Items', '${cart.totalQuantity}'),
                                  const SizedBox(height: 8),
                                  _buildRow('Total Amount', '\$${cart.total.toStringAsFixed(2)}', 
                                            isBold: true, valueColor: Colors.green),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Payment Method
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildPaymentMethodCard(
                                  PaymentMethod.cash,
                                  Icons.money,
                                  'Cash',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPaymentMethodCard(
                                  PaymentMethod.card,
                                  Icons.credit_card,
                                  'Card',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Amount Received (for cash)
                          if (_selectedMethod == PaymentMethod.cash) ...[
                            const Text(
                              'Amount Received',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GlassmorphicContainer(
                              width: double.infinity,
                              height: 80,
                              borderRadius: 16,
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
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  prefixStyle: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: '0.00',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Change
                            if (_amountController.text.isNotEmpty) ...[
                              GlassmorphicContainer(
                                width: double.infinity,
                                height: 80,
                                borderRadius: 16,
                                blur: 15,
                                alignment: Alignment.center,
                                border: 2,
                                linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.withOpacity(0.1),
                                    Colors.blue.withOpacity(0.05),
                                  ],
                                ),
                                borderGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.withOpacity(0.5),
                                    Colors.blue.withOpacity(0.2),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Change',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$${((double.tryParse(_amountController.text) ?? 0) - cart.total).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],

                          const SizedBox(height: 32),

                          // Complete Sale Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _completeSale,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Complete Sale',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, IconData icon, String label) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 100,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  Colors.green.withOpacity(0.8),
                  Colors.green.withOpacity(0.5),
                ]
              : [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.2),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
