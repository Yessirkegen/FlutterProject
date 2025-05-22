import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Create a stream of connectivity status
  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged.map((List<ConnectivityResult> results) {
        return results.isNotEmpty ? results.first : ConnectivityResult.none;
      });
  
  // Check current connectivity status
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    final hasConnectivity = results.isNotEmpty && results.first != ConnectivityResult.none;
    
    // If we have network connectivity, verify we can actually reach the internet
    if (hasConnectivity) {
      return await _checkInternetAccess();
    }
    
    return false;
  }
  
  // Check actual internet access by trying to reach Firebase
  Future<bool> _checkInternetAccess() async {
    try {
      // Try to connect to Firebase host with a short timeout
      final response = await http.get(
        Uri.parse('https://firestore.googleapis.com/google.firestore.v1.Firestore/Listen/channel'),
        headers: {'Connection': 'keep-alive', 'Content-Length': '0'},
      ).timeout(const Duration(seconds: 5));
      
      final hasInternet = response.statusCode == 200 || response.statusCode == 400;
      developer.log('Internet connectivity check: ${hasInternet ? 'Success' : 'Failed'} (Status: ${response.statusCode})');
      return hasInternet;
    } catch (e) {
      developer.log('Internet connectivity check failed: $e');
      return false;
    }
  }
  
  // Get the current connectivity status
  Future<ConnectivityResult> getCurrentConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }
} 