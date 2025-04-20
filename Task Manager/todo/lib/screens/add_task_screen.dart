import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;
  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  int _selectedReminder = 10;
  String _selectedRepeat = 'None';
  Color _selectedColor = Colors.blue;
  final List<int> _reminderOptions = [5, 10, 15, 20];
  final List<String> _repeatOptions = ['None', 'Daily', 'Weekly', 'Monthly'];
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.pink,
    Colors.red,
    Colors.brown,
    Colors.grey,
  ];
  final TextStyle _blackTextStyle = const TextStyle(color: Colors.black, fontSize: 16.0);

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _noteController.text = widget.task!.note;
      _locationController.text = widget.task!.location;
      _selectedDate = widget.task!.date;
      _selectedStartTime = widget.task!.startTime;
      _selectedEndTime = widget.task!.endTime;
      _selectedReminder = widget.task!.reminder;
      _selectedRepeat = widget.task!.repeat;
      _selectedColor = Color(widget.task!.color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Note',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date:', style: _blackTextStyle),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(DateFormat.yMd().format(_selectedDate), style: _blackTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start Time:', style: _blackTextStyle),
                TextButton(
                  onPressed: _pickStartTime,
                  child: Text(_selectedStartTime.format(context), style: _blackTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('End Time:', style: _blackTextStyle),
                TextButton(
                  onPressed: _pickEndTime,
                  child: Text(_selectedEndTime.format(context), style: _blackTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind Me:', style: _blackTextStyle),
                DropdownButton<int>(
                  value: _selectedReminder,
                  dropdownColor: Colors.pink[100],
                  style: const TextStyle(color: Colors.black),
                  iconEnabledColor: Colors.black,
                  items: _reminderOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value minutes before'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedReminder = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Repeat:', style: _blackTextStyle),
                DropdownButton<String>(
                  value: _selectedRepeat,
                  dropdownColor: Colors.pink[100],
                  style: const TextStyle(color: Colors.black),
                  iconEnabledColor: Colors.black,
                  items: _repeatOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Text('Color:', style: _blackTextStyle),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: _colorOptions.map((Color color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 18.0,
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Save Task', style: TextStyle(fontSize: 18.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<bool> _getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? false;
  }

  void _saveTask() async {
    final String title = _titleController.text.trim();
    final String note = _noteController.text.trim();
    final String location = _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title is required')),
      );
      return;
    }

    final taskData = {
      'title': title,
      'note': note,
      'location': location,
      'date': _selectedDate.toIso8601String(),
      'startTime': _selectedStartTime,
      'endTime': _selectedEndTime,
      'reminder': _selectedReminder,
      'repeat': _selectedRepeat,
      'color': _selectedColor.value,
    };

    if (widget.task != null) {
      taskData['id'] = widget.task!.id ?? 0;
    }

    // Schedule notification only if notifications are enabled
    final bool notificationsEnabled = await _getNotificationsEnabled();
    if (notificationsEnabled) {
      final notificationService = NotificationService();
      final reminderTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      ).subtract(Duration(minutes: _selectedReminder));

      final payload = widget.task?.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

      await notificationService.scheduleTaskNotification(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: note.isNotEmpty ? note : 'Task reminder',
        scheduledDate: reminderTime,
        notificationsEnabled: notificationsEnabled,
        payload: payload,
      );
    }

    Navigator.pop(context, taskData);
  }
}