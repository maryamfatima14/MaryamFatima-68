import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sleep_screen.dart';

class WakeUpScreen extends StatefulWidget {
  const WakeUpScreen({super.key});

  @override
  State<WakeUpScreen> createState() => _WakeUpScreenState();
}

class _WakeUpScreenState extends State<WakeUpScreen> {
  int selectedHour = 8;
  int selectedMinute = 0;
  String selectedPeriod = 'AM';

  final List<int> hours = List.generate(12, (index) => index + 1);
  final List<int> minutes = List.generate(60, (index) => index);
  final List<String> periods = ['AM', 'PM'];

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
                      "When Do You",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Wake Up?",
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
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setInt('wakeUpHour', selectedHour);
                          prefs.setInt('wakeUpMinute', selectedMinute);
                          prefs.setString('wakeUpPeriod', selectedPeriod);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SleepScreen(),
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