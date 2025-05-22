import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager/core/app_constants.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Extract trip data
    final name = trip[AppConstants.tripName] as String? ?? 'Unnamed Trip';
    final destination = trip[AppConstants.tripDestination] as String? ?? 'Unknown';
    final startDateStr = trip[AppConstants.tripStartDate] as String?;
    final endDateStr = trip[AppConstants.tripEndDate] as String?;
    final budget = trip[AppConstants.tripBudget];
    final imageUrls = trip[AppConstants.tripImageUrls] as List<dynamic>?;
    
    // Format dates
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = startDateStr != null 
        ? DateTime.tryParse(startDateStr)
        : null;
    final endDate = endDateStr != null 
        ? DateTime.tryParse(endDateStr)
        : null;
    
    final formattedStartDate = startDate != null 
        ? dateFormat.format(startDate)
        : 'Not set';
    final formattedEndDate = endDate != null 
        ? dateFormat.format(endDate)
        : 'Not set';
    
    // Check if trip is past, current, or upcoming
    final now = DateTime.now();
    String status = 'Upcoming';
    Color statusColor = Colors.blue;
    
    if (startDate != null && endDate != null) {
      if (endDate.isBefore(now)) {
        status = 'Past';
        statusColor = Colors.grey;
      } else if (startDate.isBefore(now) && endDate.isAfter(now)) {
        status = 'Current';
        statusColor = Colors.green;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip image or placeholder
            Stack(
              children: [
                if (imageUrls != null && imageUrls.isNotEmpty)
                  Image.network(
                    imageUrls[0] as String,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  )
                else
                  _buildImagePlaceholder(),
                
                // Status badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Trip details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Destination
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(destination),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Date range
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('$formattedStartDate - $formattedEndDate'),
                    ],
                  ),
                  
                  // Budget if available
                  if (budget != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('\$$budget'),
                      ],
                    ),
                  ],
                  
                  // Actions if provided
                  if (onEdit != null || onDelete != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: onEdit,
                              tooltip: 'Edit',
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: onDelete,
                              tooltip: 'Delete',
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.travel_explore,
          size: 64,
          color: Colors.grey[500],
        ),
      ),
    );
  }
} 