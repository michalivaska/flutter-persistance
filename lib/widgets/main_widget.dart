import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  static const preferencesKey = 'tasks';

  SharedPreferences? preferences;
  List<String> tasks = [];
  String newTask = '';
  bool adding = false;

  void _init() async {
    preferences = await SharedPreferences.getInstance();
    tasks = preferences?.getStringList(preferencesKey) ?? [];
  }

  void addTask(String label) {
    if (label.isEmpty) return;
    setState(() {
      tasks.add(label);
      adding = false;
    });
    syncTasks();
  }

  Future<void> removeTaskAt(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    return syncTasks();
  }

  Future<void> syncTasks() async {
    await preferences?.setStringList(preferencesKey, tasks);
  }

  Widget _wTaskTile(int index) {
    final task = tasks[index];
    return Container(
      color: Colors.deepOrange.shade200,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        title: Text(
          task,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            removeTaskAt(index);
          },
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des tâches'),
        actions: [
          if (!adding)
            IconButton(
              onPressed: () {
                setState(() {
                  adding = true;
                });
              },
              icon: const Icon(Icons.add_circle),
            ),
        ],
      ),
      body: Column(
        children: [
          if (adding)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            newTask = value;
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        addTask(newTask);
                      },
                      icon: const Icon(Icons.save),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          newTask = '';
                          adding = false;
                        });
                      },
                      icon: const Icon(Icons.cancel),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < tasks.length; i++) _wTaskTile(i),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
