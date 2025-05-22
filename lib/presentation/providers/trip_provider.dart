import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:travel_manager/data/repositories/trip_repository.dart';
import 'package:travel_manager/services/connectivity_service.dart';
import 'package:travel_manager/services/local_storage_service.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _tripRepository;
  final ConnectivityService _connectivityService = ConnectivityService();
  late LocalStorageService _localStorageService;
  
  List<Map<String, dynamic>> _trips = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isOnline = true;
  
  // Constructor
  TripProvider(this._tripRepository) {
    _init();
  }
  
  // Getters
  List<Map<String, dynamic>> get trips => _trips;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  
  // Initialize
  Future<void> _init() async {
    _localStorageService = LocalStorageService();
    await _localStorageService.init();
    
    // Listen for connectivity changes
    _connectivityService.connectivityStream.listen((status) {
      _isOnline = status != ConnectivityResult.none;
      notifyListeners();
      
      // Load trips when connectivity changes
      if (_isOnline) {
        loadTrips();
      } else {
        loadLocalTrips();
      }
    });
    
    // Check initial connectivity
    _isOnline = await _connectivityService.isConnected();
    
    // Load initial data
    if (_isOnline) {
      loadTrips();
    } else {
      loadLocalTrips();
    }
  }
  
  // Load trips from Firebase
  Future<void> loadTrips() async {
    if (!_isOnline) {
      loadLocalTrips();
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _trips = await _tripRepository.getUserTrips();
      
      // Save trips locally for offline access
      _saveTripsLocally(_trips);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load trips: ${e.toString()}');
      // Fall back to local trips
      loadLocalTrips();
    } finally {
      _setLoading(false);
    }
  }
  
  // Load trips from local storage
  Future<void> loadLocalTrips() async {
    _setLoading(true);
    _clearError();
    
    try {
      _trips = _localStorageService.getAllTrips();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load local trips: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new trip
  Future<bool> addTrip(Map<String, dynamic> trip) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_isOnline) {
        // Add to Firebase
        final tripId = await _tripRepository.addTrip(trip);
        if (tripId != null) {
          trip['id'] = tripId;
        }
      }
      
      // Always save locally, regardless of online status
      await _localStorageService.saveTrip(trip);
      
      _trips.add(trip);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an existing trip
  Future<bool> updateTrip(String tripId, Map<String, dynamic> updatedTrip) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Ensure ID is in the trip data
      updatedTrip['id'] = tripId;
      
      if (_isOnline) {
        // Update in Firebase
        await _tripRepository.updateTrip(tripId, updatedTrip);
      }
      
      // Always update locally, regardless of online status
      await _localStorageService.saveTrip(updatedTrip);
      
      // Update in-memory list
      final index = _trips.indexWhere((trip) => trip['id'] == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_isOnline) {
        // Delete from Firebase
        await _tripRepository.deleteTrip(tripId);
      }
      
      // Always delete locally, regardless of online status
      await _localStorageService.deleteTrip(tripId);
      
      // Remove from in-memory list
      _trips.removeWhere((trip) => trip['id'] == tripId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Search trips
  Future<void> searchTrips(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_isOnline) {
        _trips = await _tripRepository.searchTrips(query);
      } else {
        _trips = _localStorageService.searchTrips(query);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Filter trips by date
  Future<void> filterByDate(DateTime startDate, DateTime endDate) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_isOnline) {
        _trips = await _tripRepository.filterTripsByDate(startDate, endDate);
      } else {
        _trips = _localStorageService.filterTripsByDate(startDate, endDate);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Filter failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Filter trips by country
  Future<void> filterByCountry(String country) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_isOnline) {
        _trips = await _tripRepository.filterTripsByCountry(country);
      } else {
        _trips = _localStorageService.filterTripsByCountry(country);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Filter failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Sync local trips with Firebase
  Future<bool> syncTrips() async {
    if (!_isOnline) {
      _setError('Cannot sync while offline');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // Get all local trips
      final localTrips = _localStorageService.getAllTrips();
      
      // Sync to Firebase
      final result = await _tripRepository.syncTrips(localTrips);
      
      // If successful, reload trips from Firebase
      if (result) {
        await loadTrips();
      }
      
      return result;
    } catch (e) {
      _setError('Sync failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Reset filters and load all trips
  Future<void> resetFilters() async {
    if (_isOnline) {
      loadTrips();
    } else {
      loadLocalTrips();
    }
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  Future<void> _saveTripsLocally(List<Map<String, dynamic>> trips) async {
    // Clear existing trips
    await _localStorageService.clearAll();
    
    // Save each trip
    for (final trip in trips) {
      await _localStorageService.saveTrip(trip);
    }
  }
} 