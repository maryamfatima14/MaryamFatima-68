import 'dart:convert';
import 'package:flutter/material.dart' as material;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart' as rx;
import '../models/user.dart' as local_user;
import '../models/task.dart';
import '../models/notification.dart';
import 'dart:math';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  final rx.BehaviorSubject<List<Notification>> _notificationSubject = rx.BehaviorSubject<List<Notification>>();

  Stream<List<Notification>> get notifications => _notificationSubject.stream;

  String _generateKeyId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    final randomPart = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return '$timestamp$randomPart'; // e.g., 1234ABCD
  }

  Future<String> _generateLoginId() async {
    try {
      material.debugPrint('Attempting to call get_student_count RPC...');
      final response = await _client.rpc('get_student_count').single();
      material.debugPrint('get_student_count raw response: $response');

      int totalStudents;
      if (response is int) {
        totalStudents = response as int;
        material.debugPrint('Parsed int response: $totalStudents');
      } else if (response is Map && response.containsKey('count')) {
        totalStudents = response['count'] as int;
        material.debugPrint('Parsed Map response: $totalStudents');
      } else {
        material.debugPrint('Unexpected response type from get_student_count: $response');
        final fallbackResponse = await _client.from('users').select('id').eq('role', 'student').count();
        totalStudents = fallbackResponse.count;
        material.debugPrint('Fallback count: $totalStudents');
      }

      final loginId = 'CSA-${(totalStudents + 1).toString().padLeft(3, '0')}';
      material.debugPrint('Generated login_id: $loginId');
      return loginId;
    } catch (e) {
      material.debugPrint('Error in _generateLoginId: $e');
      try {
        final fallbackResponse = await _client.from('users').select('id').eq('role', 'student').count();
        final totalStudents = fallbackResponse.count;
        final loginId = 'CSA-${(totalStudents + 1).toString().padLeft(3, '0')}';
        material.debugPrint('Generated login_id via fallback: $loginId');
        return loginId;
      } catch (fallbackError) {
        material.debugPrint('Fallback failed in _generateLoginId: $fallbackError');
        throw Exception('Failed to generate login_id: $e');
      }
    }
  }

  Future<List<local_user.User>> getStudents() async {
    try {
      material.debugPrint('Fetching students from users table...');
      final response = await _client.from('users').select().eq('role', 'student');
      material.debugPrint('Fetched students: ${response.length}');
      if (response.isEmpty) {
        material.debugPrint('No students found in users table with role=student');
      }
      return response.map((data) => local_user.User.fromJson(data)).toList();
    } catch (e) {
      material.debugPrint('Error fetching students: $e');
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<String> addStudent(String name) async {
    try {
      material.debugPrint('Adding student: $name');
      final keyId = _generateKeyId();
      material.debugPrint('Generated key_id: $keyId');

      final loginId = await _generateLoginId();
      material.debugPrint('Inserting student into users table...');
      final response = await _client.from('users').insert({
        'name': name,
        'role': 'student',
        'key_id': keyId,
        'login_id': loginId,
      }).select('id').single();

      material.debugPrint('Insert response: $response');
      final String id = response['id'].toString();
      material.debugPrint('Student added successfully: $name with ID: $id, Key ID: $keyId, Login ID: $loginId');
      return id;
    } catch (e) {
      material.debugPrint('Error in addStudent: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(String id, String newName) async {
    try {
      await _client.from('users').update({'name': newName}).eq('id', id);
      material.debugPrint('Student updated: $id with new name: $newName');
    } catch (e) {
      material.debugPrint('Error updating student: $e');
      throw Exception('Failed to update student: $e');
    }
  }

  Future<void> bulkUploadStudents(List<Map<String, String>> students) async {
    try {
      if (students.isEmpty) throw Exception('No student data provided');
      final validStudents = <Map<String, dynamic>>[];
      final currentCountResponse = await _client.rpc('get_student_count').single();
      int nextLoginIdNumber;
      if (currentCountResponse is int) {
        nextLoginIdNumber = currentCountResponse as int;
      } else if (currentCountResponse.containsKey('count')) {
        nextLoginIdNumber = currentCountResponse['count'] as int;
      } else {
        final fallbackResponse = await _client.from('users').select('id').eq('role', 'student').count();
        nextLoginIdNumber = fallbackResponse.count;
        material.debugPrint('Fallback count for bulkUploadStudents: $nextLoginIdNumber');
      }

      for (var student in students) {
        final name = student['name']?.trim();
        final originalId = student['ORIGINAL ID']?.trim();
        if (name == null || name.isEmpty) {
          material.debugPrint('Skipping invalid student entry: missing name');
          continue;
        }
        final id = originalId != null && originalId.isNotEmpty ? originalId : _uuid.v4();
        final keyId = _generateKeyId();
        nextLoginIdNumber++;
        final loginId = 'CSA-${nextLoginIdNumber.toString().padLeft(3, '0')}';
        final studentData = {
          'id': id,
          'name': name,
          'role': 'student',
          'key_id': keyId,
          'login_id': loginId,
        };
        validStudents.add(studentData);
        material.debugPrint('Prepared student for upload: $studentData');
      }
      if (validStudents.isEmpty) throw Exception('No valid student entries');
      await _client.from('users').insert(validStudents);
      material.debugPrint('Bulk added ${validStudents.length} students');
    } catch (e) {
      material.debugPrint('Error bulk uploading students: $e');
      throw Exception('Failed to bulk upload students: $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _client.from('users').delete().eq('id', id);
      material.debugPrint('Student deleted: $id');
    } catch (e) {
      material.debugPrint('Error deleting student: $e');
      throw Exception('Failed to delete student: $e');
    }
  }

  Future<void> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime dueDate,
    required String createdBy,
  }) async {
    try {
      material.debugPrint('Assigning task: $title to $assignedTo by $createdBy');
      if (createdBy != '00000000-0000-0000-0000-000000000000') {
        final response = await _client.from('users').select().eq('id', createdBy).maybeSingle();
        if (response == null) material.debugPrint('Warning: created_by user $createdBy not found');
      }
      await _client.from('tasks').insert({
        'title': title,
        'description': description,
        'assigned_to': assignedTo,
        'due_date': dueDate.toIso8601String(),
        'created_by': createdBy,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      material.debugPrint('Task assigned: $title to $assignedTo');
    } catch (e) {
      material.debugPrint('Error assigning task: $e');
      throw Exception('Failed to assign task: $e');
    }
  }

  Future<void> bulkAssignTasks(List<Map<String, String>> tasks) async {
    try {
      if (tasks.isEmpty) throw Exception('No task data provided');
      final validTasks = <Map<String, dynamic>>[];
      for (var task in tasks) {
        final title = task['title']?.trim();
        final description = task['description']?.trim();
        final assignedTo = task['assigned_to']?.trim();
        if (title == null || title.isEmpty || assignedTo == null || assignedTo.isEmpty) {
          material.debugPrint('Skipping invalid task entry: missing title or assigned_to');
          continue;
        }
        final dueDateStr = task['due_date']?.trim();
        final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : DateTime.now().add(const Duration(days: 7));
        validTasks.add({
          'title': title,
          'description': description ?? '',
          'assigned_to': assignedTo,
          'due_date': dueDate?.toIso8601String(),
          'created_by': '00000000-0000-0000-0000-000000000000',
          'status': 'pending',
        });
      }
      if (validTasks.isEmpty) throw Exception('No valid task entries');
      await _client.from('tasks').insert(validTasks);
      material.debugPrint('Bulk assigned ${validTasks.length} tasks');
    } catch (e) {
      material.debugPrint('Error bulk assigning tasks: $e');
      throw Exception('Failed to bulk assign tasks: $e');
    }
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String assignedTo,
    required DateTime dueDate,
  }) async {
    try {
      await _client.from('tasks').update({
        'title': title,
        'description': description,
        'assigned_to': assignedTo,
        'due_date': dueDate.toIso8601String(),
      }).eq('id', taskId);
      material.debugPrint('Task updated: $taskId');
    } catch (e) {
      material.debugPrint('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      material.debugPrint('Fetching task with ID: $taskId');
      final task = await _client.from('tasks').select().eq('id', taskId).maybeSingle();
      if (task == null) {
        material.debugPrint('Task not found: $taskId');
        throw Exception('Task with ID $taskId not found');
      }
      final oldStatus = task['status'].toString();
      material.debugPrint('Updating task status for taskId: $taskId from $oldStatus to $status');
      await _client.from('tasks').update({'status': status}).eq('id', taskId);
      material.debugPrint('Task status updated: $taskId to $status');
      if (status == 'completed' && oldStatus != 'completed') {
        await sendAdminNotification(
          task['assigned_to'].toString(),
          'Task "${task['title']}" completed',
          'task_completed',
        );
      }
    } catch (e) {
      material.debugPrint('Error updating task status for taskId $taskId: $e');
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> updateTaskFeedback(String taskId, String feedbackCategory, String? comments) async {
    try {
      const validCategories = {'Excellent', 'Good', 'Normal', 'Poor', 'Bad'};
      if (!validCategories.contains(feedbackCategory)) {
        throw Exception('Invalid feedback category: $feedbackCategory');
      }
      await _client.from('tasks').update({
        'feedback_category': feedbackCategory,
        'feedback_comments': comments,
      }).eq('id', taskId);
      material.debugPrint('Task feedback updated: $taskId with category $feedbackCategory');
      final task = await _client.from('tasks').select().eq('id', taskId).single();
      await sendAdminNotification(
        task['assigned_to'].toString(),
        'Feedback provided for task "${task['title']}"',
        'feedback_provided',
      );
    } catch (e) {
      material.debugPrint('Error updating task feedback: $e');
      throw Exception('Failed to update task feedback: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
      material.debugPrint('Task deleted: $taskId');
    } catch (e) {
      material.debugPrint('Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final response = await _client.from('tasks').select();
      material.debugPrint('Fetched tasks: ${response.length}');
      return response.map((data) => Task.fromJson(data)).toList();
    } catch (e) {
      material.debugPrint('Error fetching tasks: $e');
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<List<Task>> getTasksForStudent(String studentId) async {
    try {
      final response = await _client.from('tasks').select().eq('assigned_to', studentId);
      material.debugPrint('Fetched tasks for student $studentId: ${response.length}');
      return response.map((data) => Task.fromJson(data)).toList();
    } catch (e) {
      material.debugPrint('Error fetching tasks for student: $e');
      throw Exception('Failed to fetch tasks for student: $e');
    }
  }

  Future<List<Notification>> getNotifications(String userId) async {
    try {
      final response = await _client.from('notifications').select().eq('recipient_id', userId).order('created_at', ascending: false);
      material.debugPrint('Fetched notifications for $userId: ${response.length}');
      return response.map((data) => Notification.fromJson(data)).toList();
    } catch (e) {
      material.debugPrint('Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> sendAdminNotification(String userId, String message, String type) async {
    try {
      material.debugPrint('Sending admin notification for userId: $userId');
      await _client.from('notifications').insert({
        'recipient_id': userId,
        'message': message,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });
      final notifications = await getNotifications(userId);
      _notificationSubject.add(notifications);
      material.debugPrint('Notification sent to $userId: $message');
    } catch (e) {
      material.debugPrint('Error sending admin notification: $e');
      throw Exception('Failed to send admin notification: $e');
    }
  }

  void subscribeToTasks(Function(List<Task>) onUpdate) {
    try {
      final channel = _client.channel('public:tasks');
      channel
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tasks',
        callback: (payload) {
          material.debugPrint('Task update received: ${payload.newRecord}');
          getTasks().then((tasks) => onUpdate(tasks)).catchError((e) {
            material.debugPrint('Error in subscription callback: $e');
          });
        },
      )
          .subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          material.debugPrint('Subscribed to tasks channel');
        } else if (error != null) {
          material.debugPrint('Subscription error: $error');
        }
      });
    } catch (e) {
      material.debugPrint('Error subscribing to tasks: $e');
      throw Exception('Failed to subscribe to tasks: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final students = await getStudents();
      final tasks = await getTasks();
      final today = DateTime.now();
      final tasksToday = tasks
          .where((task) =>
      task.createdAt.day == today.day &&
          task.createdAt.month == today.month &&
          task.createdAt.year == today.year)
          .length;
      final pendingTasks = tasks.where((task) => task.status == 'pending').length;
      final completedTasks = tasks.where((task) => task.status == 'completed').length;

      return {
        'total_students': students.length,
        'tasks_today': tasksToday,
        'pending_tasks': pendingTasks,
        'completed_tasks': completedTasks,
      };
    } catch (e) {
      material.debugPrint('Error fetching dashboard stats: $e');
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentPerformance() async {
    try {
      final students = await getStudents();
      material.debugPrint('Processing performance for ${students.length} students');
      final List<Map<String, dynamic>> performance = [];
      for (var student in students) {
        final tasks = await getTasksForStudent(student.id);
        final completedTasks = tasks.where((task) => task.status == 'completed').toList();
        final totalTasks = tasks.length;
        final completedCount = completedTasks.length;
        final performanceScore = totalTasks > 0 ? (completedCount / totalTasks) * 100 : 0.0;
        performance.add({
          'student_id': student.id,
          'name': student.name,
          'completed_tasks': completedCount,
          'total_tasks': totalTasks,
          'performance_score': performanceScore,
        });
        material.debugPrint(
            'Student ${student.name} (ID: ${student.id}): $completedCount/$totalTasks tasks completed, $performanceScore% performance score');
      }
      return performance..sort((a, b) => b['performance_score'].compareTo(a['performance_score']));
    } catch (e) {
      material.debugPrint('Error fetching student performance: $e');
      throw Exception('Failed to fetch student performance: $e');
    }
  }

  // New public method for admin login
  Future<bool> loginAdmin(String email, String password) async {
    try {
      material.debugPrint('Attempting admin login for email: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        material.debugPrint('Admin login successful for email: $email');
        return true;
      } else {
        material.debugPrint('Admin login failed for email: $email');
        return false;
      }
    } catch (e) {
      material.debugPrint('Error during admin login: $e');
      return false;
    }
  }
}