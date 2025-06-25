import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'supabase_config.dart';

class StudentDashboard extends StatelessWidget {
  final AppUser student;
  const StudentDashboard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Student Dashboard', style: TextStyle(color: Colors.white)),
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
                'Welcome, ${student.username}!',
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
                      icon: Icons.edit_document,
                      title: 'Raise a Complaint',
                      subtitle: 'Submit a new complaint to HOD or Batch Advisor',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StudentRaiseComplaintPage(student: student)));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardOption(
                      context: context,
                      icon: Icons.list_alt,
                      title: 'View My Complaints',
                      subtitle: 'Check the status of your complaints',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewStudentComplaintsPage(student: student)));
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

class StudentRaiseComplaintPage extends StatefulWidget {
  final AppUser student;
  const StudentRaiseComplaintPage({super.key, required this.student});

  @override
  State<StudentRaiseComplaintPage> createState() => _StudentRaiseComplaintPageState();
}

class _StudentRaiseComplaintPageState extends State<StudentRaiseComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  
  String _selectedRecipientType = 'BatchAdvisor';
  AppUser? _selectedRecipient;
  bool _isAnonymous = false;
  XFile? _selectedImage;
  
  bool _isRecipientsLoading = false;
  bool _isSubmitting = false;
  List<AppUser> _recipients = [];

  @override
  void initState() {
    super.initState();
    _loadRecipients();
  }

  Future<void> _loadRecipients() async {
    setState(() {
      _isRecipientsLoading = true;
      _recipients = [];
      _selectedRecipient = null;
    });
    try {
      final recipients = await UserService.getUsersByRole(_selectedRecipientType);
      if (!mounted) return;
      setState(() {
        _recipients = recipients;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load recipients: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (!mounted) return;
      setState(() {
        _isRecipientsLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRecipient == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a recipient.'),
          backgroundColor: Colors.orangeAccent,
        ));
        return;
      }

      setState(() { _isSubmitting = true; });

      try {
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await ComplaintService.uploadImage(_selectedImage!);
        }

        await ComplaintService.addComplaint(
          studentId: widget.student.id,
          recipientId: _selectedRecipient!.id,
          complaintText: _complaintController.text.trim(),
          isAnonymous: _isAnonymous,
          imageUrl: imageUrl,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Complaint submitted successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit complaint: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        if (!mounted) return;
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Raise a Complaint', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('1. Who is this complaint for?'),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment<String>(value: 'BatchAdvisor', label: Text('Batch Advisor'), icon: Icon(Icons.person)),
                            ButtonSegment<String>(value: 'HOD', label: Text('HOD'), icon: Icon(Icons.school)),
                          ],
                          selected: {_selectedRecipientType},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedRecipientType = newSelection.first;
                              _selectedRecipient = null;
                            });
                            _loadRecipients();
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('2. Select the recipient'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<AppUser>(
                          value: _selectedRecipient,
                          isExpanded: true,
                          decoration: _buildInputDecoration(
                            labelText: 'Select Recipient',
                            icon: Icons.person_search,
                          ),
                          items: _recipients.map((AppUser user) {
                            return DropdownMenuItem<AppUser>(
                              value: user,
                              child: Text(user.username),
                            );
                          }).toList(),
                          onChanged: (AppUser? newValue) {
                            setState(() {
                              _selectedRecipient = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a recipient' : null,
                          hint: _isRecipientsLoading ? const Text('Loading...') : const Text('Select a recipient'),
                        ),
                        const SizedBox(height: 20),
                         _buildSectionTitle('3. Write your complaint'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _complaintController,
                          maxLines: 5,
                          decoration: _buildInputDecoration(
                            labelText: 'Please describe your issue...',
                            icon: Icons.edit_note,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your complaint';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('4. Attach an image (Optional)'),
                        const SizedBox(height: 16),
                        if (_selectedImage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_selectedImage!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.attach_file),
                          label: Text(_selectedImage == null ? 'Select Image' : 'Change Image'),
                           style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D1B2A),
                              side: const BorderSide(color: Color(0xFF0D1B2A)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12)
                            ),
                        ),
                        const SizedBox(height: 20),
                        CheckboxListTile(
                          title: const Text('Send Anonymously', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                          subtitle: const Text('If checked, the recipient will not see your name.'),
                          value: _isAnonymous,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAnonymous = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF0D1B2A),
                          tileColor: const Color(0xFFFFF0F5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                              : const Text('Submit Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D1B2A),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF666666)),
      prefixIcon: Icon(icon, color: const Color(0xFF0D1B2A)),
      filled: true,
      fillColor: const Color(0xFFFFF0F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B2A), width: 2),
      ),
    );
  }
}

class ViewStudentComplaintsPage extends StatefulWidget {
  final AppUser student;
  const ViewStudentComplaintsPage({super.key, required this.student});

  @override
  State<ViewStudentComplaintsPage> createState() => _ViewStudentComplaintsPageState();
}

class _ViewStudentComplaintsPageState extends State<ViewStudentComplaintsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  String _selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() { _isLoading = true; });
    try {
      final complaints = await ComplaintService.getComplaintsByStudentWithComments(widget.student.id);
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
        _applyFilter();
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

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredComplaints = List.from(_complaints);
    } else {
      _filteredComplaints = _complaints.where((complaint) {
        final status = complaint['status'] ?? 'N/A';
        return status == _selectedFilter;
      }).toList();
    }
  }

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null) {
      setState(() {
        _selectedFilter = newFilter;
        _applyFilter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('My Complaints', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter by:',
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
                          value: _selectedFilter,
                          isExpanded: true,
                          dropdownColor: const Color(0xFFFFFFFF),
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Complaints')),
                            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                            DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                          ],
                          onChanged: _onFilterChanged,
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
    
    if (_selectedFilter == 'All') {
      message = 'No Complaints Found';
      subtitle = 'You haven\'t raised any complaints yet.';
    } else {
      message = 'No ${_selectedFilter} Complaints';
      subtitle = 'You don\'t have any ${_selectedFilter.toLowerCase()} complaints.';
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
          if (_selectedFilter != 'All' && _complaints.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _onFilterChanged('All'),
              icon: const Icon(Icons.clear_all),
              label: const Text('View All Complaints'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
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
          final recipient = complaint['recipient'] ?? {'username': 'N/A', 'role': 'N/A'};
          final status = complaint['status'] ?? 'N/A';
          final createdAt = DateTime.parse(complaint['created_at']);
          
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
                      Text(
                        'To: ${recipient['username']} (${recipient['role']})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    complaint['complaint_text'],
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  if (complaint['image_url'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          complaint['image_url'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null ? child : const Center(child: CircularProgressIndicator());
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
                      final isStudentComment = comment['teacher_id'] == widget.student.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isStudentComment ? const Color(0xFFFFF0F5) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isStudentComment ? const Color(0xFF0D1B2A) : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isStudentComment ? Icons.person : Icons.school,
                                  size: 16,
                                  color: isStudentComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isStudentComment ? 'You' : 'Recipient',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isStudentComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('d MMM, h:mm a').format(DateTime.parse(comment['created_at'])),
                                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment['comment_text'],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
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
                      if (complaint['complaint_comments'] != null && (complaint['complaint_comments'] as List).isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _showReplyDialog(complaint),
                          icon: const Icon(Icons.reply, size: 16),
                          label: const Text('Reply'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D1B2A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                    ],
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

  void _showReplyDialog(Map<String, dynamic> complaint) {
    final replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reply'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your reply...',
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
              if (replyController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                try {
                  await ComplaintService.addComment(
                    complaintId: complaint['id'],
                    studentId: widget.student.id,
                    commentText: replyController.text.trim(),
                  );
                  await _loadComplaints();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Reply added successfully'),
                    backgroundColor: Colors.green,
                  ));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to add reply: $e'),
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
} 