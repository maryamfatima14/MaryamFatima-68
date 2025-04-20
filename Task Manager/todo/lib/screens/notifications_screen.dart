import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    if (!value) {
      await _notificationService.cancelAllNotifications();
    } else {
      // Reschedule sleep notification if a sleep time is set
      final hour = prefs.getInt('sleepHour');
      final minute = prefs.getInt('sleepMinute');
      final period = prefs.getString('sleepPeriod');
      if (hour != null && minute != null && period != null) {
        int hour24 = hour;
        if (period == 'PM' && hour != 12) {
          hour24 += 12;
        } else if (period == 'AM' && hour == 12) {
          hour24 = 0;
        }
        await _notificationService.scheduleSleepNotification(
          hour: hour24,
          minute: minute,
        );
      }
    }
  }

  void _toggleNotification(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _saveNotificationSetting(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8BBD0), // Baby pink background (same as AboutScreen)
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700, // Blue app bar (same as AboutScreen)
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white, // White text (same as AboutScreen)
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.blue.shade900,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE), // Light pink background (same as AboutScreen)
              border: Border.all(
                color: Colors.blueAccent, // Blue border
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notification Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 20),

                // Notification Settings
                SwitchListTile(
                  title: const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: const Text(
                    'Turn on to receive task reminders',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: _toggleNotification,
                  activeColor: Colors.blue.shade700,
                ),
                const SizedBox(height: 20),

                // Status Indicator
                Text(
                  _notificationsEnabled
                      ? "✅ Notifications are ON"
                      : "❌ Notifications are OFF",
                  style: TextStyle(
                    fontSize: 16,
                    color: _notificationsEnabled ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}