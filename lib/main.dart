import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

/// Локализация приложения с поддержкой языков: английский, русский, казахский.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Метод для быстрого доступа к экземпляру локализаций через BuildContext.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Карта переводов для используемых ключей.
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Travel Planner',
      'home': 'Home',
      'about': 'About',
      'route': 'Route Planner',
      'inputCountries': 'Enter countries:',
      'calculateRoute': 'Calculate Optimal Route',
      'toggleInfo': 'Tap to toggle info',
      'longPressMsg': 'Long Press Detected!',
      'extraInfo': 'Extra info about route',
      'addCountry': 'Add Country',
      'routeCountries': 'Countries:',
      'optimalRoute': 'Optimal Route:',
      'aboutDescription':
      'This travel planner app demonstrates a fully functional Flutter project with interactive pages, gestures, and real map integration using OpenStreetMap.',
    },
    'ru': {
      'title': 'Планировщик путешествий',
      'home': 'Главная',
      'about': 'О программе',
      'route': 'Планировщик маршрута',
      'inputCountries': 'Введите страны:',
      'calculateRoute': 'Рассчитать оптимальный маршрут',
      'toggleInfo': 'Нажми для показа информации',
      'longPressMsg': 'Обнаружено долгое нажатие!',
      'extraInfo': 'Дополнительная информация о маршруте',
      'addCountry': 'Добавить страну',
      'routeCountries': 'Страны:',
      'optimalRoute': 'Оптимальный маршрут:',
      'aboutDescription':
      'Это приложение для планирования путешествий демонстрирует функциональный проект на Flutter с интерактивными страницами, жестами и интеграцией реальной карты через OpenStreetMap.',
    },
    'kk': {
      'title': 'Саяхат жоспарлаушы',
      'home': 'Басты бет',
      'about': 'Бағдарлама туралы',
      'route': 'Маршрут жоспарлаушы',
      'inputCountries': 'Елдерді енгізіңіз:',
      'calculateRoute': 'Оптималды маршрутты есептеу',
      'toggleInfo': 'Ақпаратты көрсету үшін басыңыз',
      'longPressMsg': 'Ұзақ басу анықталды!',
      'extraInfo': 'Маршрут туралы қосымша ақпарат',
      'addCountry': 'Елді қосу',
      'routeCountries': 'Елдер:',
      'optimalRoute': 'Оптималды маршрут:',
      'aboutDescription':
      'Бұл Flutter жобасының тапсырмасы аясында жасалған саяхат жоспарлаушы қосымша. Онда интерактивті беттер, жесттер және OpenStreetMap арқылы нақты карта интеграциясы бар.',
    },
  };

  // Метод для получения перевода по ключу.
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['kk']![key] ??
        key;
  }
}

/// Делегат для загрузки локализаций.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'kk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Основной виджет приложения.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('kk'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('kk');
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('kk');
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/about': (context) => const AboutPage(),
        '/route': (context) => const RoutePage(),
      },
    );
  }
}

/// Главный экран приложения с динамическим UI и обработкой жестов.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showExtraInfo = false;
  final TextEditingController _countryController = TextEditingController();
  List<String> addedCountries = [];

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate('title')),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(
                  title: Text(localization.translate('home')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                ListTile(
                  title: Text(localization.translate('route')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/route');
                  },
                ),
                ListTile(
                  title: Text(localization.translate('about')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: orientation == Orientation.portrait
                ? _buildVerticalLayout(localization)
                : _buildHorizontalLayout(localization),
          ),
        );
      },
    );
  }

  // Вертикальная раскладка (портрет)
  Widget _buildVerticalLayout(AppLocalizations localization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Жесты: tap для переключения информации и long press для показа Snackbar
        GestureDetector(
          onTap: () {
            setState(() {
              showExtraInfo = !showExtraInfo;
            });
          },
          onLongPress: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localization.translate('longPressMsg')),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                localization.translate('toggleInfo'),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (showExtraInfo)
          Text(
            localization.translate('extraInfo'),
            style: const TextStyle(fontSize: 16),
          ),
        const SizedBox(height: 20),
        TextField(
          controller: _countryController,
          decoration: InputDecoration(
            labelText: localization.translate('inputCountries'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (_countryController.text.isNotEmpty) {
              setState(() {
                addedCountries.add(_countryController.text);
                _countryController.clear();
              });
            }
          },
          child: Text(localization.translate('addCountry')),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: addedCountries.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(addedCountries[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // Горизонтальная раскладка (ландшафт)
  Widget _buildHorizontalLayout(AppLocalizations localization) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showExtraInfo = !showExtraInfo;
                  });
                },
                onLongPress: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localization.translate('longPressMsg')),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      localization.translate('toggleInfo'),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (showExtraInfo)
                Text(
                  localization.translate('extraInfo'),
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              TextField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: localization.translate('inputCountries'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_countryController.text.isNotEmpty) {
                    setState(() {
                      addedCountries.add(_countryController.text);
                      _countryController.clear();
                    });
                  }
                },
                child: Text(localization.translate('addCountry')),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: addedCountries.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(addedCountries[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }
}

/// Страница "О программе"
class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate('about')),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(
                  title: Text(localization.translate('home')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                ListTile(
                  title: Text(localization.translate('route')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/route');
                  },
                ),
                ListTile(
                  title: Text(localization.translate('about')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                localization.translate('aboutDescription'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Страница с функционалом планирования маршрута с реальной картой через OpenStreetMap.
class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  List<String> countries = [];
  List<String> route = [];
  final TextEditingController _routeCountryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate('route')),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(
                  title: Text(localization.translate('home')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                ListTile(
                  title: Text(localization.translate('route')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/route');
                  },
                ),
                ListTile(
                  title: Text(localization.translate('about')),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: orientation == Orientation.portrait
                ? _buildVerticalLayout(localization)
                : _buildHorizontalLayout(localization),
          ),
        );
      },
    );
  }

  // Вертикальная раскладка для страницы маршрута
  Widget _buildVerticalLayout(AppLocalizations localization) {
    return Column(
      children: [
        TextField(
          controller: _routeCountryController,
          decoration: InputDecoration(
            labelText: localization.translate('inputCountries'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (_routeCountryController.text.isNotEmpty) {
              setState(() {
                countries.add(_routeCountryController.text);
                _routeCountryController.clear();
              });
            }
          },
          child: Text(localization.translate('addCountry')),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Симуляция расчёта маршрута: переворот списка введённых стран.
            setState(() {
              route = List.from(countries.reversed);
            });
          },
          child: Text(localization.translate('calculateRoute')),
        ),
        const SizedBox(height: 10),
        Text(
          '${localization.translate('routeCountries')} ${countries.join(', ')}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          '${localization.translate('optimalRoute')} ${route.join(' -> ')}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildMapWidget(),
        ),
      ],
    );
  }

  // Горизонтальная раскладка для страницы маршрута
  Widget _buildHorizontalLayout(AppLocalizations localization) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: _routeCountryController,
                decoration: InputDecoration(
                  labelText: localization.translate('inputCountries'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_routeCountryController.text.isNotEmpty) {
                    setState(() {
                      countries.add(_routeCountryController.text);
                      _routeCountryController.clear();
                    });
                  }
                },
                child: Text(localization.translate('addCountry')),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    route = List.from(countries.reversed);
                  });
                },
                child: Text(localization.translate('calculateRoute')),
              ),
              const SizedBox(height: 10),
              Text(
                '${localization.translate('routeCountries')} ${countries.join(', ')}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '${localization.translate('optimalRoute')} ${route.join(' -> ')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildMapWidget(),
        ),
      ],
    );
  }

  // Виджет с картой, интегрированной через flutter_map и OpenStreetMap.
  Widget _buildMapWidget() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(43.238949, 76.889709), // Changed from 'center' to 'initialCenter'
        initialZoom: 12.0, // Changed from 'zoom' to 'initialZoom'
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.travelplanner',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _routeCountryController.dispose();
    super.dispose();
  }
}
