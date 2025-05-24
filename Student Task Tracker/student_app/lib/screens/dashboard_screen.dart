import 'package:flutter/material.dart';
import 'package:student_task_tracker/screens/notification_settings_screen.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_task_tracker/screens/task_calender_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/task.dart';
import '../services/supabase_services.dart';
import '../utils/helper.dart';
import '../widgets/streak_indicader.dart';
import 'task_list_screen.dart';
import 'performance_screen.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  final User student;
  const DashboardScreen({super.key, required this.student});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _notificationsEnabled = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadNotificationPreference();
    _fetchTasks();
    _supabaseService.subscribeToTasks((updatedTasks) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          final newTasks = updatedTasks.where((task) => task.assignedTo == widget.student.id).toList();
          final newlyAssignedTasks = newTasks.where((newTask) =>
          !_tasks.any((existingTask) => existingTask.id == newTask.id)).toList();

          setState(() {
            _tasks = newTasks;
          });

          _scheduleNotifications(_tasks);

          if (_notificationsEnabled) {
            for (var task in newlyAssignedTasks) {
              if (task.status == 'pending') {
                _scheduleTaskAssignmentNotification(task);
              }
            }
          }
        }
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    setState(() {
      _notificationsEnabled = enabled;
    });
    if (!enabled) {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Notifications disabled, all notifications canceled.');
    } else {
      _scheduleNotifications(_tasks);
    }
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    bool? initialized = await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    debugPrint('Notification initialization: ${initialized == true ? "Success" : "Failed"}');

    bool? iosPermission = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('iOS notification permission: ${iosPermission == true ? "Granted" : "Denied"}');

    bool? androidPermission = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    debugPrint('Android notification permission: ${androidPermission == true ? "Granted" : "Denied"}');
  }

  Future<void> _scheduleTaskAssignmentNotification(Task task) async {
    if (!_notificationsEnabled) {
      debugPrint('Notifications are disabled, skipping task assignment notification.');
      return;
    }

    final now = DateTime.now();
    final notificationTime = now.add(const Duration(seconds: 5));
    debugPrint('Scheduling task assignment notification for task: ${task.title} at $notificationTime');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      ('assignment_${task.id}').hashCode,
      'New Task Assigned: ${task.title}',
      'Due on ${Helpers.formatDate(task.dueDate!)}',
      _convertToTZDateTime(notificationTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignment_channel',
          'Task Assignment Notifications',
          channelDescription: 'Notifications for newly assigned tasks',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleNotifications(List<Task> tasks) async {
    if (!_notificationsEnabled) {
      debugPrint('Notifications are disabled, skipping scheduling.');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All previous notifications canceled.');

    final now = DateTime.now();
    debugPrint('Current time: $now');

    for (var task in tasks) {
      if (task.status == 'pending' && task.dueDate != null && task.dueDate!.isAfter(now)) {
        final notificationTime = task.dueDate!.subtract(const Duration(hours: 1));
        if (notificationTime.isAfter(now)) {
          debugPrint('Scheduling notification for task: ${task.title} at $notificationTime');
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            task.id.hashCode,
            'Task Reminder: ${task.title}',
            'Due on ${Helpers.formatDate(task.dueDate!)}',
            _convertToTZDateTime(notificationTime),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'task_channel',
                'Task Reminders',
                channelDescription: 'Notifications for upcoming tasks',
                importance: Importance.max,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } else {
          debugPrint('Notification time $notificationTime is in the past for task: ${task.title}');
        }
      }
    }
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.getLocation('Asia/Karachi'));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tasks = await _supabaseService.getTasksForStudent(widget.student.id);
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
        await _scheduleNotifications(tasks);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tasks: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int get _streak {
    int streak = 0;
    final sortedTasks = _tasks.where((task) => task.status == 'completed').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final today = DateTime.now();
    for (var task in sortedTasks) {
      if (task.createdAt.day == today.day) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> _markTaskComplete(Task task) async {
    try {
      await _supabaseService.updateTaskStatus(task.id, 'completed');
      await _flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
      debugPrint('Canceled notification for completed task: ${task.title}');
      await _supabaseService.sendAdminNotification(
        widget.student.id,
        'Task "${task.title}" completed by ${widget.student.name}',
        'task_completed',
      );
      await _fetchTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking task as complete: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // Home: Already on DashboardScreen, no navigation needed
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskListScreen(studentId: widget.student.id)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskCalendarScreen(studentId: widget.student.id)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PerformanceScreen(studentId: widget.student.id)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _tasks.where((task) => task.status == 'pending').length;
    final completedTasks = _tasks.where((task) => task.status == 'completed').length;
    final recentTasks = _tasks
        .where((task) => task.status == 'pending')
        .take(3)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final now = DateTime.now();
    final upcomingTasks = _tasks
        .where((task) => task.status == 'pending' && task.dueDate != null && task.dueDate!.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[700]!, Colors.indigo[300]!],
            stops: const [0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () async {
                            debugPrint('Notification icon tapped at ${DateTime.now()}');
                            try {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationSettingsScreen(
                                    notificationsEnabled: _notificationsEnabled,
                                  ),
                                ),
                              );
                              debugPrint('Navigation returned with result: $result');
                              if (result != null && result is bool) {
                                await _saveNotificationPreference(result);
                                debugPrint('Notification preference updated to: $result');
                              }
                            } catch (e) {
                              debugPrint('Error during navigation: $e');
                            }
                          },
                          tooltip: 'Notification Settings',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          color: Colors.white,
                          onPressed: _fetchTasks,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.indigo[100],
                                  child: Icon(
                                    Icons.person,
                                    size: 45,
                                    color: Colors.indigo[700],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${widget.student.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Overview',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatCard(
                                      context,
                                      label: 'Pending',
                                      value: pendingTasks.toString(),
                                      color: Colors.indigo[400]!,
                                    ),
                                    _buildStatCard(
                                      context,
                                      label: 'Completed',
                                      value: completedTasks.toString(),
                                      color: Colors.indigo[700]!,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Recent Tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        recentTasks.isEmpty
                            ? _buildAnimatedCard(
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: Text('No pending tasks')),
                          ),
                        )
                            : Column(
                          children: recentTasks
                              .map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildAnimatedCard(
                              child: TaskCard(
                                task: task,
                                onComplete: () => _markTaskComplete(task),
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upcoming Due Dates',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                upcomingTasks.isEmpty
                                    ? const Center(child: Text('No upcoming tasks'))
                                    : SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    itemCount: upcomingTasks.length > 3 ? 3 : upcomingTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = upcomingTasks[index];
                                      return ListTile(
                                        title: Text(
                                          task.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          'Due: ${Helpers.formatDate(task.dueDate!)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (upcomingTasks.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: _buildAnimatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TaskCalendarScreen(studentId: widget.student.id),
                                        ),
                                      ),
                                      child: Text(
                                        'View More',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Streak',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                StreakIndicator(streak: _streak),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Performance',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo[700],
        unselectedItemColor: Colors.indigo[300],
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation: 6 * _scaleAnimation.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: child,
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({required VoidCallback onPressed, required Widget child}) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) {
          _animationController.reverse();
          onPressed();
        },
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.indigo[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * _scaleAnimation.value),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}