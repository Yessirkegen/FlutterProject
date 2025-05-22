import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/pages/about_screen.dart';
import 'package:travel_manager/presentation/pages/profile_screen.dart';
import 'package:travel_manager/presentation/pages/settings_screen.dart';
import 'package:travel_manager/presentation/pages/trips/trip_history_screen.dart';
import 'package:travel_manager/presentation/pages/trips/trip_list_screen.dart';
import 'package:travel_manager/presentation/pages/trips/trip_form_screen.dart';
import 'package:travel_manager/presentation/providers/auth_provider.dart' as app_auth;
import 'package:travel_manager/presentation/widgets/connectivity_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const TripListScreen(),
    const TripHistoryScreen(),
    const ProfileScreen(),
    const AboutScreen(),
    const SettingsScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context);
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _getAppBarTitle(context, _currentIndex),
        actions: [
          if (authProvider.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                label: Text(
                  translations.guestMode,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Colors.orange,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity banner to show online/offline status
          const ConnectivityBanner(),
          
          // Main content
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: translations.homeTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: translations.historyTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: translations.profile,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: translations.aboutTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: translations.settingsTitle,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TripFormScreen()),
              );
            },
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
  
  Widget _getAppBarTitle(BuildContext context, int index) {
    final translations = AppLocalizations.of(context);
    
    switch (index) {
      case 0:
        return Text(translations.homeTitle);
      case 1:
        return Text(translations.historyTitle);
      case 2:
        return Text(translations.profile);
      case 3:
        return Text(translations.aboutTitle);
      case 4:
        return Text(translations.settingsTitle);
      default:
        return Text(translations.appTitle);
    }
  }
} 