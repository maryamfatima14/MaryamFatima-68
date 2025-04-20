import 'package:flutter/material.dart';

class TimeProvider with ChangeNotifier {
  // Default wake-up and sleep times
  TimeOfDay wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay sleepTime = const TimeOfDay(hour: 22, minute: 0);

  // Wake-up time ko update karne ka method
  void updateWakeUpTime(TimeOfDay newTime) {
    wakeUpTime = newTime;
    notifyListeners();  // UI ko notify karna ke state change hui hai
  }

  // Sleep time ko update karne ka method
  void updateSleepTime(TimeOfDay newTime) {
    sleepTime = newTime;
    notifyListeners();  // UI ko notify karna ke state change hui hai
  }
}
