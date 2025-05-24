import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../services/supabase_service.dart';
import '../models/user.dart';
import '../models/task.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feedbackCommentsController = TextEditingController();
  List<User> _students = [];
  List<Task> _tasks = [];
  String? _selectedStudentId;
  DateTime? _dueDate;
  bool _isLoading = true;
  Task? _editingTask;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _supabaseService.subscribeToTasks((tasks) {
      if (mounted) {
        setState(() {
          _tasks = tasks;
          for (var task in _tasks.where((t) => t.status == 'completed' && t.feedbackCategory == null)) {
            _supabaseService.sendAdminNotification(
              '00000000-0000-0000-0000-000000000000',
              'Task "${task.title}" completed, awaiting feedback',
              'task_completed',
            );
          }
        });
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final students = await _supabaseService.getStudents();
      final tasks = await _supabaseService.getTasks();
      if (mounted) {
        setState(() {
          _students = students;
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _assignTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty || _selectedStudentId == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all required fields')));
      return;
    }
    try {
      if (_editingTask == null) {
        await _supabaseService.assignTask(
          title: title,
          description: description,
          assignedTo: _selectedStudentId!,
          dueDate: _dueDate!,
          createdBy: '00000000-0000-0000-0000-000000000000',
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task assigned')));
      } else {
        await _supabaseService.updateTask(
          taskId: _editingTask!.id,
          title: title,
          description: description,
          assignedTo: _selectedStudentId!,
          dueDate: _dueDate!,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated')));
      }
      _clearForm();
      await _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _bulkAssignTasks() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      final file = result.files.single;
      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File content inaccessible')));
        return;
      }
      final input = utf8.decode(file.bytes!);
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(input);
      List<Map<String, String>> tasks = [];
      for (var row in csvTable.skip(1)) {
        if (row.length >= 2 && row[0] != null && row[1] != null) {
          tasks.add({
            'title': row[0].toString().trim(),
            'description': row.length > 2 ? row[2].toString().trim() : '',
            'assigned_to': row[1].toString().trim(),
            'due_date': row.length > 3 ? row[3].toString().trim() : '',
          });
        }
      }
      if (tasks.isNotEmpty) {
        try {
          await _supabaseService.bulkAssignTasks(tasks);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tasks assigned')));
          _fetchData();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid task data')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file selected')));
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _supabaseService.deleteTask(taskId);
      await _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _updateTaskStatus(String taskId, String status) async {
    try {
      await _supabaseService.updateTaskStatus(taskId as String, status);
      await _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _provideFeedback(Task task) async {
    _feedbackCommentsController.text = '';
    String? selectedFeedback;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Provide Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFeedback,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Excellent',
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Excellent'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Good',
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Good'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Normal',
                    child: Row(
                      children: [
                        Icon(Icons.adjust, color: Colors.blueGrey),
                        SizedBox(width: 8),
                        Text('Normal'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Poor',
                    child: Row(
                      children: [
                        Icon(Icons.sentiment_neutral, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Poor'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Bad',
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Bad'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  selectedFeedback = value;
                },
                hint: const Text('Select Feedback'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackCommentsController,
                decoration: const InputDecoration(labelText: 'Comments (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedFeedback == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a feedback category')));
                return;
              }
              try {
                await _supabaseService.updateTaskFeedback(
                  task.id,
                  selectedFeedback as String,
                  _feedbackCommentsController.text.trim().isEmpty ? null : _feedbackCommentsController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted')));
                await _fetchData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.indigo,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _editTask(Task task) {
    setState(() {
      _editingTask = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedStudentId = task.assignedTo;
      _dueDate = task.dueDate;
    });
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assigned to: ${task.assignedTo}'),
              Text('Due: ${DateFormat('yyyy-MM-dd').format(task.dueDate)}'),
              Text('Status: ${task.status}'),
              if (task.feedbackCategory != null) ...[
                Row(
                  children: [
                    Text('Feedback: ${task.feedbackCategory}'),
                    const SizedBox(width: 8),
                    Icon(
                      task.feedbackCategory == 'Excellent'
                          ? Icons.emoji_events
                          : task.feedbackCategory == 'Good'
                          ? Icons.thumb_up
                          : task.feedbackCategory == 'Normal'
                          ? Icons.adjust
                          : task.feedbackCategory == 'Poor'
                          ? Icons.sentiment_neutral
                          : Icons.warning,
                      color: task.feedbackCategory == 'Excellent'
                          ? Colors.amber
                          : task.feedbackCategory == 'Good'
                          ? Colors.green
                          : task.feedbackCategory == 'Normal'
                          ? Colors.blueGrey
                          : task.feedbackCategory == 'Poor'
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ],
                ),
                if (task.feedbackComments != null) Text('Comments: ${task.feedbackComments}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editTask(task);
            },
            child: const Icon(Icons.edit, color: Colors.blue),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: Text('Delete "${task.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ) == true) {
                await _deleteTask(task.id);
              }
            },
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTaskStatus(task.id, task.status == 'completed' ? 'pending' : 'completed');
            },
            child: Icon(
              task.status == 'completed' ? Icons.undo : Icons.check,
              color: task.status == 'completed' ? Colors.orange : Colors.green,
            ),
          ),
          if (task.status == 'completed' && task.feedbackCategory == null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _provideFeedback(task);
              },
              child: const Icon(Icons.feedback, color: Colors.purple),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedStudentId = null;
    _dueDate = null;
    _editingTask = null;
    setState(() {});
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
              // Simplified Header without Profile Pic
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _editingTask == null ? 'Assign Tasks' : 'Edit Task',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _fetchData,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Task Title',
                                prefixIcon: const Icon(Icons.title),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description (Optional)',
                                prefixIcon: const Icon(Icons.description),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedStudentId,
                              decoration: InputDecoration(
                                labelText: 'Assign To',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: _students.isEmpty
                                  ? [const DropdownMenuItem(value: null, child: Text('No students'))]
                                  : _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                              onChanged: _students.isEmpty ? null : (v) => setState(() => _selectedStudentId = v),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _dueDate == null ? 'Select Due Date' : 'Due: ${DateFormat('yyyy-MM-dd').format(_dueDate!)}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _selectDate(context),
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text('Pick Date'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _assignTask,
                              icon: Icon(_editingTask == null ? Icons.assignment_add : Icons.save),
                              label: Text(_editingTask == null ? 'Assign Task' : 'Update Task'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                            ),
                            if (_editingTask != null) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearForm,
                                child: const Text('Cancel Edit', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _bulkAssignTasks,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Bulk Assign Tasks via CSV'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                            ),
                            const SizedBox(height: 24),
                            _tasks.isEmpty
                                ? const Center(child: Text('No tasks'))
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                final student = _students.firstWhere(
                                      (s) => s.id == task.assignedTo,
                                  orElse: () => User(id: '', name: 'Unknown'),
                                );
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8),
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: task.status == 'completed' ? Colors.green[100] : Colors.orange[100],
                                      child: Icon(
                                        task.status == 'completed' ? Icons.check_circle : Icons.pending,
                                        size: 16,
                                        color: task.status == 'completed' ? Colors.green[800] : Colors.orange[800],
                                      ),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            student.name.length > 10 ? '${student.name.substring(0, 10)}...' : student.name,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            DateFormat('yyyy-MM-dd').format(task.dueDate),
                                            style: Theme.of(context).textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () => _showTaskDetails(task),
                                      child: const Icon(Icons.more_horiz, color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _feedbackCommentsController.dispose();
    super.dispose();
  }
}