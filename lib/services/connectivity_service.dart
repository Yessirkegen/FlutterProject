import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Stream to listen for connectivity changes
  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged
          .map((results) => results.isNotEmpty ? results.first : ConnectivityResult.none);
  
  // Check current connectivity state
  Future<bool> isConnected() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }
  
  // Get the current connectivity status
  Future<ConnectivityResult> getCurrentConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }
} 