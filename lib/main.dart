import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:flutter/src/widgets/basic.dart';
import 'package:sqlite3/sqlite3.dart' hide Row;
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Удалить баннер отладки
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Журнал
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // Эта функция используется для извлечения всех данных из базы данных
  void _refreshJournals() async {
    final data = await getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Загрузка журнала при запуске приложения
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();

  // Загрузка дневника при запуске приложения
  // Эта функция будет активирована при нажатии плавающей кнопки
  // Она также будет активирована, когда обновляется элемент
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> создать новый элемент
      // id != null -> обновить существующий элемент
      final existingJournal =
      _journals.firstWhere((element) => element['ID'] == id);
      _nameController.text = existingJournal['name'];
      _profitController.text = existingJournal['profit'];
    }

    //окно для добавления/редактирования
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // это предотвратит закрытие текстовых полей программной клавиатурой
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'name'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _profitController,
                decoration: const InputDecoration(hintText: 'profit'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Сохранить новый журнал
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }

                  // Очистить текстовые поля
                  _profitController.text = '';
                  _profitController.text = '';

                  // Закрывается нижний лист
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

// Вставить новый журнал в базу данных
  Future<void> _addItem() async {
    createItem(_nameController.text, _profitController.text);
    _refreshJournals();
  }

  // Обновить существующий журнал
  Future<void> _updateItem(int id) async {
    updateItem(id, _nameController.text, _profitController.text);
    _refreshJournals();
  }

  // Удалить объект
  void _deleteItem(int id) async {
    deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Урок SQL'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
              title: Text(_journals[index]['name']),
              subtitle: Text(_journals[index]['profit']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(_journals[index]['name']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteItem(_journals[index]['ID']),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}