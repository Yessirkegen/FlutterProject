import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/providers/trip_provider.dart';
import 'package:travel_manager/presentation/widgets/trips/trip_card.dart';
import 'package:travel_manager/core/app_constants.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load trips when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).loadTrips();
    });
  }
  
  bool _isPastTrip(Map<String, dynamic> trip) {
    final endDateStr = trip[AppConstants.tripEndDate];
    if (endDateStr == null) return false;
    
    final endDate = DateTime.tryParse(endDateStr.toString());
    if (endDate == null) return false;
    
    return endDate.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context);
    final tripProvider = Provider.of<TripProvider>(context);
    
    // Filter to get only past trips
    final pastTrips = tripProvider.trips.where(_isPastTrip).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            translations.historyTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your past adventures',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Trip list
          Expanded(
            child: tripProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : pastTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No past trips found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: pastTrips.length,
                    itemBuilder: (context, index) {
                      final trip = pastTrips[index];
                      return TripCard(
                        trip: trip,
                        onTap: () {
                          // TODO: Navigate to trip details screen
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 