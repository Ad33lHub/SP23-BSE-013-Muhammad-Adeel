import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'database_helper.dart';
import '../models/sale.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Sync all pending data
  Future<Map<String, dynamic>> syncAll() async {
    if (_isSyncing) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    _isSyncing = true;
    int successCount = 0;
    int failCount = 0;

    try {
      // Sync offline sales
      final result = await syncOfflineSales();
      successCount += result['success'] as int;
      failCount += result['failed'] as int;

      // Sync queue items
      final queueResult = await syncQueue();
      successCount += queueResult['success'] as int;
      failCount += queueResult['failed'] as int;

      _lastSyncTime = DateTime.now();

      return {
        'success': true,
        'synced': successCount,
        'failed': failCount,
        'message': 'Sync completed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Sync failed: $e',
      };
    } finally {
      _isSyncing = false;
    }
  }

  // Sync offline sales to Firestore
  Future<Map<String, int>> syncOfflineSales() async {
    int successCount = 0;
    int failCount = 0;

    try {
      final pendingSales = await _dbHelper.getPendingSales();

      for (final saleRow in pendingSales) {
        try {
          final saleData = jsonDecode(saleRow['saleData'] as String) as Map<String, dynamic>;
          
          // Upload to Firestore
          await _firestore.collection('sales').add(saleData);
          
          // Mark as synced
          await _dbHelper.markSaleAsSynced(saleRow['id'] as String);
          successCount++;
        } catch (e) {
          failCount++;
          print('Failed to sync sale ${saleRow['id']}: $e');
        }
      }
    } catch (e) {
      print('Error syncing sales: $e');
    }

    return {'success': successCount, 'failed': failCount};
  }

  // Sync queue items
  Future<Map<String, int>> syncQueue() async {
    int successCount = 0;
    int failCount = 0;

    try {
      final queueItems = await _dbHelper.getSyncQueue();

      for (final item in queueItems) {
        try {
          final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;
          final operation = item['operation'] as String;
          final collection = item['collection'] as String;
          final docId = item['documentId'] as String?;

          // Execute operation
          if (operation == 'create') {
            await _firestore.collection(collection).add(data);
          } else if (operation == 'update' && docId != null) {
            await _firestore.collection(collection).doc(docId).update(data);
          } else if (operation == 'delete' && docId != null) {
            await _firestore.collection(collection).doc(docId).delete();
          }

          // Remove from queue
          await _dbHelper.removeFromSyncQueue(item['id'] as int);
          successCount++;
        } catch (e) {
          // Increment attempt count
          await _dbHelper.incrementSyncAttempt(item['id'] as int);
          failCount++;
          print('Failed to sync queue item ${item['id']}: $e');
        }
      }
    } catch (e) {
      print('Error syncing queue: $e');
    }

    return {'success': successCount, 'failed': failCount};
  }

  // Get pending sync count
  Future<int> getPendingCount() async {
    try {
      final salesCount = await _dbHelper.getPendingSalesCount();
      final queueItems = await _dbHelper.getSyncQueue();
      return salesCount + queueItems.length;
    } catch (e) {
      return 0;
    }
  }

  // Cache products for offline use
  Future<void> cacheProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      
      for (final doc in snapshot.docs) {
        await _dbHelper.cacheProduct(doc.id, doc.data());
      }
    } catch (e) {
      print('Error caching products: $e');
    }
  }

  // Get cached products (for offline mode)
  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    try {
      return await _dbHelper.getCachedProducts();
    } catch (e) {
      print('Error getting cached products: $e');
      return [];
    }
  }
}
