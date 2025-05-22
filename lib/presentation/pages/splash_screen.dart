import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/core/app_constants.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/pages/auth/login_screen.dart';
import 'package:travel_manager/presentation/pages/home_screen.dart';
import 'package:travel_manager/presentation/providers/app_provider.dart';
import 'package:travel_manager/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Give the splash screen at least 2 seconds to display
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Navigate to appropriate screen based on auth status
    switch (authProvider.status) {
      case AuthStatus.authenticated:
        _navigateToHome();
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.guest:
        _navigateToLogin();
        break;
      case AuthStatus.unknown:
        // Wait for auth state to be determined
        authProvider.authStateChanges.listen((user) {
          if (user != null) {
            _navigateToHome();
          } else {
            _navigateToLogin();
          }
        });
        break;
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              AppConstants.logoPath,
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.travel_explore,
                  size: 120,
                  color: Colors.blue,
                );
              },
            ),
            const SizedBox(height: 24),
            
            // App name
            Consumer<AppProvider>(
              builder: (context, appProvider, _) {
                final translations = AppLocalizations.of(context);
                return Text(
                  translations.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 