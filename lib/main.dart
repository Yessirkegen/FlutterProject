import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_manager/core/app_constants.dart';
import 'package:travel_manager/data/repositories/auth_repository.dart';
import 'package:travel_manager/data/repositories/trip_repository.dart';
import 'package:travel_manager/presentation/pages/splash_screen.dart';
import 'package:travel_manager/services/connectivity_service.dart';
import 'package:travel_manager/services/local_storage_service.dart';
import 'package:travel_manager/presentation/themes/app_theme.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/providers/app_provider.dart';
import 'package:travel_manager/presentation/providers/auth_provider.dart';
import 'package:travel_manager/presentation/providers/trip_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.tripsBox);
  
  // Initialize services
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  
  runApp(MyApp(localStorageService: localStorageService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService localStorageService;
  
  const MyApp({super.key, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // App Provider for theme and localization
        ChangeNotifierProvider(
          create: (_) => AppProvider(localStorageService),
        ),
        
        // Authentication Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository()),
        ),
        
        // Trip Provider
        ChangeNotifierProvider(
          create: (_) => TripProvider(TripRepository()),
        ),
        
        // Connectivity Provider
        StreamProvider<ConnectivityResult>(
          create: (_) => ConnectivityService().connectivityStream,
          initialData: ConnectivityResult.none,
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'Travel Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            locale: appProvider.locale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ru', ''), // Russian
              Locale('kk', ''), // Kazakh
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              // Fallback to Kazakh if not supported
              return const Locale('kk', '');
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
