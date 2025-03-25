import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Buttons Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This is a snackbar message!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToNewScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Buttons Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button 1: Increment Counter
            ElevatedButton(
              onPressed: _incrementCounter,
              child: Text('Increment Counter'),
            ),
            Text(
              'Counter: $_counter',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),

            // Button 2: Show Snackbar
            ElevatedButton(
              onPressed: () => _showSnackbar(context),
              child: Text('Show Snackbar'),
            ),
            SizedBox(height: 20),

            // Button 3: Navigate to New Screen
            ElevatedButton(
              onPressed: () => _navigateToNewScreen(context),
              child: Text('Navigate to New Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// New Screen Example
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Screen')),
      body: Center(
        child: Text(
          'You are on a new screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
