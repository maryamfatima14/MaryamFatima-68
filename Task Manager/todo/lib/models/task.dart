import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task {
  final int? id;
  final String title;
  final String note;
  final String location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int reminder;
  final String repeat;
  final int color;
  final bool isCompleted;
  final bool notificationsEnabled;

  Task({
    this.id,
    required this.title,
    required this.note,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reminder,
    required this.repeat,
    required this.color,
    required this.isCompleted,
    this.notificationsEnabled = false,
  });

  Task copyWith({
    int? id,
    String? title,
    String? note,
    String? location,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? reminder,
    String? repeat,
    int? color,
    bool? isCompleted,
    bool? notificationsEnabled,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminder: reminder ?? this.reminder,
      repeat: repeat ?? this.repeat,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'location': location,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'reminder': reminder,
      'repeat': repeat,
      'color': color,
      'isCompleted': isCompleted ? 1 : 0,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      note: map['note'] ?? '',
      location: map['location'] ?? '',
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(map['startTime'].split(':')[0]),
        minute: int.parse(map['startTime'].split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(map['endTime'].split(':')[0]),
        minute: int.parse(map['endTime'].split(':')[1]),
      ),
      reminder: map['reminder'],
      repeat: map['repeat'],
      color: map['color'],
      isCompleted: map['isCompleted'] == 1,
      notificationsEnabled: map['notificationsEnabled'] == 1,
    );
  }
}