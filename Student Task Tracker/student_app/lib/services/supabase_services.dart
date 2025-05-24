import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as local_user;
import '../models/task.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Validates a student using either key_id or original_id (UUID) for login
  Future<local_user.User?> validateStudentId(String id) async {
    try {
      final bool isUuid = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(id);

      final response = await _client
          .from('users')
          .select()
          .eq(isUuid ? 'id' : 'key_id', id)
          .eq('role', 'student')
          .maybeSingle();

      if (response == null) {
        debugPrint('No student found with ${isUuid ? 'ID' : 'Key ID'}: $id');
        return null;
      }

      final user = local_user.User.fromJson(response);
      debugPrint('Student validated with ${isUuid ? 'ID' : 'Key ID'}: ${user.name}');
      return user;
    } catch (e) {
      final bool isUuid = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(id);
      debugPrint('Error validating student with ${isUuid ? 'ID' : 'Key ID'}: $e');
      throw Exception('Failed to validate student with ${isUuid ? 'ID' : 'Key ID'}: $e');
    }
  }

  /// Fetches tasks assigned to a student
  Future<List<Task>> getTasksForStudent(String studentId) async {
    try {
      final response = await _client.from('tasks').select().eq('assigned_to', studentId);
      debugPrint('Fetched tasks for student $studentId: ${response.length} tasks');
      return (response as List<dynamic>)
          .map((data) => Task.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching tasks for student: $e');
      throw Exception('Failed to fetch tasks for student: $e');
    }
  }

  /// Updates the status of a task
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _client.from('tasks').update({'status': status}).eq('id', taskId);
      debugPrint('Task $taskId updated to status: $status');
    } catch (e) {
      debugPrint('Error updating task status: $e');
      throw Exception('Failed to update task status: $e');
    }
  }

  /// Sends a notification to the admin
  ///
  /// Make sure the 'notifications' table uses 'recipient_id' and NOT 'student_id'
  Future<void> sendAdminNotification(
      String studentId, String message, String type) async {
    try {
      await _client.from('notifications').insert({
        'recipient_id': studentId,
        'message': message,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Admin notification sent: $message');
    } catch (e) {
      debugPrint('Error sending admin notification: $e');
      throw Exception('Failed to send admin notification: $e');
    }
  }

  /// Subscribes to real-time task updates
  void subscribeToTasks(Function(List<Task>) onUpdate) {
    try {
      final channel = _client.channel('public:tasks');
      channel
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tasks',
        callback: (PostgresChangePayload payload) {
          debugPrint('Received task update: ${payload.newRecord}');
          _client
              .from('tasks')
              .select()
              .then((response) => (response as List<dynamic>)
              .map((data) => Task.fromJson(data))
              .toList())
              .then(onUpdate);
        },
      )
          .subscribe();
    } catch (e) {
      debugPrint('Error subscribing to tasks: $e');
      throw Exception('Failed to subscribe to tasks: $e');
    }
  }
}
