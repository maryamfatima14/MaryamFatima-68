import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:todo/db/task_database.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models//notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedIndex = 0;
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 4, minute: 30);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 21, minute: 30);
  List<Task> todaysTasks = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadTimes();
    _loadTodaysTasks();
  }

  Future<void> _loadTodaysTasks() async {
    final tasks = await TaskDatabase.instance.getTasksByDateAndCompletion(
      _selectedDate,
      true, // Only completed tasks
    );
    if (mounted) {
      setState(() {
        todaysTasks = tasks;
      });
    }
  }

  Future<void> _loadTimes() async {
    final prefs = await SharedPreferences.getInstance();

    int wakeHour = prefs.getInt('wakeUpHour') ?? 4;
    int wakeMinute = prefs.getInt('wakeUpMinute') ?? 30;
    String wakePeriod = prefs.getString('wakeUpPeriod') ?? 'AM';

    if (wakePeriod == 'PM' && wakeHour != 12) wakeHour += 12;
    if (wakePeriod == 'AM' && wakeHour == 12) wakeHour = 0;

    int sleepHour = prefs.getInt('sleepHour') ?? 21;
    int sleepMinute = prefs.getInt('sleepMinute') ?? 30;
    String sleepPeriod = prefs.getString('sleepPeriod') ?? 'PM';

    if (sleepPeriod == 'PM' && sleepHour != 12) sleepHour += 12;
    if (sleepPeriod == 'AM' && sleepHour == 12) sleepHour = 0;

    if (mounted) {
      setState(() {
        _wakeUpTime = TimeOfDay(hour: wakeHour, minute: wakeMinute);
        _sleepTime = TimeOfDay(hour: sleepHour, minute: sleepMinute);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadTodaysTasks();
    }
  }

  Future<void> _selectWakeUpTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
    );
    if (picked != null && picked != _wakeUpTime && mounted) {
      setState(() {
        _wakeUpTime = picked;
      });
      final prefs = await SharedPreferences.getInstance();
      int hour = picked.hour;
      String period = (hour >= 12) ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      await prefs.setInt('wakeUpHour', hour);
      await prefs.setInt('wakeUpMinute', picked.minute);
      await prefs.setString('wakeUpPeriod', period);
    }
  }

  Future<void> _selectSleepTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sleepTime,
    );
    if (picked != null && picked != _sleepTime && mounted) {
      setState(() {
        _sleepTime = picked;
      });
      final prefs = await SharedPreferences.getInstance();
      int hour = picked.hour;
      String period = (hour >= 12) ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      await prefs.setInt('sleepHour', hour);
      await prefs.setInt('sleepMinute', picked.minute);
      await prefs.setString('sleepPeriod', period);

      // Schedule sleep notification if notifications are enabled
      final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      if (notificationsEnabled) {
        int hour24 = picked.hour;
        await _notificationService.scheduleSleepNotification(
          hour: hour24,
          minute: picked.minute,
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushNamed(context, '/taskHome').then((_) {
        // Refresh tasks when returning from TaskHome
        _loadTodaysTasks();
      });
    } else if (index == 2) {
      _downloadHomeScreenAsPdf();
    }
  }

  Future<void> _downloadHomeScreenAsPdf() async {
    final pdf = pw.Document();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                text: 'Daily Planner - $formattedDate',
              ),
              pw.SizedBox(height: 20),
              pw.Text('Wake Up Time: ${_wakeUpTime.format(context)}'),
              pw.Text('Sleep Time: ${_sleepTime.format(context)}'),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                text: "Today's Completed Tasks",
              ),
              pw.ListView.builder(
                itemCount: todaysTasks.length,
                itemBuilder: (pdfContext, index) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('• ${todaysTasks[index].title}'),
                  );
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text('Selected Date: ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}'),
            ],
          );
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/planner_$formattedDate.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to ${file.path}'),
          duration: const Duration(seconds: 2),
        ),
      );

      await OpenFile.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF Error: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Row(
          children: [
            Text(
              DateFormat('MMMM').format(_selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('yyyy').format(_selectedDate),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodaysTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildCalendarSection(),
              _buildSleepWakeCards(),
              _buildTasksSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.blue.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCalendarSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.28, // Reduced height
      child: Column(
        children: [
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildWeekdayLabels(),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Reduced padding
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                childAspectRatio: 1.2, // More rectangular cells
                children: _buildCalendarDays(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepWakeCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimeCard(
            icon: Icons.alarm,
            title: 'Wake Up',
            time: _wakeUpTime,
            onTap: () => _selectWakeUpTime(context),
          ),
          const SizedBox(height: 20),
          _buildTimeCard(
            icon: FontAwesomeIcons.moon,
            title: 'Sleep',
            time: _sleepTime,
            onTap: () => _selectSleepTime(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Tasks - ${DateFormat('MMM dd').format(_selectedDate)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Header text in black
                ),
              ),
              const SizedBox(height: 8),
              todaysTasks.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "No tasks for today",
                    style: TextStyle(
                      color: Colors.black, // "No tasks" text in black
                      fontSize: 16,
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todaysTasks.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(todaysTasks[index].color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    todaysTasks[index].title,
                    style: TextStyle(
                      color: Colors.black, // Task title in black
                      decoration: todaysTasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    todaysTasks[index].note,
                    style: const TextStyle(
                      color: Colors.black, // Task note in black
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      todaysTasks[index].isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: todaysTasks[index].isCompleted
                          ? Colors.green
                          : Colors.grey,
                    ),
                    onPressed: () async {
                      await TaskDatabase.instance.updateTask(
                        todaysTasks[index].copyWith(
                          isCompleted: !todaysTasks[index].isCompleted,
                        ),
                      );
                      _loadTodaysTasks();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeekdayLabels() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        .map((day) => Text(day, style: const TextStyle(color: Colors.black87)))
        .toList();
  }

  List<Widget> _buildCalendarDays() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstWeekday = firstDay.weekday;
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysFromNextMonth = 7 - lastDay.weekday;

    return List.generate(firstWeekday - 1 + daysInMonth + daysFromNextMonth, (index) {
      final dayIndex = index - firstWeekday + 2;
      final isCurrentMonth = dayIndex > 0 && dayIndex <= daysInMonth;
      final isSelected = isCurrentMonth && dayIndex == _selectedDate.day;

      return Container(
        margin: const EdgeInsets.all(1), // Minimal margin
        child: InkWell(
          onTap: isCurrentMonth
              ? () => setState(() {
            _selectedDate = DateTime(firstDay.year, firstDay.month, dayIndex);
            _loadTodaysTasks();
          })
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.shade200 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isCurrentMonth ? '$dayIndex' : '',
                style: TextStyle(
                  fontSize: 12, // Smaller font
                  color: isSelected
                      ? Colors.white
                      : (isCurrentMonth ? Colors.black87 : Colors.grey),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.pink.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: Icon(icon, color: Colors.pink.shade700),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Changed to black
          ),
        ),
        subtitle: Text(
          time.format(context),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black, // Changed to black
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}