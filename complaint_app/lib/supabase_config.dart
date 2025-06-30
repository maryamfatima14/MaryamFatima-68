import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://lgggruciywrlbspvztyw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnZ2dydWNpeXdybGJzcHZ6dHl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExNDI4NTEsImV4cCI6MjA2NjcxODg1MX0.g9B-57WDyRJm_5OukdMgTb24mySwX9OyEQmMdJK3bOs';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

class AppUser {
  final String id;
  final String username;
  final String password;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class UserService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Add a new user
  static Future<void> addUser(String username, String password, String role) async {
    try {
      await _client.from('users').insert({
        'username': username,
        'password': password,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  // Get all users
  static Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await _client.from('users').select().order('created_at', ascending: false);
      return (response as List).map((user) => AppUser.fromMap(user)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Get users by role
  static Future<List<AppUser>> getUsersByRole(String role) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('role', role)
          .order('created_at', ascending: false);
      return (response as List).map((user) => AppUser.fromMap(user)).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  // Delete user
  static Future<void> deleteUser(String userId) async {
    try {
      await _client.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Update user password
  static Future<void> updatePassword(String userId, String newPassword) async {
    try {
      await _client.from('users').update({
        'password': newPassword,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Check if user exists for login
  static Future<AppUser?> authenticateUser(String username, String password, String role) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .eq('role', role)
          .single();
      return AppUser.fromMap(response);
    } catch (e) {
      return null; // User not found or authentication failed
    }
  }
}

class ComplaintService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Uploads an image file to Supabase Storage and returns the public URL.
  static Future<String> uploadImage(XFile image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final fileBytes = await image.readAsBytes();

      await _client.storage.from('complaint-images').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: FileOptions(
              contentType: image.mimeType ?? 'image/$fileExt',
            ),
          );
      
      final imageUrl = _client.storage
          .from('complaint-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Adds a new complaint to the database.
  static Future<void> addComplaint({
    required String studentId,
    required String recipientId,
    required String complaintText,
    required bool isAnonymous,
    String? imageUrl,
  }) async {
    try {
      final complaintData = {
        'student_id': isAnonymous ? null : studentId, // null for anonymous, student ID for non-anonymous
        'student_tracking_id': studentId, // Always store student ID for tracking
        'recipient_id': recipientId,
        'complaint_text': complaintText,
        'is_anonymous': isAnonymous,
        'image_url': imageUrl,
        'status': 'Pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _client.from('complaints').insert(complaintData);
    } catch (e) {
      throw Exception('Failed to add complaint: $e');
    }
  }

  /// Fetches all complaints raised by a specific student.
  static Future<List<Map<String, dynamic>>> getComplaintsByStudent(String studentId) async {
    try {
      // Get complaints using student_tracking_id (new method)
      final newComplaints = await _client
          .from('complaints')
          .select('*, recipient:recipient_id(username, role)')
          .eq('student_tracking_id', studentId)
          .order('created_at', ascending: false);
      
      // Get complaints using student_id (old method for backward compatibility)
      final oldComplaints = await _client
          .from('complaints')
          .select('*, recipient:recipient_id(username, role)')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      
      // Combine and remove duplicates
      final allComplaints = <Map<String, dynamic>>[];
      final seenIds = <String>{};
      
      // Add new complaints first
      for (final complaint in newComplaints) {
        final id = complaint['id'] as String;
        if (!seenIds.contains(id)) {
          allComplaints.add(complaint);
          seenIds.add(id);
        }
      }
      
      // Add old complaints that aren't already included
      for (final complaint in oldComplaints) {
        final id = complaint['id'] as String;
        if (!seenIds.contains(id)) {
          allComplaints.add(complaint);
          seenIds.add(id);
        }
      }
      
      // Sort by creation date (newest first)
      allComplaints.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
      
      return allComplaints;
    } catch (e) {
      throw Exception('Failed to get complaints: $e');
    }
  }

  /// Fetches all complaints sent to a specific teacher.
  static Future<List<Map<String, dynamic>>> getComplaintsForTeacher(String teacherId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, student:student_tracking_id(username, role), complaint_comments(*)')
          .eq('recipient_id', teacherId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get complaints for teacher: $e');
    }
  }

  /// Fetches all complaints sent to a specific batch advisor.
  static Future<List<Map<String, dynamic>>> getComplaintsForBatchAdvisor(String batchAdvisorId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, student:student_tracking_id(username, role), complaint_comments(*)')
          .eq('recipient_id', batchAdvisorId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get complaints for batch advisor: $e');
    }
  }

  /// Updates the status of a complaint.
  static Future<void> updateComplaintStatus(String complaintId, String status) async {
    try {
      await _client
          .from('complaints')
          .update({'status': status})
          .eq('id', complaintId);
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  /// Adds a comment to a complaint.
  static Future<void> addComment({
    required String complaintId,
    String? teacherId,
    String? batchAdvisorId,
    String? hodId,
    String? studentId,
    required String commentText,
  }) async {
    try {
      final commentData = {
        'complaint_id': complaintId,
        'comment_text': commentText,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      if (teacherId != null) {
        commentData['teacher_id'] = teacherId;
      }
      
      if (batchAdvisorId != null) {
        commentData['batch_advisor_id'] = batchAdvisorId;
      }
      
      if (hodId != null) {
        commentData['hod_id'] = hodId;
      }
      
      if (studentId != null) {
        commentData['student_id'] = studentId;
      }
      
      await _client.from('complaint_comments').insert(commentData);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Fetches complaints sent to HOD by a specific role (Student or BatchAdvisor).
  static Future<List<Map<String, dynamic>>> getComplaintsForHOD(String hodId, String senderRole) async {
    try {
      // Get all complaints sent to this HOD with sender information
      final allComplaints = await _client
          .from('complaints')
          .select('*, sender:student_tracking_id(username, role), complaint_comments(*)')
          .eq('recipient_id', hodId)
          .eq('is_anonymous', false)
          .order('created_at', ascending: false);
      
      // Filter complaints based on sender role
      final filteredComplaints = allComplaints.where((complaint) {
        final sender = complaint['sender'];
        if (sender == null) return false;
        
        final role = sender['role']?.toString().toLowerCase();
        if (senderRole == 'student') {
          return role == 'student' || role == 'cr' || role == 'gr';
        } else if (senderRole == 'batch_advisor') {
          return role == 'batchadvisor' || role == 'batch_advisor';
        }
        return false;
      }).toList();
      
      print('HOD $hodId: Found ${allComplaints.length} total complaints, ${filteredComplaints.length} for role $senderRole');
      
      return List<Map<String, dynamic>>.from(filteredComplaints);
    } catch (e) {
      throw Exception('Failed to get complaints for HOD: $e');
    }
  }

  /// Fetches anonymous complaints sent to HOD.
  static Future<List<Map<String, dynamic>>> getAnonymousComplaintsForHOD(String hodId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, complaint_comments(*)')
          .eq('recipient_id', hodId)
          .eq('is_anonymous', true)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get anonymous complaints for HOD: $e');
    }
  }

  /// Fetches all complaints raised by a specific student with comments.
  static Future<List<Map<String, dynamic>>> getComplaintsByStudentWithComments(String studentId) async {
    try {
      // Get complaints using student_tracking_id (new method)
      final newComplaints = await _client
          .from('complaints')
          .select('*, recipient:recipient_id(username, role), complaint_comments(*)')
          .eq('student_tracking_id', studentId)
          .order('created_at', ascending: false);
      
      // Get complaints using student_id (old method for backward compatibility)
      final oldComplaints = await _client
          .from('complaints')
          .select('*, recipient:recipient_id(username, role), complaint_comments(*)')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      
      // Combine and remove duplicates
      final allComplaints = <Map<String, dynamic>>[];
      final seenIds = <String>{};
      
      // Add new complaints first
      for (final complaint in newComplaints) {
        final id = complaint['id'] as String;
        if (!seenIds.contains(id)) {
          allComplaints.add(complaint);
          seenIds.add(id);
        }
      }
      
      // Add old complaints that aren't already included
      for (final complaint in oldComplaints) {
        final id = complaint['id'] as String;
        if (!seenIds.contains(id)) {
          allComplaints.add(complaint);
          seenIds.add(id);
        }
      }
      
      // Sort by creation date (newest first)
      allComplaints.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
      
      return allComplaints;
    } catch (e) {
      throw Exception('Failed to get complaints: $e');
    }
  }

  /// Fetches all complaints raised by a specific teacher with comments.
  static Future<List<Map<String, dynamic>>> getComplaintsByTeacherWithComments(String teacherId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, recipient:recipient_id(username, role), complaint_comments(*)')
          .eq('student_tracking_id', teacherId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get complaints by teacher: $e');
    }
  }

  /// Fetches all complaints raised by a specific batch advisor with comments.
  static Future<List<Map<String, dynamic>>> getComplaintsByBatchAdvisorWithComments(String batchAdvisorId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, recipient:recipient_id(username, role), complaint_comments(*)')
          .eq('student_tracking_id', batchAdvisorId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get complaints by batch advisor: $e');
    }
  }
} 
