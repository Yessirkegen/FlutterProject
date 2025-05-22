import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/pages/auth/login_screen.dart';
import 'package:travel_manager/presentation/providers/app_provider.dart';
import 'package:travel_manager/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations.darkTheme,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: Text(translations.lightTheme),
                    value: ThemeMode.light,
                    groupValue: appProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(translations.darkTheme),
                    value: ThemeMode.dark,
                    groupValue: appProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(translations.systemTheme),
                    value: ThemeMode.system,
                    groupValue: appProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appProvider.setThemeMode(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Language settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations.language,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: Text(translations.english),
                    value: 'en',
                    groupValue: appProvider.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        appProvider.setLanguage(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(translations.russian),
                    value: 'ru',
                    groupValue: appProvider.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        appProvider.setLanguage(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(translations.kazakh),
                    value: 'kk',
                    groupValue: appProvider.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        appProvider.setLanguage(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logout button (only for authenticated users)
          if (authProvider.isLoggedIn)
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(translations.logout),
                onTap: () => _showLogoutConfirmation(context),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showLogoutConfirmation(BuildContext context) {
    final translations = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translations.logout),
        content: Text(translations.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(translations.no),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: Text(translations.yes),
          ),
        ],
      ),
    );
  }
} 