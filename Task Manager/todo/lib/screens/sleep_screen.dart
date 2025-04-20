import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/notification_service.dart';

import 'home_screen.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int selectedHour = 8;
  int selectedMinute = 0;
  String selectedPeriod = 'AM';
  final NotificationService _notificationService = NotificationService();

  final List<int> hours = List.generate(12, (index) => index + 1);
  final List<int> minutes = List.generate(60, (index) => index);
  final List<String> periods = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _loadSleepTime();
  }

  Future<void> _loadSleepTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedHour = prefs.getInt('sleepHour') ?? 8;
      selectedMinute = prefs.getInt('sleepMinute') ?? 0;
      selectedPeriod = prefs.getString('sleepPeriod') ?? 'AM';
    });
  }

  Future<void> _saveSleepTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleepHour', selectedHour);
    await prefs.setInt('sleepMinute', selectedMinute);
    await prefs.setString('sleepPeriod', selectedPeriod);

    // Convert 12-hour format to 24-hour format for scheduling
    int hour24 = selectedHour;
    if (selectedPeriod == 'PM' && selectedHour != 12) {
      hour24 += 12;
    } else if (selectedPeriod == 'AM' && selectedHour == 12) {
      hour24 = 0;
    }

    // Schedule notification if notifications are enabled
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    if (notificationsEnabled) {
      await _notificationService.scheduleSleepNotification(
        hour: hour24,
        minute: selectedMinute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/header.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What Time Do You",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Sleep?",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Simply scroll to adjust the time",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPicker(hours, selectedHour, (val) {
                            setState(() => selectedHour = val);
                          }),
                          _buildPicker(minutes, selectedMinute, (val) {
                            setState(() => selectedMinute = val);
                          }),
                          _buildPicker(periods, selectedPeriod, (val) {
                            setState(() => selectedPeriod = val);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "You can change this later in the app",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () async {
                          await _saveSleepTime();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(List list, dynamic selectedValue, Function(dynamic) onChanged) {
    return SizedBox(
      height: 150,
      width: 80,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(
          initialItem: list.indexOf(selectedValue),
        ),
        itemExtent: 40,
        onSelectedItemChanged: (index) => onChanged(list[index]),
        children: list
            .map((e) => Center(
          child: Text(
            e is int ? e.toString().padLeft(2, '0') : e.toString(),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}