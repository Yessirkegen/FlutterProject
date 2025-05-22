import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/providers/app_provider.dart';
import 'package:travel_manager/presentation/providers/auth_provider.dart' as app_auth;
import 'package:travel_manager/presentation/providers/trip_provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final tripProvider = Provider.of<TripProvider>(context);
    final l10n = AppLocalizations.of(context);

    // Get current theme mode
    String themeName = '';
    switch (appProvider.themeMode) {
      case ThemeMode.light:
        themeName = l10n.lightTheme;
        break;
      case ThemeMode.dark:
        themeName = l10n.darkTheme;
        break;
      case ThemeMode.system:
        themeName = l10n.systemTheme;
        break;
    }

    // Get trip count
    final tripsCount = tripProvider.trips.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: authProvider.user == null
          ? Center(
              child: Text(l10n.notLoggedIn),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with avatar
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            authProvider.user?.email ?? '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Settings section
                    Text(
                      l10n.settings,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(),
                    
                    // Language setting
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.language),
                      subtitle: Text(appProvider.locale.languageCode == 'en' ? 'English' : 'Русский'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    
                    // Theme setting
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: Text(l10n.theme),
                      subtitle: Text(themeName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats section
                    Text(
                      l10n.statistics,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(),
                    
                    // Trip count
                    ListTile(
                      leading: const Icon(Icons.luggage),
                      title: Text(l10n.totalTrips),
                      subtitle: Text('$tripsCount'),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Logout button
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.logout),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                          minimumSize: const Size(200, 50),
                        ),
                        onPressed: () {
                          authProvider.logout().then((_) {
                            Navigator.of(context).pushReplacementNamed('/login');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 