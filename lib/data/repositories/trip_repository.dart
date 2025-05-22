import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_manager/core/app_constants.dart';

class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get user ID or null if not authenticated
  String? get _userId => _auth.currentUser?.uid;
  
  // Get all trips for the current user
  Future<List<Map<String, dynamic>>> getUserTrips() async {
    if (_userId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.tripsCollection)
          .where(AppConstants.tripUserId, isEqualTo: _userId)
          .orderBy(AppConstants.tripCreatedAt, descending: true)
          .get();
          
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID to the data
        data[AppConstants.tripId] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user trips: $e');
      return [];
    }
  }
  
  // Get a single trip by ID
  Future<Map<String, dynamic>?> getTrip(String tripId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .get();
          
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data[AppConstants.tripId] = doc.id;
      
      // Check if trip belongs to current user
      if (_userId != null && data[AppConstants.tripUserId] != _userId) {
        return null; // Not authorized to view this trip
      }
      
      return data;
    } catch (e) {
      print('Error getting trip: $e');
      return null;
    }
  }
  
  // Add a new trip
  Future<String?> addTrip(Map<String, dynamic> trip) async {
    if (_userId == null) return null;
    
    try {
      // Add user ID and timestamp
      trip[AppConstants.tripUserId] = _userId;
      trip[AppConstants.tripCreatedAt] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore
          .collection(AppConstants.tripsCollection)
          .add(trip);
          
      return docRef.id;
    } catch (e) {
      print('Error adding trip: $e');
      return null;
    }
  }
  
  // Update an existing trip
  Future<bool> updateTrip(String tripId, Map<String, dynamic> trip) async {
    if (_userId == null) return false;
    
    try {
      // Check if trip belongs to current user
      final doc = await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .get();
          
      if (!doc.exists || doc.data()?[AppConstants.tripUserId] != _userId) {
        return false; // Not authorized to update this trip
      }
      
      // Preserve user ID and add update timestamp
      trip[AppConstants.tripUserId] = _userId;
      trip['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .update(trip);
          
      return true;
    } catch (e) {
      print('Error updating trip: $e');
      return false;
    }
  }
  
  // Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    if (_userId == null) return false;
    
    try {
      // Check if trip belongs to current user
      final doc = await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .get();
          
      if (!doc.exists || doc.data()?[AppConstants.tripUserId] != _userId) {
        return false; // Not authorized to delete this trip
      }
      
      await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .delete();
          
      return true;
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    }
  }
  
  // Search and filter trips
  Future<List<Map<String, dynamic>>> searchTrips(String query) async {
    if (_userId == null) return [];
    
    try {
      // We can't perform text search directly in Firestore without special indexing
      // So we'll get all user trips and filter them in memory
      final allTrips = await getUserTrips();
      
      if (query.isEmpty) {
        return allTrips;
      }
      
      final lowerQuery = query.toLowerCase();
      
      return allTrips.where((trip) {
        final name = (trip[AppConstants.tripName] ?? '').toString().toLowerCase();
        final destination = (trip[AppConstants.tripDestination] ?? '').toString().toLowerCase();
        final notes = (trip[AppConstants.tripNotes] ?? '').toString().toLowerCase();
        
        return name.contains(lowerQuery) || 
               destination.contains(lowerQuery) || 
               notes.contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching trips: $e');
      return [];
    }
  }
  
  // Filter trips by date range
  Future<List<Map<String, dynamic>>> filterTripsByDate(DateTime startDate, DateTime endDate) async {
    if (_userId == null) return [];
    
    try {
      // Get all user trips first
      final allTrips = await getUserTrips();
      
      return allTrips.where((trip) {
        final tripStartDate = DateTime.tryParse(trip[AppConstants.tripStartDate] ?? '');
        final tripEndDate = DateTime.tryParse(trip[AppConstants.tripEndDate] ?? '');
        
        if (tripStartDate == null || tripEndDate == null) {
          return false;
        }
        
        // Check if trip dates overlap with filter dates
        return !(tripEndDate.isBefore(startDate) || tripStartDate.isAfter(endDate));
      }).toList();
    } catch (e) {
      print('Error filtering trips by date: $e');
      return [];
    }
  }
  
  // Filter trips by country/destination
  Future<List<Map<String, dynamic>>> filterTripsByCountry(String country) async {
    if (_userId == null) return [];
    
    try {
      // Get all user trips first
      final allTrips = await getUserTrips();
      
      if (country.isEmpty) {
        return allTrips;
      }
      
      final lowerCountry = country.toLowerCase();
      
      return allTrips.where((trip) {
        final destination = (trip[AppConstants.tripDestination] ?? '').toString().toLowerCase();
        return destination.contains(lowerCountry);
      }).toList();
    } catch (e) {
      print('Error filtering trips by country: $e');
      return [];
    }
  }
  
  // Synchronize trips from local to Firestore
  Future<bool> syncTrips(List<Map<String, dynamic>> localTrips) async {
    if (_userId == null) return false;
    
    try {
      final batch = _firestore.batch();
      
      for (final trip in localTrips) {
        final id = trip[AppConstants.tripId];
        
        // Skip trips without ID
        if (id == null) continue;
        
        // Add user ID if missing
        if (trip[AppConstants.tripUserId] == null) {
          trip[AppConstants.tripUserId] = _userId;
        }
        
        // Skip trips that don't belong to the current user
        if (trip[AppConstants.tripUserId] != _userId) continue;
        
        // Add sync timestamp
        trip['syncedAt'] = FieldValue.serverTimestamp();
        
        // Create or update trip in Firestore
        final docRef = _firestore.collection(AppConstants.tripsCollection).doc(id);
        batch.set(docRef, trip, SetOptions(merge: true));
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error syncing trips: $e');
      return false;
    }
  }
} 