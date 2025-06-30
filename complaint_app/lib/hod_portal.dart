import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'supabase_config.dart';
import 'admin_screens.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'supabase_config.dart';
import 'utils/save_file.dart';

final _client = SupabaseConfig.client;

class HODPortal extends StatefulWidget {
  final AppUser hod;
  const HODPortal({super.key, required this.hod});

  @override
  State<HODPortal> createState() => _HODPortalState();
}

class _HODPortalState extends State<HODPortal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        elevation: 0,
        title: const Text('HOD Portal', style: TextStyle(color: Color(0xFFEAEFEF))),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(
              Icons.logout,
              color: Color(0xFFEAEFEF),
              size: 28,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Welcome Message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Text(
                'Welcome, ${widget.hod.username}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52357B),
                  shadows: [
                    Shadow(
                      color: Colors.pink,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Options Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDashboardOption(
                      context: context,
                      icon: Icons.rate_review,
                      title: 'Review Student Complaints',
                      subtitle: 'Review complaints from students',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HODReviewComplaintsPage(
                          hod: widget.hod,
                          complaintType: 'student',
                          title: 'Student Complaints',
                        )));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardOption(
                      context: context,
                      icon: Icons.rate_review,
                      title: 'Review Batch Advisor Complaints',
                      subtitle: 'Review complaints from batch advisors',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HODReviewComplaintsPage(
                          hod: widget.hod,
                          complaintType: 'batch_advisor',
                          title: 'Batch Advisor Complaints',
                        )));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardOption(
                      context: context,
                      icon: Icons.visibility_off,
                      title: 'Review Anonymous Complaints',
                      subtitle: 'Review anonymous complaints from both',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HODReviewComplaintsPage(
                          hod: widget.hod,
                          complaintType: 'anonymous',
                          title: 'Anonymous Complaints',
                        )));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardOption(
                      context: context,
                      icon: Icons.people,
                      title: 'Manage Batch Advisors',
                      subtitle: 'Create, assign, and manage batch advisors',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HODBatchAdvisorManagementScreen(hod: widget.hod)));
                      },
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

  Widget _buildDashboardOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF52357B),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class HODReviewComplaintsPage extends StatefulWidget {
  final AppUser hod;
  final String complaintType;
  final String title;

  const HODReviewComplaintsPage({
    super.key,
    required this.hod,
    required this.complaintType,
    required this.title,
  });

  @override
  State<HODReviewComplaintsPage> createState() => _HODReviewComplaintsPageState();
}

class _HODReviewComplaintsPageState extends State<HODReviewComplaintsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  String _selectedTimeFilter = 'All Time';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() { _isLoading = true; });
    try {
      List<Map<String, dynamic>> complaints = [];
      
      print('Loading complaints for HOD ${widget.hod.id}, type: ${widget.complaintType}');
      
      if (widget.complaintType == 'anonymous') {
        complaints = await ComplaintService.getAnonymousComplaintsForHOD(widget.hod.id);
      } else {
        // For student and batch advisor complaints, get all non-anonymous complaints
        complaints = await ComplaintService.getComplaintsForHOD(widget.hod.id, widget.complaintType);
      }
      
      print('Loaded ${complaints.length} complaints for ${widget.complaintType}');
      
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
        _applyTimeFilter();
      });
    } catch (e) {
      print('Error loading complaints: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load complaints: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (!mounted) return;
      setState(() { _isLoading = false; });
    }
  }

  void _applyTimeFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    _filteredComplaints = _complaints.where((complaint) {
      final createdAt = DateTime.tryParse(complaint['created_at'] ?? '') ?? DateTime.now();
      
      switch (_selectedTimeFilter) {
        case 'Today':
          return createdAt.isAfter(today);
        case 'Yesterday':
          return createdAt.isAfter(yesterday) && createdAt.isBefore(today);
        case 'This Week':
          return createdAt.isAfter(thisWeek);
        case 'This Month':
          return createdAt.isAfter(thisMonth);
        default:
          return true; // All Time
      }
    }).toList();
  }

  void _onTimeFilterChanged(String? newFilter) {
    if (newFilter != null) {
      setState(() {
        _selectedTimeFilter = newFilter;
        _applyTimeFilter();
      });
    }
  }

  Future<void> _updateComplaintStatus(String complaintId, String status) async {
    try {
      await ComplaintService.updateComplaintStatus(complaintId, status);
      await _loadComplaints();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint marked as $status'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Error updating status: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showCommentDialog(Map<String, dynamic> complaint) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                try {
                  await ComplaintService.addComment(
                    complaintId: complaint['id'],
                    hodId: widget.hod.id,
                    commentText: commentController.text.trim(),
                  );
                  await _loadComplaints();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Comment added successfully'),
                    backgroundColor: Colors.green,
                  ));
                } catch (e) {
                  print('Error adding comment: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to add comment: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Color(0xFFEAEFEF))),
        actions: [
          IconButton(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh, color: Color(0xFFEAEFEF), size: 24),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Time:',
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTimeFilter,
                            isExpanded: true,
                            dropdownColor: const Color(0xFFFFFFFF),
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            items: const [
                              DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                              DropdownMenuItem(value: 'Today', child: Text('Today')),
                              DropdownMenuItem(value: 'Yesterday', child: Text('Yesterday')),
                              DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                              DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                            ],
                            onChanged: _onTimeFilterChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!_isLoading && _complaints.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_filteredComplaints.length} of ${_complaints.length} complaints',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_filteredComplaints.isEmpty)
                _buildEmptyState()
              else
                ..._filteredComplaints.map((complaint) => _buildComplaintCard(complaint)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    
    if (_selectedTimeFilter == 'All Time') {
      message = 'No Complaints Found';
      subtitle = 'No complaints found for this category.';
    } else {
      message = 'No ${_selectedTimeFilter} Complaints';
      subtitle = 'No complaints found for the selected time period.';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Color(0xFF999999)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final status = complaint['status'] ?? 'Pending';
    final createdAt = DateTime.tryParse(complaint['created_at'] ?? '') ?? DateTime.now();
    final isAnonymous = complaint['is_anonymous'] ?? false;
    final sender = complaint['sender'];
    final imageUrl = complaint['image_url'];
    final comments = complaint['complaint_comments'] ?? [];
    
    Color statusColor;
    switch (status) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'In Progress':
        statusColor = Colors.purple;
        break;
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnonymous ? 'Anonymous Complaint' : (sender?['username'] ?? 'Unknown User'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF52357B),
                        ),
                      ),
                      if (!isAnonymous && sender != null)
                        Text(
                          'Role: ${sender['role'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint['complaint_text'] ?? 'No complaint text',
              style: const TextStyle(fontSize: 16),
            ),
            if (imageUrl != null && imageUrl.toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(createdAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Comments (${comments.length}):',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52357B),
                ),
              ),
              const SizedBox(height: 8),
              ...comments.map((comment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['comment_text'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.tryParse(comment['created_at'] ?? '') ?? DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCommentDialog(complaint),
                    icon: const Icon(Icons.comment),
                    label: const Text('Add Comment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52357B),
                      foregroundColor: const Color(0xFFEAEFEF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (status) => _updateComplaintStatus(complaint['id'], status),
                  icon: const Icon(Icons.more_vert, color: Color(0xFF52357B)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Pending', child: Text('Mark Pending')),
                    const PopupMenuItem(value: 'In Progress', child: Text('Mark In Progress')),
                    const PopupMenuItem(value: 'Resolved', child: Text('Mark Resolved')),
                    const PopupMenuItem(value: 'Rejected', child: Text('Mark Rejected')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HODBatchAdvisorManagementScreen extends StatefulWidget {
  final AppUser hod;
  const HODBatchAdvisorManagementScreen({super.key, required this.hod});

  @override
  State<HODBatchAdvisorManagementScreen> createState() => _HODBatchAdvisorManagementScreenState();
}

class _HODBatchAdvisorManagementScreenState extends State<HODBatchAdvisorManagementScreen> {
  List<Map<String, dynamic>> _batches = [];
  List<AppUser> _batchAdvisors = [];
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreating = false;

  String? _lastExportedBatchAdvisorsFilePath;

  @override
  void initState() {
    super.initState();
    _loadBatches();
    _loadBatchAdvisors();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await _client
          .from('batches')
          .select('*, department:department_id(name, code), batch_advisor:batch_advisor_id(username, id)')
          .order('name', ascending: true);
      setState(() {
        _batches = List<Map<String, dynamic>>.from(batches);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading batches: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batches: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadBatchAdvisors() async {
    try {
      final advisors = await UserService.getUsersByRole('BatchAdvisor');
      setState(() => _batchAdvisors = advisors);
    } catch (e) {
      print('Error loading batch advisors: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batch advisors: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createBatchAdvisor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);
    try {
      await UserService.addUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        'BatchAdvisor',
      );
      _formKey.currentState!.reset();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      await _loadBatchAdvisors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch Advisor created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Error creating batch advisor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create Batch Advisor: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _showAssignAdvisorDialog(Map<String, dynamic> batch) {
    AppUser? selectedAdvisor = batch['batch_advisor'] != null
        ? AppUser(
      id: batch['batch_advisor']['id'],
      username: batch['batch_advisor']['username'],
      password: '',
      role: 'BatchAdvisor',
      createdAt: DateTime.now(),
    )
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Advisor to ${batch['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Department: ${batch['department']['name']}'),
              Text('Academic Year: ${batch['academic_year']}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppUser>(
                value: selectedAdvisor,
                decoration: const InputDecoration(labelText: 'Select Batch Advisor'),
                items: [
                  const DropdownMenuItem<AppUser>(
                    value: null,
                    child: Text('No Advisor'),
                  ),
                  ..._batchAdvisors.map((advisor) => DropdownMenuItem(
                    value: advisor,
                    child: Text(advisor.username),
                  )),
                ],
                onChanged: (advisor) => setDialogState(() => selectedAdvisor = advisor),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _client.from('batches').update({
                    'batch_advisor_id': selectedAdvisor?.id,
                  }).eq('id', batch['id']);
                  Navigator.pop(context);
                  _loadBatches();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(selectedAdvisor != null
                            ? 'Advisor assigned successfully!'
                            : 'Advisor removed successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error assigning advisor: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to assign advisor: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBatchAdvisors() async {
    setState(() { _isLoading = true; });
    try {
      final advisors = await _client.from('users').select('username, password').eq('role', 'BatchAdvisor');
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['BatchAdvisors'];
      sheet.appendRow(['Username/Email', 'Password', 'Role']);
      for (var a in advisors) {
        sheet.appendRow([
          a['username'] ?? '',
          a['password'] ?? '',
          'BatchAdvisor',
        ]);
      }
      final bytes = excelFile.encode();
      if (kIsWeb) {
        saveFileWeb(Uint8List.fromList(bytes!), 'batch_advisors_export.xlsx');
        setState(() { _lastExportedBatchAdvisorsFilePath = null; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/batch_advisors_export.xlsx');
        await file.writeAsBytes(bytes!);
        setState(() { _lastExportedBatchAdvisorsFilePath = file.path; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Batch Advisors exported: ${file.path}'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print('Error exporting batch advisors: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Advisors'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        actions: [
          IconButton(
            onPressed: () {
              _loadBatches();
              _loadBatchAdvisors();
            },
            icon: const Icon(Icons.refresh, color: Color(0xFFEAEFEF)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create New Batch Advisor',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username/Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCreating ? null : _createBatchAdvisor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF52357B),
                              foregroundColor: const Color(0xFFEAEFEF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEAEFEF))),
                            )
                                : const Text('Create Batch Advisor'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Assign Advisors to Batches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._batches.map((batch) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(batch['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Department: ${batch['department']['name']} (${batch['department']['code']})'),
                      Text('Academic Year: ${batch['academic_year']}'),
                      if (batch['batch_advisor'] != null)
                        Text('Current Advisor: ${batch['batch_advisor']['username']}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      else
                        const Text('No Advisor Assigned',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: batch['batch_advisor'] == null
                      ? ElevatedButton(
                    onPressed: () => _showAssignAdvisorDialog(batch),
                    child: const Text('Assign'),
                  )
                      : null,
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _exportBatchAdvisors,
                icon: const Icon(Icons.download),
                label: const Text('Export Batch Advisors'),
              ),
              if (_lastExportedBatchAdvisorsFilePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await OpenFile.open(_lastExportedBatchAdvisorsFilePath!);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Exported File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
