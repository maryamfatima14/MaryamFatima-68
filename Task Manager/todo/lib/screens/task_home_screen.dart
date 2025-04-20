import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import 'package:todo/db/task_database.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models//notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({super.key});

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  int _selectedIndex = 0;
  final List<String> tabs = ['All', 'Repeated', 'Completed', 'Upcoming'];
  List<Task> tasks = [];
  bool _notificationsEnabled = false;
  final NotificationService _notificationService = NotificationService();

  List<Task> get _filteredTasks {
    switch (tabs[_selectedIndex]) {
      case 'Repeated':
        return tasks.where((task) => task.repeat != 'None').toList();
      case 'Completed':
        return tasks.where((task) => task.isCompleted).toList();
      case 'Upcoming':
        return tasks.where((task) => task.date.isAfter(DateTime.now())).toList();
      default:
        return tasks;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    });
  }

  Future<void> _addTask(Task newTask) async {
    final insertedId = await TaskDatabase.instance.insertTask(newTask);
    final reminderTime = DateTime(
      newTask.date.year,
      newTask.date.month,
      newTask.date.day,
      newTask.startTime.hour,
      newTask.startTime.minute,
    ).subtract(Duration(minutes: newTask.reminder));

    if (_notificationsEnabled) {
      await _notificationService.scheduleTaskNotification(
        id: insertedId,
        title: newTask.title,
        body: newTask.note.isNotEmpty ? newTask.note : 'Task reminder',
        scheduledDate: reminderTime,
        notificationsEnabled: _notificationsEnabled,
        payload: insertedId.toString(),
      );
    }
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasksFromDb = await TaskDatabase.instance.getAllTasks();
    if (mounted) {
      setState(() => tasks = tasksFromDb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(tabs[_selectedIndex], style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _filteredTasks.isEmpty
                  ? Center(
                child: Text(
                  'No tasks found',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = _filteredTasks[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Color(0xFFF8BBD0),
                    child: ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(task.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        task.note,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) async {
                              if (value == null) return;
                              final updatedTask = task.copyWith(isCompleted: value);
                              await TaskDatabase.instance.updateTask(updatedTask);
                              await _loadTasks();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task status updated'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            activeColor: Colors.blue.shade700,
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.black),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final updatedTaskData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskPage(task: task),
                                  ),
                                );
                                if (updatedTaskData != null && mounted) {
                                  final updatedTask = Task(
                                    id: updatedTaskData['id'] as int,
                                    title: updatedTaskData['title'] as String,
                                    note: updatedTaskData['note'] as String,
                                    location: updatedTaskData['location'] as String,
                                    date: DateTime.parse(updatedTaskData['date'] as String),
                                    startTime: updatedTaskData['startTime'] as TimeOfDay,
                                    endTime: updatedTaskData['endTime'] as TimeOfDay,
                                    reminder: updatedTaskData['reminder'] as int,
                                    repeat: updatedTaskData['repeat'] as String,
                                    color: updatedTaskData['color'] as int,
                                    isCompleted: task.isCompleted,
                                  );
                                  await TaskDatabase.instance.updateTask(updatedTask);
                                  // Cancel existing notification
                                  await _notificationService.cancelNotification(task.id ?? 0);
                                  // Schedule new notification if enabled
                                  if (_notificationsEnabled) {
                                    final reminderTime = DateTime(
                                      updatedTask.date.year,
                                      updatedTask.date.month,
                                      updatedTask.date.day,
                                      updatedTask.startTime.hour,
                                      updatedTask.startTime.minute,
                                    ).subtract(Duration(minutes: updatedTask.reminder));
                                    await _notificationService.scheduleTaskNotification(
                                      id: updatedTask.id ?? 0,
                                      title: updatedTask.title,
                                      body: updatedTask.note.isNotEmpty
                                          ? updatedTask.note
                                          : 'Task reminder',
                                      scheduledDate: reminderTime,
                                      notificationsEnabled: _notificationsEnabled,
                                      payload: updatedTask.id.toString(),
                                    );
                                  }
                                  await _loadTasks();
                                }
                              } else if (value == 'delete') {
                                final confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: const Text('Are you sure?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.pinkAccent)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmDelete == true && mounted) {
                                  await _notificationService.cancelNotification(task.id ?? 0);
                                  await TaskDatabase.instance.deleteTask(task.id ?? 0);
                                  await _loadTasks();
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit', style: TextStyle(color: Colors.black)),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay),
            label: 'Repeated',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Upcoming',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTaskData = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
          if (newTaskData != null && mounted) {
            if (newTaskData.containsKey('id')) {
              final originalTask = tasks.firstWhere(
                    (task) => task.id == newTaskData['id'],
                orElse: () => Task(
                  id: newTaskData['id'] as int,
                  title: '',
                  note: '',
                  location: '',
                  date: DateTime.now(),
                  startTime: TimeOfDay.now(),
                  endTime: TimeOfDay.now(),
                  reminder: 0,
                  repeat: 'None',
                  color: Colors.blue.value,
                  isCompleted: false,
                ),
              );
              final updatedTask = Task(
                id: newTaskData['id'] as int,
                title: newTaskData['title'] as String,
                note: newTaskData['note'] as String,
                location: newTaskData['location'] as String,
                date: DateTime.parse(newTaskData['date'] as String),
                startTime: newTaskData['startTime'] as TimeOfDay,
                endTime: newTaskData['endTime'] as TimeOfDay,
                reminder: newTaskData['reminder'] as int,
                repeat: newTaskData['repeat'] as String,
                color: newTaskData['color'] as int,
                isCompleted: newTaskData['isCompleted'] as bool? ?? originalTask.isCompleted,
              );
              await TaskDatabase.instance.updateTask(updatedTask);
              // Cancel existing notification
              await _notificationService.cancelNotification(updatedTask.id ?? 0);
              // Schedule new notification if enabled
              if (_notificationsEnabled) {
                final reminderTime = DateTime(
                  updatedTask.date.year,
                  updatedTask.date.month,
                  updatedTask.date.day,
                  updatedTask.startTime.hour,
                  updatedTask.startTime.minute,
                ).subtract(Duration(minutes: updatedTask.reminder));
                await _notificationService.scheduleTaskNotification(
                  id: updatedTask.id ?? 0,
                  title: updatedTask.title,
                  body: updatedTask.note.isNotEmpty ? updatedTask.note : 'Task reminder',
                  scheduledDate: reminderTime,
                  notificationsEnabled: _notificationsEnabled,
                  payload: updatedTask.id.toString(),
                );
              }
              await _loadTasks();
            } else {
              final newTask = Task(
                title: newTaskData['title'] as String,
                note: newTaskData['note'] as String,
                location: newTaskData['location'] as String,
                date: DateTime.parse(newTaskData['date'] as String),
                startTime: newTaskData['startTime'] as TimeOfDay,
                endTime: newTaskData['endTime'] as TimeOfDay,
                reminder: newTaskData['reminder'] as int,
                repeat: newTaskData['repeat'] as String,
                color: newTaskData['color'] as int,
                isCompleted: false,
              );
              await _addTask(newTask);
            }
          }
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}