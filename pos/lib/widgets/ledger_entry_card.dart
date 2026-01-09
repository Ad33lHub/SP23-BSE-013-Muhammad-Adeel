import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../models/ledger_entry.dart';

class LedgerEntryCard extends StatelessWidget {
  final LedgerEntry entry;

  const LedgerEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: entry.isDebit
            ? [
                Colors.orange.withOpacity(0.15),
                Colors.orange.withOpacity(0.05),
              ]
            : [
                Colors.green.withOpacity(0.15),
                Colors.green.withOpacity(0.05),
              ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: entry.isDebit
            ? [
                Colors.orange.withOpacity(0.5),
                Colors.orange.withOpacity(0.2),
              ]
            : [
                Colors.green.withOpacity(0.5),
                Colors.green.withOpacity(0.2),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.isDebit
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: entry.isDebit
                      ? Colors.orange.withOpacity(0.6)
                      : Colors.green.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Icon(
                entry.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                color: entry.isDebit ? Colors.orange : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(entry.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance: \$${entry.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.typeString,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.isDebit ? '+' : '-'}\$${entry.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: entry.isDebit ? Colors.orange : Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
