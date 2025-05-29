import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = Locale('en');
  User? _user;
  bool _loading = true;

  final Map<String, Map<String, String>> _texts = {
    'en': {
      'home': 'Home',
      'about': 'About',
      'settings': 'Settings',
      'profile': 'Profile',
      'login': 'Login / Register',
      'homeContent': 'Welcome to Travel Manager!',
      'aboutContent': 'This app helps you plan your travels.',
      'theme': 'Dark Theme',
      'language': 'Language',
      'email': 'Email',
      'password': 'Password',
      'register': 'Register',
      'loginBtn': 'Login',
      'logout': 'Logout',
      'errorLogin': 'Please log in to access this feature',
    },
    'ru': {
      'home': 'Главная',
      'about': 'О приложении',
      'settings': 'Настройки',
      'profile': 'Профиль',
      'login': 'Вход / Регистрация',
      'homeContent': 'Добро пожаловать в Travel Manager!',
      'aboutContent': 'Это приложение поможет вам планировать поездки.',
      'theme': 'Тёмная тема',
      'language': 'Язык',
      'email': 'Почта',
      'password': 'Пароль',
      'register': 'Регистрация',
      'loginBtn': 'Войти',
      'logout': 'Выйти',
      'errorLogin': 'Пожалуйста, войдите, чтобы получить доступ к этой функции',
    },
    'kk': {
      'home': 'Бас бет',
      'about': 'Қосымша туралы',
      'settings': 'Баптаулар',
      'profile': 'Профиль',
      'login': 'Кіру / Тіркеу',
      'homeContent': 'Travel Manager-ге қош келдіңіз!',
      'aboutContent': 'Бұл қосымша сіздің саяхатыңызды жоспарлауға көмектеседі.',
      'theme': 'Қараңғы тема',
      'language': 'Тіл',
      'email': 'Электрондық пошта',
      'password': 'Құпия сөз',
      'register': 'Тіркелу',
      'loginBtn': 'Кіру',
      'logout': 'Шығу',
      'errorLogin': 'Осы функцияға қол жеткізу үшін жүйеге кіріңіз',
    },
  };

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadPrefs(user.uid);
      }
      setState(() {
        _user = user;
        _loading = false;
      });
    });
  }

  Future<void> _loadPrefs(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _themeMode = data['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
          _locale = Locale(data['language']);
        });
      }
    } catch (_) {}
  }

  void _updateTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    if (_user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid)
            .set({'theme': isDark ? 'dark' : 'light'}, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  void _updateLocale(String code) async {
    setState(() {
      _locale = Locale(code);
    });
    if (_user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid)
            .set({'language': code}, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Manager',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: [Locale('en'), Locale('ru'), Locale('kk')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (ctx) => _loading
            ? Scaffold(body: Center(child: CircularProgressIndicator()))
            : (_user == null
            ? AuthScreen(
          texts: _texts[_locale.languageCode]!,
          onAuthSuccess: (user) {},
        )
            : HomeScreen(
            texts: _texts[_locale.languageCode]!,
            user: _user!)),
        '/about': (ctx) => AboutScreen(
          texts: _texts[_locale.languageCode]!,
          user: _user,
        ),
        '/settings': (ctx) => _loading
            ? Scaffold(body: Center(child: CircularProgressIndicator()))
            : (_user == null
            ? Scaffold(
          appBar: AppBar(title: Text(_texts[_locale.languageCode]!['settings']!)),
          body: Center(child: Text(_texts[_locale.languageCode]!['errorLogin']!)),
        )
            : SettingsScreen(
          texts: _texts[_locale.languageCode]!,
          isDark: _themeMode == ThemeMode.dark,
          onThemeChanged: _updateTheme,
          currentLang: _locale.languageCode,
          onLangChanged: _updateLocale,
          user: _user,
        )),
        '/profile': (ctx) => _loading
            ? Scaffold(body: Center(child: CircularProgressIndicator()))
            : (_user == null
            ? Scaffold(
          appBar: AppBar(title: Text(_texts[_locale.languageCode]!['profile']!)),
          body: Center(child: Text(_texts[_locale.languageCode]!['errorLogin']!)),
        )
            : ProfileScreen(
          texts: _texts[_locale.languageCode]!,
          user: _user!,
          themeMode: _themeMode,
          locale: _locale,
          onThemeChanged: _updateTheme,
          onLocaleChanged: _updateLocale,
        )),
        '/auth': (ctx) => AuthScreen(
          texts: _texts[_locale.languageCode]!,
          onAuthSuccess: (user) {},
        ),
      },
    );
  }
}

// ... (AuthScreen, HomeScreen, AboutScreen, SettingsScreen, ProfileScreen, AppDrawer remain unchanged)

class AuthScreen extends StatefulWidget {
  final Map<String, String> texts;
  final void Function(User user) onAuthSuccess;
  AuthScreen({required this.texts, required this.onAuthSuccess});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      widget.onAuthSuccess(cred.user!);
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'theme': 'light',
        'language': 'en',
      });
      widget.onAuthSuccess(cred.user!);
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.texts['login']!)),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [Tab(text: widget.texts['loginBtn']), Tab(text: widget.texts['register'])],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLogin(),
                _buildRegister(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextField(controller: _emailController, decoration: InputDecoration(labelText: widget.texts['email'])),
        TextField(controller: _passwordController, decoration: InputDecoration(labelText: widget.texts['password']), obscureText: true),
        SizedBox(height: 20),
        _loading
            ? CircularProgressIndicator()
            : ElevatedButton(onPressed: _login, child: Text(widget.texts['loginBtn']!)),
      ],
    ),
  );

  Widget _buildRegister() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextField(controller: _emailController, decoration: InputDecoration(labelText: widget.texts['email'])),
        TextField(controller: _passwordController, decoration: InputDecoration(labelText: widget.texts['password']), obscureText: true),
        TextField(controller: _confirmController, decoration: InputDecoration(labelText: 'Confirm ${widget.texts['password']}'), obscureText: true),
        SizedBox(height: 20),
        _loading
            ? CircularProgressIndicator()
            : ElevatedButton(onPressed: _register, child: Text(widget.texts['register']!)),
      ],
    ),
  );
}

class HomeScreen extends StatelessWidget {
  final Map<String, String> texts;
  final User user;
  HomeScreen({required this.texts, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(texts['home']!)),
      drawer: AppDrawer(texts: texts, user: user),
      body: Center(child: Text(texts['homeContent']!)),
    );
  }
}

class AboutScreen extends StatelessWidget {
  final Map<String, String> texts;
  final User? user;
  AboutScreen({required this.texts, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(texts['about']!)),
      drawer: AppDrawer(texts: texts, user: user),
      body: Center(child: Text(texts['aboutContent']!)),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final Map<String, String> texts;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final String currentLang;
  final ValueChanged<String> onLangChanged;
  final User? user;

  SettingsScreen({
    required this.texts,
    required this.isDark,
    required this.onThemeChanged,
    required this.currentLang,
    required this.onLangChanged,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(texts['settings']!)),
      drawer: AppDrawer(texts: texts, user: user),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(texts['theme']!),
              value: isDark,
              onChanged: onThemeChanged,
            ),
            SizedBox(height: 20),
            Text(texts['language']!, style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: currentLang,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
              ],
              onChanged: (val) {
                if (val != null) onLangChanged(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final Map<String, String> texts;
  final User user;
  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<String> onLocaleChanged;

  ProfileScreen({
    required this.texts,
    required this.user,
    required this.themeMode,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(texts['profile']!)),
      drawer: AppDrawer(texts: texts, user: user),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${texts['email']}: ${user.email}'),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text(texts['theme']!),
              value: themeMode == ThemeMode.dark,
              onChanged: onThemeChanged,
            ),
            SizedBox(height: 10),
            Text(texts['language']!),
            DropdownButton<String>(
              value: locale.languageCode,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
              ],
              onChanged: (val) {
                if (val != null) onLocaleChanged(val);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/auth');
              },
              child: Text(texts['logout']!),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final Map<String, String> texts;
  final User? user;
  AppDrawer({required this.texts, this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text('Travel Manager', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(texts['home']!),
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(texts['about']!),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          if (user != null) ...[
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(texts['settings']!),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(texts['profile']!),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ] else ...[
            ListTile(
              leading: Icon(Icons.login),
              title: Text(texts['login']!),
              onTap: () => Navigator.pushNamed(context, '/auth'),
            ),
          ],
        ],
      ),
    );
  }
}