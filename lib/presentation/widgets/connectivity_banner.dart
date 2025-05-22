import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/providers/trip_provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context);
    final tripProvider = Provider.of<TripProvider>(context);
    final connectivityStatus = Provider.of<ConnectivityResult>(context);
    final isOnline = connectivityStatus != ConnectivityResult.none;
    
    // If online, don't show the banner
    if (isOnline) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                translations.offline,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          TextButton(
            onPressed: () => tripProvider.syncTrips(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Row(
              children: [
                Text(translations.sync),
                const SizedBox(width: 4),
                const Icon(Icons.sync, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 