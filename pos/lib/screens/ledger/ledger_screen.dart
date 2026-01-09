import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/customer_provider.dart';
import '../../providers/ledger_provider.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/ledger_entry_card.dart';
import '../../models/customer.dart';
import 'payment_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().loadCustomers();
      context.read<LedgerProvider>().loadSummary();
      context.read<LedgerProvider>().loadCustomersWithBalance();
    });
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
                      'Ledger',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Consumer<LedgerProvider>(
                  builder: (context, ledger, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Outstanding',
                            '\$${ledger.totalOutstanding.toStringAsFixed(2)}',
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Customers',
                            '${ledger.outstandingCustomersCount}',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Today',
                            '\$${ledger.todayPayments.toStringAsFixed(2)}',
                            Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Customers with balance or ledger entries
              Expanded(
                child: _selectedCustomer == null
                    ? _buildCustomersList()
                    : _buildCustomerLedger(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomersList() {
    return Consumer<LedgerProvider>(
      builder: (context, ledger, _) {
        final customers = ledger.customersWithBalance;

        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No outstanding balances',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Customers with Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: customers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return CustomerCard(
                    customer: customer,
                    onTap: () {
                      setState(() => _selectedCustomer = customer);
                      context.read<LedgerProvider>().loadCustomerLedger(customer.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerLedger() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _selectedCustomer = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCustomer!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Balance: \$${_selectedCustomer!.outstandingBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.orange[300],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedCustomer!.hasBalance)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(customer: _selectedCustomer!),
                      ),
                    ).then((_) {
                      // Reload data after payment
                      context.read<CustomerProvider>().loadCustomers();
                      context.read<LedgerProvider>().loadCustomerLedger(_selectedCustomer!.id);
                      context.read<LedgerProvider>().loadSummary();
                    });
                  },
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Pay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ledger entries
        Expanded(
          child: Consumer<LedgerProvider>(
            builder: (context, ledger, _) {
              final entries = ledger.entries;

              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    'No ledger entries',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return LedgerEntryCard(entry: entries[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 70,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.5),
          color.withOpacity(0.2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
