import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:travel_manager/core/app_constants.dart';
import 'package:travel_manager/data/repositories/trip_repository.dart';
import 'package:travel_manager/services/connectivity_service.dart';
import 'package:travel_manager/services/local_storage_service.dart';
import 'dart:developer' as developer;

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
      developer.log('Error loading trips from Firebase: $e');
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
      developer.log('Loaded ${_trips.length} trips from local storage');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load local trips: ${e.toString()}');
      developer.log('Error loading trips from local storage: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new trip
  Future<bool> addTrip(Map<String, dynamic> trip) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Ensure we're working with a copy, not the original object
      final tripData = Map<String, dynamic>.from(trip);
      
      if (_isOnline) {
        // Add to Firebase
        final tripId = await _tripRepository.addTrip(tripData);
        if (tripId != null) {
          tripData[AppConstants.tripId] = tripId;
        }
      } else if (!tripData.containsKey(AppConstants.tripId) || tripData[AppConstants.tripId] == null) {
        // Generate a local ID if offline and no ID exists
        tripData[AppConstants.tripId] = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Always save locally, regardless of online status
      await _localStorageService.saveTrip(tripData);
      
      _trips.add(tripData);
      developer.log('Added new trip: ${tripData[AppConstants.tripId]}');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add trip: ${e.toString()}');
      developer.log('Error adding trip: $e');
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
      // Ensure we're working with a copy, not the original object
      final tripData = Map<String, dynamic>.from(updatedTrip);
      
      // Ensure ID is in the trip data
      tripData[AppConstants.tripId] = tripId;
      
      if (_isOnline) {
        // Update in Firebase
        await _tripRepository.updateTrip(tripId, tripData);
      }
      
      // Always update locally, regardless of online status
      await _localStorageService.saveTrip(tripData);
      
      // Update in-memory list
      final index = _trips.indexWhere((trip) => trip[AppConstants.tripId] == tripId);
      if (index != -1) {
        _trips[index] = tripData;
      }
      
      developer.log('Updated trip: $tripId');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update trip: ${e.toString()}');
      developer.log('Error updating trip: $e');
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
      _trips.removeWhere((trip) => trip[AppConstants.tripId] == tripId);
      
      developer.log('Deleted trip: $tripId');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete trip: ${e.toString()}');
      developer.log('Error deleting trip: $e');
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
      developer.log('Error searching trips: $e');
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
      developer.log('Error filtering trips by date: $e');
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
      developer.log('Error filtering trips by country: $e');
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
      developer.log('Error syncing trips: $e');
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
    try {
      // Clear local storage first to prevent duplicate entries
      await _localStorageService.clearAll();
      
      // Save each trip individually
      for (final trip in trips) {
        // Make sure we're working with a copy
        final tripData = Map<String, dynamic>.from(trip);
        
        // Make sure ID uses the AppConstants key
        if (tripData.containsKey('id') && !tripData.containsKey(AppConstants.tripId)) {
          tripData[AppConstants.tripId] = tripData['id'];
        }
        
        await _localStorageService.saveTrip(tripData);
      }
      
      developer.log('Saved ${trips.length} trips to local storage');
    } catch (e) {
      developer.log('Error saving trips locally: $e');
      _setError('Failed to save trips locally: ${e.toString()}');
    }
  }
} 