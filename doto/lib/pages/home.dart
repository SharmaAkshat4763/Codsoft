import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _todoList = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String>? savedList = _prefs.getStringList('todoList');
      if (savedList != null) {
        _todoList.addAll(savedList.map((item) {
          var splitItem = item.split(':');
          return {
            'task': splitItem[0],
            'completed': splitItem[1] == 'true',
          };
        }).toList());
      }
    });
  }

  Future<void> _saveTodoList() async {
    List<String> stringList = _todoList
        .map((item) => '${item['task']}:${item['completed']}')
        .toList();
    await _prefs.setStringList('todoList', stringList);
  }

  Future<void> _addTodoItem(String task) async {
    setState(() {
      _todoList.add({'task': task, 'completed': false});
    });
    _saveTodoList();
  }

  void _toggleCompletion(int index) {
    setState(() {
      _todoList[index]['completed'] = !_todoList[index]['completed'];
    });
    _saveTodoList();
  }

  Future<void> _deleteTodoItem(int index) async {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTodoList();
  }

  void _showAddTodoDialog() {
    final TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter todo item'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  _addTodoItem(_textFieldController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Application'),
      ),
      body: ListView.builder(
        itemCount: _todoList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _todoList[index]['task'],
              style: TextStyle(
                decoration: _todoList[index]['completed']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            leading: Checkbox(
              value: _todoList[index]['completed'],
              onChanged: (bool? value) {
                _toggleCompletion(index);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteTodoItem(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
