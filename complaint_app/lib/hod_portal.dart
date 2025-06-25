import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'supabase_config.dart';

class HODPortal extends StatelessWidget {
  final AppUser hod;
  const HODPortal({super.key, required this.hod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('HOD Portal', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Welcome Message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Welcome, ${hod.username}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.pink.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 60),
            
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
                          hod: hod,
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
                          hod: hod,
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
                          hod: hod,
                          complaintType: 'anonymous',
                          title: 'Anonymous Complaints',
                        )));
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
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.95),
          foregroundColor: const Color(0xFF0D1B2A),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: Colors.pink.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
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
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class HODReviewComplaintsPage extends StatefulWidget {
  final AppUser hod;
  final String complaintType; // 'student', 'batch_advisor', or 'anonymous'
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
      List<Map<String, dynamic>> complaints;
      
      switch (widget.complaintType) {
        case 'student':
          complaints = await ComplaintService.getComplaintsForHOD(widget.hod.id, 'Student');
          break;
        case 'batch_advisor':
          complaints = await ComplaintService.getComplaintsForHOD(widget.hod.id, 'BatchAdvisor');
          break;
        case 'anonymous':
          complaints = await ComplaintService.getAnonymousComplaintsForHOD(widget.hod.id);
          break;
        default:
          complaints = [];
      }
      
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
        _applyTimeFilter();
      });
    } catch (e) {
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
      final createdAt = DateTime.parse(complaint['created_at']);
      
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
      await _loadComplaints(); // Reload complaints
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint marked as $status'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
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
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        actions: [
          IconButton(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Time Filter Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Time:',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
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
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
            // Complaint Count Indicator
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
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D1B2A))))
                    : _filteredComplaints.isEmpty
                        ? _buildEmptyState()
                        : _buildComplaintsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    
    if (_selectedTimeFilter == 'All Time') {
      message = 'No ${widget.title} Found';
      subtitle = 'No ${widget.complaintType} complaints have been sent to you yet.';
    } else {
      message = 'No Complaints in ${_selectedTimeFilter}';
      subtitle = 'No ${widget.complaintType} complaints found for the selected time period.';
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
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    return RefreshIndicator(
      onRefresh: _loadComplaints,
      color: const Color(0xFF0D1B2A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredComplaints.length,
        itemBuilder: (context, index) {
          final complaint = _filteredComplaints[index];
          final sender = complaint['sender'] ?? {'username': 'Anonymous', 'role': 'Unknown'};
          final status = complaint['status'] ?? 'N/A';
          final createdAt = DateTime.tryParse(complaint['created_at'] ?? '') ?? DateTime.now();
          final isAnonymous = complaint['is_anonymous'] ?? false;
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _getStatusColor(status)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From: ${isAnonymous ? 'Anonymous ${sender['role'] ?? 'Unknown'}' : (sender['username'] ?? 'Unknown')}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (!isAnonymous)
                              Text(
                                'Role: ${sender['role'] ?? 'Unknown'}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    complaint['complaint_text'] ?? 'No complaint text',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  if ((complaint['image_url'] ?? '') != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Image.network(
                              complaint['image_url'],
                              width: constraints.maxWidth,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null ? child : const Center(child: CircularProgressIndicator());
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  // Comments Section
                  if (complaint['complaint_comments'] != null && (complaint['complaint_comments'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const Text(
                      'Comments:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ...(complaint['complaint_comments'] as List).map<Widget>((comment) {
                      final isHODComment = comment['teacher_id'] == widget.hod.id;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isHODComment ? const Color(0xFF0D1B2A) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isHODComment ? const Color(0xFF0D1B2A) : Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isHODComment ? Icons.school : Icons.person,
                                      size: 16,
                                      color: isHODComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        isHODComment ? 'You (HOD)' : 'Sender',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isHODComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        DateFormat('d MMM, h:mm a').format(DateTime.tryParse(comment['created_at'] ?? '') ?? DateTime.now()),
                                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMM yyyy, h:mm a').format(createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (status == 'Pending') ...[
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _updateComplaintStatus(complaint['id'], 'Resolved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('Resolve', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateComplaintStatus(complaint['id'], 'Rejected'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('Reject', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCommentDialog(complaint),
                      icon: const Icon(Icons.comment, size: 16),
                      label: const Text('Add Comment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orangeAccent;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
} 