import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';

class SyncProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingCount = 0;
  String? _syncMessage;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingCount => _pendingCount;
  String? get syncMessage => _syncMessage;

  SyncProvider() {
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    _pendingCount = await _syncService.getPendingCount();
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncMessage = 'Syncing...';
    notifyListeners();

    try {
      final result = await _syncService.syncAll();
      
      if (result['success'] == true) {
        _lastSyncTime = DateTime.now();
        _syncMessage = 'Synced ${ result['synced']} items';
        
        if (result['failed'] > 0) {
          _syncMessage = '$_syncMessage, ${result['failed']} failed';
        }
      } else {
        _syncMessage = result['message'] as String?;
      }

      await _loadPendingCount();
    } catch (e) {
      _syncMessage = 'Sync failed: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();

      // Clear message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _syncMessage = null;
        notifyListeners();
      });
    }
  }

  Future<void> cacheProducts() async {
    try {
      await _syncService.cacheProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  void incrementPendingCount() {
    _pendingCount++;
    notifyListeners();
  }
}
