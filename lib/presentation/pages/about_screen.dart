import 'package:flutter/material.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo
          Center(
            child: Icon(
              Icons.travel_explore,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // App name
          Center(
            child: Text(
              translations.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Version
          Center(
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // About content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the App',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Travel Manager is a comprehensive travel planning application '
                    'that helps you organize your trips, track expenses, and keep '
                    'all your travel memories in one place.'
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Key Features:'
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(context, 'Plan and organize trips'),
                  _buildFeatureItem(context, 'Track travel expenses and budget'),
                  _buildFeatureItem(context, 'Save important travel documents'),
                  _buildFeatureItem(context, 'Works offline'),
                  _buildFeatureItem(context, 'Multilingual support (English, Russian, Kazakh)'),
                  _buildFeatureItem(context, 'Customizable theme'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Developer info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Travel Manager Team'),
                    subtitle: Text('© 2023 All Rights Reserved'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.email),
                    title: Text('support@travelmanager.app'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.web),
                    title: Text('www.travelmanager.app'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
} 