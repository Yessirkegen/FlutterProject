import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      'settings': 'Settings',
      'settingsTheme': 'Theme',
      'settingsLanguage': 'Language',
      'inputCountries': 'Enter countries:',
      'calculateRoute': 'Calculate Optimal Route',
      'toggleInfo': 'Tap to toggle info',
      'longPressMsg': 'Long Press Detected!',
      'extraInfo': 'Extra info about route',
      'addCountry': 'Add Country',
      'routeCountries': 'Countries:',
      'optimalRoute': 'Optimal Route:',
      'themeSystem': 'System',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'aboutDescription':
      'This travel planner app demonstrates a fully functional Flutter project with interactive pages, gestures, and real map integration using OpenStreetMap.',
    },
    'ru': {
      'title': 'Планировщик путешествий',
      'home': 'Главная',
      'about': 'О программе',
      'route': 'Планировщик маршрута',
      'settings': 'Настройки',
      'settingsTheme': 'Тема',
      'settingsLanguage': 'Язык',
      'inputCountries': 'Введите страны:',
      'calculateRoute': 'Рассчитать оптимальный маршрут',
      'toggleInfo': 'Нажми для показа информации',
      'longPressMsg': 'Обнаружено долгое нажатие!',
      'extraInfo': 'Дополнительная информация о маршруте',
      'addCountry': 'Добавить страну',
      'routeCountries': 'Страны:',
      'optimalRoute': 'Оптимальный маршрут:',
      'themeSystem': 'Система',
      'themeLight': 'Светлая',
      'themeDark': 'Тёмная',
      'aboutDescription':
      'Это приложение для планирования путешествий демонстрирует функциональный проект на Flutter с интерактивными страницами, жестами и интеграцией реальной карты через OpenStreetMap.',
    },
    'kk': {
      'title': 'Саяхат жоспарлаушы',
      'home': 'Басты бет',
      'about': 'Бағдарлама туралы',
      'route': 'Маршрут жоспарлаушы',
      'settings': 'Параметрлер',
      'settingsTheme': 'Тақырып',
      'settingsLanguage': 'Тіл',
      'inputCountries': 'Елдерді енгізіңіз:',
      'calculateRoute': 'Оптималды маршрутты есептеу',
      'toggleInfo': 'Ақпаратты көрсету үшін басыңыз',
      'longPressMsg': 'Ұзақ басу анықталды!',
      'extraInfo': 'Маршрут туралы қосымша ақпарат',
      'addCountry': 'Елді қосу',
      'routeCountries': 'Елдер:',
      'optimalRoute': 'Оптималды маршрут:',
      'themeSystem': 'Жүйе',
      'themeLight': 'Жарық',
      'themeDark': 'Қараңғы',
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

/// Основной виджет приложения с поддержкой изменения темы и языка.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  void _updateTheme(ThemeMode mode) => setState(() => _themeMode = mode);
  void _updateLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('kk'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
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
        '/settings': (context) => SettingsPage(
          currentTheme: _themeMode,
          onThemeChanged: _updateTheme,
          currentLocale: _locale,
          onLocaleChanged: _updateLocale,
        ),
      },
    );
  }
}

/// Главный экран.
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('title'))),
      drawer: _buildDrawer(context, loc),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => setState(() => showExtraInfo = !showExtraInfo),
          onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.translate('longPressMsg'))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    loc.translate('toggleInfo'),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              if (showExtraInfo) ...[
                const SizedBox(height: 10),
                Text(loc.translate('extraInfo')),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: loc.translate('inputCountries'),
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
                child: Text(loc.translate('addCountry')),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: addedCountries.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(addedCountries[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, AppLocalizations loc) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text(loc.translate('home')),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            title: Text(loc.translate('route')),
            onTap: () => Navigator.pushReplacementNamed(context, '/route'),
          ),
          ListTile(
            title: Text(loc.translate('about')),
            onTap: () => Navigator.pushReplacementNamed(context, '/about'),
          ),
          ListTile(
            title: Text(loc.translate('settings')),
            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }
}

/// О программе.
class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('about'))),
      drawer: _buildDrawer(context, loc),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            loc.translate('aboutDescription'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, AppLocalizations loc) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text(loc.translate('home')),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            title: Text(loc.translate('route')),
            onTap: () => Navigator.pushReplacementNamed(context, '/route'),
          ),
          ListTile(
            title: Text(loc.translate('about')),
            onTap: () => Navigator.pushReplacementNamed(context, '/about'),
          ),
          ListTile(
            title: Text(loc.translate('settings')),
            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
}

/// Маршрутная страница с картой.
class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final List<String> countries = [];
  final List<String> route = [];
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('route'))),
      drawer: _buildDrawer(context, loc),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: loc.translate('inputCountries'),
                border: const OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() => countries.add(_controller.text));
                      _controller.clear();
                    }
                  },
                  child: Text(loc.translate('addCountry')),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      route.clear();
                      route.addAll(countries.reversed);
                    });
                  },
                  child: Text(loc.translate('calculateRoute')),
                ),
              ],
            ),
            Text('${loc.translate('routeCountries')} ${countries.join(', ')}'),
            Text('${loc.translate('optimalRoute')} ${route.join(' -> ')}'),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(43.238949, 76.889709),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, AppLocalizations loc) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text(loc.translate('home')),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            title: Text(loc.translate('route')),
            onTap: () => Navigator.pushReplacementNamed(context, '/route'),
          ),
          ListTile(
            title: Text(loc.translate('about')),
            onTap: () => Navigator.pushReplacementNamed(context, '/about'),
          ),
          ListTile(
            title: Text(loc.translate('settings')),
            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Страница настроек для переключения темы и языка.
class SettingsPage extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Locale? currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const SettingsPage({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final selLocale = currentLocale ?? Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('settings'))),
      drawer: _buildDrawer(context, loc),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              loc.translate('settingsTheme'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<ThemeMode>(
              title: Text(loc.translate('themeSystem')),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (ThemeMode? mode) {
                if (mode != null) onThemeChanged(mode);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(loc.translate('themeLight')),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (ThemeMode? mode) {
                if (mode != null) onThemeChanged(mode);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(loc.translate('themeDark')),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (ThemeMode? mode) {
                if (mode != null) onThemeChanged(mode);
              },
            ),
            const SizedBox(height: 20),
            Text(
              loc.translate('settingsLanguage'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<Locale>(
              value: selLocale,
              onChanged: (Locale? L) {
                if (L != null) onLocaleChanged(L);
              },
              items: const [Locale('en'), Locale('ru'), Locale('kk')]
                  .map((L) {
                final label = L.languageCode == 'en'
                    ? 'English'
                    : L.languageCode == 'ru'
                    ? 'Русский'
                    : 'Қазақша';
                return DropdownMenuItem(value: L, child: Text(label));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, AppLocalizations loc) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text(loc.translate('home')),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            title: Text(loc.translate('route')),
            onTap: () => Navigator.pushReplacementNamed(context, '/route'),
          ),
          ListTile(
            title: Text(loc.translate('about')),
            onTap: () => Navigator.pushReplacementNamed(context, '/about'),
          ),
          ListTile(
            title: Text(loc.translate('settings')),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}