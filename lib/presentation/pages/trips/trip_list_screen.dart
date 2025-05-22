import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/pages/trips/trip_form_screen.dart';
import 'package:travel_manager/presentation/providers/auth_provider.dart' as app_auth;
import 'package:travel_manager/presentation/providers/trip_provider.dart';
import 'package:travel_manager/presentation/widgets/trips/trip_card.dart';
import 'package:travel_manager/presentation/widgets/trips/trip_filter.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load trips when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).loadTrips();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _searchTrips(String query) {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.searchTrips(query);
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context);
    final tripProvider = Provider.of<TripProvider>(context);
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: translations.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchTrips('');
                        },
                      )
                    : null,
                ),
                onChanged: _searchTrips,
              ),
              
              const SizedBox(height: 16),
              
              // Filter options
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Date filter
                    TripFilter(
                      icon: Icons.calendar_today,
                      label: translations.filterByDate,
                      onTap: () async {
                        // Show date range picker
                        final dateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        
                        if (dateRange != null && mounted) {
                          tripProvider.filterByDate(
                            dateRange.start,
                            dateRange.end,
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Country filter
                    TripFilter(
                      icon: Icons.public,
                      label: translations.filterByCountry,
                      onTap: () {
                        // TODO: Show country selection dialog
                      },
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Reset filters
                    TripFilter(
                      icon: Icons.filter_list_off,
                      label: 'Reset Filters',
                      onTap: () {
                        _searchController.clear();
                        tripProvider.resetFilters();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Trip list
        Expanded(
          child: tripProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : tripProvider.trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.travel_explore,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        translations.noTripsFound,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!authProvider.isGuest)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TripFormScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: Text(translations.addTrip),
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: tripProvider.trips.length,
                  itemBuilder: (context, index) {
                    final trip = tripProvider.trips[index];
                    return TripCard(
                      trip: trip,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripFormScreen(tripData: trip),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
} 