import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isOnline = true;
  DateTime? _lastOnlineTime;
  
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  DateTime? get lastOnlineTime => _lastOnlineTime;
  
  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isOnline = false;
      notifyListeners();
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    
    _isOnline = result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
    
    if (_isOnline) {
      _lastOnlineTime = DateTime.now();
    }
    
    // If status changed, notify listeners
    if (wasOnline != _isOnline) {
      notifyListeners();
      
      // If just came online, trigger sync
      if (_isOnline && !wasOnline) {
        debugPrint('📶 Connection restored - ready to sync');
      } else if (!_isOnline && wasOnline) {
        debugPrint('📵 Connection lost - entering offline mode');
      }
    }
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
