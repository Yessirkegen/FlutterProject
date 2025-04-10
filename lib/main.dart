import 'package:flutter/material.dart';

void main() {
  runApp(VisitCountriesApp());
}

/// Основное приложение
class VisitCountriesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Страны для посещения',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

/// Главный экран приложения
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Контроллер для управления текстовым полем ввода
  final TextEditingController _controller = TextEditingController();
  // Список для хранения введённых пользователем стран
  final List<String> _countries = [];

  /// Метод для добавления новой страны в список
  void _addCountry() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _countries.add(text);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Определяем ориентацию экрана через MediaQuery
    var orientation = MediaQuery.of(context).orientation;
    final bool isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Страны для посещения'),
      ),
      // OrientationBuilder позволяет менять макет при изменении ориентации экрана
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout(),
          );
        },
      ),
    );
  }

  /// Построение макета для портретного режима
  Widget _buildPortraitLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ряд с текстовым полем и кнопкой добавления
        Row(
          children: [
            // Expanded для текстового поля, чтобы оно занимало всё доступное место
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Введите страну',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addCountry(),
              ),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: _addCountry,
              child: const Text('Добавить'),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        // Расширяемый виджет со списком стран
        Expanded(
          child: _countries.isNotEmpty
              ? ListView.builder(
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _countries[index],
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              );
            },
          )
              : const Center(
            child: Text(
              'Список стран пуст',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }

  /// Построение макета для ландшафтного режима
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Левая часть: блок ввода страны
        Expanded(
          flex: 2,
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Введите страну',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addCountry(),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _addCountry,
                child: const Text('Добавить'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        // Правая часть: список добавленных стран
        Expanded(
          flex: 3,
          child: _countries.isNotEmpty
              ? ListView.builder(
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _countries[index],
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              );
            },
          )
              : const Center(
            child: Text(
              'Список стран пуст',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }
}
