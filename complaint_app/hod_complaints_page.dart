import 'package:flutter/material.dart';
import 'supabase_config.dart';

class HODComplaintsPage extends StatefulWidget {
  final AppUser hod;
  final String complaintType; // 'student', 'batch_advisor', 'anonymous'
  const HODComplaintsPage({super.key, required this.hod, required this.complaintType});

  @override
  State<HODComplaintsPage> createState() => _HODComplaintsPageState();
}

class _HODComplaintsPageState extends State<HODComplaintsPage> {
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> complaints = await SupabaseConfig.client
          .from('complaints')
          .select('*, student:student_tracking_id(username, role), image_url, status, complaint_text, is_anonymous')
          .eq('recipient_id', widget.hod.id)
          .order('created_at', ascending: false);

      // Filter by type
      if (widget.complaintType == 'student') {
        complaints = complaints.where((c) {
          final role = c['student']?['role']?.toString()?.toLowerCase();
          return role == 'student' || role == 'cr' || role == 'gr';
        }).toList();
      } else if (widget.complaintType == 'batch_advisor') {
        complaints = complaints.where((c) {
          final role = c['student']?['role']?.toString()?.toLowerCase();
          return role == 'batchadvisor';
        }).toList();
      } else if (widget.complaintType == 'anonymous') {
        complaints = complaints.where((c) => c['is_anonymous'] == true).toList();
      }

      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    if (widget.complaintType == 'student') {
      title = 'Student Complaints';
    } else if (widget.complaintType == 'batch_advisor') {
      title = 'Batch Advisor Complaints';
    } else if (widget.complaintType == 'anonymous') {
      title = 'Anonymous Complaints';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? Center(child: Text('No complaints found.'))
              : ListView.builder(
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint['complaint_text'] ?? 'No text',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            if (complaint['image_url'] != null && complaint['image_url'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  complaint['image_url'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text('Image not available'),
                                ),
                              ),
                            SizedBox(height: 8),
                            Text('Status: ${complaint['status'] ?? ''}'),
                            Text('From: ${complaint['student']?['username'] ?? 'Unknown'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 
