import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_manager/core/app_constants.dart';
import 'dart:developer' as developer;

class LocalStorageService {
  late Box _settingsBox;
  late Box _tripsBox;
  
  Future<void> init() async {
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _tripsBox = await Hive.openBox(AppConstants.tripsBox);
  }
  
  // Theme settings
  ThemeMode getThemeMode() {
    final themeModeString = _settingsBox.get(AppConstants.themeKey, defaultValue: 'system');
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }
    await _settingsBox.put(AppConstants.themeKey, themeModeString);
  }
  
  // Language settings
  String getLanguageCode() {
    return _settingsBox.get(AppConstants.languageKey, defaultValue: AppConstants.defaultLanguage);
  }
  
  Future<void> setLanguageCode(String languageCode) async {
    await _settingsBox.put(AppConstants.languageKey, languageCode);
  }
  
  // Trip storage
  Future<void> saveTrip(Map<String, dynamic> trip) async {
    // Ensure the trip has an ID
    String id;
    if (trip.containsKey(AppConstants.tripId) && trip[AppConstants.tripId] != null) {
      id = trip[AppConstants.tripId].toString();
    } else {
      id = 'trip_${DateTime.now().millisecondsSinceEpoch}';
      trip[AppConstants.tripId] = id;
    }
    
    try {
      // Make a clean copy of the trip data for storage
      final tripToSave = Map<String, dynamic>.from(trip);
      await _tripsBox.put(id, tripToSave);
      developer.log('Saved trip with ID: $id to local storage');
    } catch (e) {
      developer.log('Error saving trip: $e');
      rethrow;
    }
  }
  
  Future<void> deleteTrip(String id) async {
    await _tripsBox.delete(id);
    developer.log('Deleted trip with ID: $id from local storage');
  }
  
  List<Map<String, dynamic>> getAllTrips() {
    final trips = _tripsBox.values.map((trip) => Map<String, dynamic>.from(trip)).toList();
    developer.log('Retrieved ${trips.length} trips from local storage');
    return trips;
  }
  
  Map<String, dynamic>? getTrip(String id) {
    final trip = _tripsBox.get(id);
    if (trip == null) return null;
    return Map<String, dynamic>.from(trip);
  }
  
  // Search and filter trips
  List<Map<String, dynamic>> searchTrips(String searchQuery) {
    if (searchQuery.isEmpty) {
      return getAllTrips();
    }
    
    final query = searchQuery.toLowerCase();
    return _tripsBox.values
        .map((trip) => Map<String, dynamic>.from(trip))
        .where((trip) {
          final name = (trip[AppConstants.tripName] ?? '').toString().toLowerCase();
          final destination = (trip[AppConstants.tripDestination] ?? '').toString().toLowerCase();
          final notes = (trip[AppConstants.tripNotes] ?? '').toString().toLowerCase();
          
          return name.contains(query) || 
                 destination.contains(query) || 
                 notes.contains(query);
        })
        .toList();
  }
  
  List<Map<String, dynamic>> filterTripsByDate(DateTime startDate, DateTime endDate) {
    return _tripsBox.values
        .map((trip) => Map<String, dynamic>.from(trip))
        .where((trip) {
          final tripStartDate = DateTime.tryParse(trip[AppConstants.tripStartDate] ?? '');
          final tripEndDate = DateTime.tryParse(trip[AppConstants.tripEndDate] ?? '');
          
          if (tripStartDate == null || tripEndDate == null) {
            return false;
          }
          
          // Check if trip dates overlap with filter dates
          return !(tripEndDate.isBefore(startDate) || tripStartDate.isAfter(endDate));
        })
        .toList();
  }
  
  List<Map<String, dynamic>> filterTripsByCountry(String country) {
    return _tripsBox.values
        .map((trip) => Map<String, dynamic>.from(trip))
        .where((trip) {
          final destination = (trip[AppConstants.tripDestination] ?? '').toString().toLowerCase();
          return destination.contains(country.toLowerCase());
        })
        .toList();
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _tripsBox.clear();
    // Don't clear settings as they should persist
  }
} 