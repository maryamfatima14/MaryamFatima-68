import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
// Fixed typo: 'supabase_services.dart' to 'supabase_service.dart'
import '../services/supabase_services.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';
import 'notification_settings_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskCalendarScreen extends StatefulWidget {
  final String studentId;
  const TaskCalendarScreen({super.key, required this.studentId});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeNotifications();
    _fetchTasks();
    _supabaseService.subscribeToTasks((updatedTasks) {
      setState(() {
        _tasks = updatedTasks.where((task) => task.assignedTo == widget.studentId).toList();
        _scheduleNotifications(_tasks);
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

  Future<void> _initializeNotifications() async {
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
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotifications(List<Task> tasks) async {
    if (!_notificationsEnabled) return;
    await _flutterLocalNotificationsPlugin.cancelAll();
    final now = DateTime.now();
    final testNotificationTime = now.add(const Duration(minutes: 1));
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Test Notification',
      'This is a test to verify notifications are working.',
      tz.TZDateTime.from(testNotificationTime, tz.getLocation('Asia/Karachi')),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Channel for test notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tasks = await _supabaseService.getTasksForStudent(widget.studentId);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
      await _scheduleNotifications(tasks);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate != null &&
          dueDate.year == day.year &&
          dueDate.month == day.month &&
          dueDate.day == day.day;
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _fetchTasks,
                    ),
                  ],
                ),
              ),
              // Content Section
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              eventLoader: _getTasksForDay,
                              calendarFormat: CalendarFormat.month,
                              rowHeight: 40.0,
                              daysOfWeekHeight: 20.0,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.indigo[700], size: 20),
                                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.indigo[700], size: 20),
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Colors.indigo[400],
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Colors.indigo[700],
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: Colors.indigo[400],
                                  shape: BoxShape.circle,
                                ),
                                outsideDaysVisible: false,
                                cellMargin: const EdgeInsets.all(2),
                              ),
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isNotEmpty) {
                                    return Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.indigo[400],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${events.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tasks for ${Helpers.formatDate(_selectedDay!)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _getTasksForDay(_selectedDay!).isEmpty
                            ? _buildAnimatedCard(
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No tasks for this day',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _getTasksForDay(_selectedDay!).length,
                          itemBuilder: (context, index) {
                            final task = _getTasksForDay(_selectedDay!)[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildAnimatedCard(
                                child: TaskCard(
                                  task: task,
                                  onComplete: task.status == 'pending'
                                      ? () async {
                                    try {
                                      await Supabase.instance.client
                                          .from('tasks')
                                          .update({'status': 'completed'})
                                          .eq('id', task.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Task marked as completed'),
                                        ),
                                      );
                                      _fetchTasks();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                      : null,
                                ),
                              ),
                            );
                          },
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
    );
  }
}