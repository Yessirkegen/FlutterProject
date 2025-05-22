import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Stream to listen for connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged
          .map((list) => list.isNotEmpty ? list.first : ConnectivityResult.none);
  
  // Check current connectivity state
  Future<bool> isConnected() async {
    final List<ConnectivityResult> list =
      await _connectivity.checkConnectivity();
    final status = list.isNotEmpty ? list.first : ConnectivityResult.none;
    return status != ConnectivityResult.none;
  }
  
  // Get the current connectivity status
  Future<ConnectivityResult> getCurrentConnectivity() async {
    final List<ConnectivityResult> list =
      await _connectivity.checkConnectivity();
    return list.isNotEmpty ? list.first : ConnectivityResult.none;
  }
} 