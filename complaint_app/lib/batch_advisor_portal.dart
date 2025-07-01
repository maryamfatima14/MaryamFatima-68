import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'supabase_config.dart';

class BatchAdvisorPortal extends StatelessWidget {
  final AppUser batchAdvisor;
  const BatchAdvisorPortal({super.key, required this.batchAdvisor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Batch Advisor Portal', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Welcome, ${batchAdvisor.username}!',
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
            
            const SizedBox(height: 20),
            
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
                      subtitle: 'Submit a complaint to HOD',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BatchAdvisorRaiseComplaintPage(batchAdvisor: batchAdvisor)));
                      },
                    ),
                    
                    const SizedBox(height: 20),

                    _buildDashboardOption(
                      context: context,
                      icon: Icons.list_alt,
                      title: 'View My Complaints',
                      subtitle: 'Check the status of your complaints',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BatchAdvisorViewComplaintsPage(batchAdvisor: batchAdvisor)));
                      },
                    ),
                    
                    const SizedBox(height: 20),

                    _buildDashboardOption(
                      context: context,
                      icon: Icons.rate_review,
                      title: 'Review Student Complaints',
                      subtitle: 'Review and respond to student complaints',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewStudentComplaintsPage(batchAdvisor: batchAdvisor)));
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

class BatchAdvisorRaiseComplaintPage extends StatefulWidget {
  final AppUser batchAdvisor;
  const BatchAdvisorRaiseComplaintPage({super.key, required this.batchAdvisor});

  @override
  State<BatchAdvisorRaiseComplaintPage> createState() => _BatchAdvisorRaiseComplaintPageState();
}

class _BatchAdvisorRaiseComplaintPageState extends State<BatchAdvisorRaiseComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  
  AppUser? _selectedHOD;
  bool _isAnonymous = false;
  XFile? _selectedImage;
  
  bool _isHODsLoading = false;
  bool _isSubmitting = false;
  List<AppUser> _hods = [];

  @override
  void initState() {
    super.initState();
    _loadHODs();
  }

  Future<void> _loadHODs() async {
    setState(() {
      _isHODsLoading = true;
      _hods = [];
      _selectedHOD = null;
    });
    try {
      final hods = await UserService.getUsersByRole('HOD');
      if (!mounted) return;
      setState(() {
        _hods = hods;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load HODs: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (!mounted) return;
      setState(() {
        _isHODsLoading = false;
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
      if (_selectedHOD == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an HOD.'),
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
          studentId: widget.batchAdvisor.id,
          recipientId: _selectedHOD!.id,
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
                        _buildSectionTitle('1. Select HOD'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<AppUser>(
                          value: _selectedHOD,
                          isExpanded: true,
                          decoration: _buildInputDecoration(
                            labelText: 'Select HOD',
                            icon: Icons.school,
                          ),
                          items: _hods.map((AppUser hod) {
                            return DropdownMenuItem<AppUser>(
                              value: hod,
                              child: Text(hod.username),
                            );
                          }).toList(),
                          onChanged: (AppUser? newValue) {
                            setState(() {
                              _selectedHOD = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an HOD';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('2. Write Your Complaint'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _complaintController,
                          maxLines: 5,
                          decoration: _buildInputDecoration(
                            labelText: 'Complaint Details',
                            icon: Icons.edit,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your complaint';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('3. Additional Options'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  _isAnonymous = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF0D1B2A),
                            ),
                            const Text(
                              'Submit anonymously',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.attach_file),
                          label: Text(_selectedImage != null ? 'Image Selected' : 'Attach Image (Optional)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E1DD),
                            foregroundColor: const Color(0xFF0D1B2A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        if (_selectedImage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE0E1DD)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D1B2A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Submit Complaint',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
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
      fillColor: const Color(0xFFE0E1DD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E1DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E1DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B2A), width: 2),
      ),
    );
  }
}

class BatchAdvisorViewComplaintsPage extends StatefulWidget {
  final AppUser batchAdvisor;
  const BatchAdvisorViewComplaintsPage({super.key, required this.batchAdvisor});

  @override
  State<BatchAdvisorViewComplaintsPage> createState() => _BatchAdvisorViewComplaintsPageState();
}

class _BatchAdvisorViewComplaintsPageState extends State<BatchAdvisorViewComplaintsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() { _isLoading = true; });
    try {
      final complaints = await ComplaintService.getComplaintsByBatchAdvisorWithComments(widget.batchAdvisor.id);
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
        title: Text('View My Complaints', style: TextStyle(color: Colors.white)),
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
                    style: const TextStyle(color: Colors.black, fontSize: 14),
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
                      final isBatchAdvisorComment = comment['batch_advisor_id'] == widget.batchAdvisor.id;
                      return _buildCommentCard(comment);
                    }).toList(),
                  ],
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (status == 'Pending') ...[
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
                      ],
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
  
  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final isBatchAdvisorComment = comment['batch_advisor_id'] == widget.batchAdvisor.id;
    final createdAt = DateTime.parse(comment['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBatchAdvisorComment ? const Color(0xFFE0E1DD) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBatchAdvisorComment ? const Color(0xFF0D1B2A) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBatchAdvisorComment ? Icons.person : Icons.school,
                size: 16,
                color: isBatchAdvisorComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                isBatchAdvisorComment ? 'You' : 'Recipient',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBatchAdvisorComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment['comment_text'], style: const TextStyle(color: Colors.black, fontSize: 14)),
        ],
      ),
    );
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
                    batchAdvisorId: widget.batchAdvisor.id,
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
                    batchAdvisorId: widget.batchAdvisor.id,
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
}

class ReviewStudentComplaintsPage extends StatefulWidget {
  final AppUser batchAdvisor;
  const ReviewStudentComplaintsPage({super.key, required this.batchAdvisor});

  @override
  State<ReviewStudentComplaintsPage> createState() => _ReviewStudentComplaintsPageState();
}

class _ReviewStudentComplaintsPageState extends State<ReviewStudentComplaintsPage> {
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
      final complaints = await ComplaintService.getComplaintsForBatchAdvisor(widget.batchAdvisor.id);
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
                    batchAdvisorId: widget.batchAdvisor.id,
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
        title: Text('Review Student Complaints', style: TextStyle(color: Colors.white)),
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
      message = 'No Student Complaints';
      subtitle = 'No students have sent you complaints yet.';
    } else {
      message = 'No Complaints in ${_selectedTimeFilter}';
      subtitle = 'No student complaints found for the selected time period.';
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
          final student = complaint['student'] ?? {'username': 'Anonymous', 'role': 'Student'};
          final status = complaint['status'] ?? 'N/A';
          final createdAt = DateTime.parse(complaint['created_at']);
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
                              'From: ${isAnonymous ? 'Anonymous Student' : student['username']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (!isAnonymous)
                              Text(
                                'Role: ${student['role']}',
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
                    complaint['complaint_text'],
                    style: const TextStyle(color: Colors.black, fontSize: 14),
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
                      final isBatchAdvisorComment = comment['batch_advisor_id'] == widget.batchAdvisor.id;
                      return _buildCommentCard(comment);
                    }).toList(),
                  ],
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (status == 'Pending') ...[
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
                      ],
                    ),
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
  
  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final isBatchAdvisorComment = comment['batch_advisor_id'] == widget.batchAdvisor.id;
    final createdAt = DateTime.parse(comment['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBatchAdvisorComment ? const Color(0xFFE0E1DD) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBatchAdvisorComment ? const Color(0xFF0D1B2A) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBatchAdvisorComment ? Icons.person : Icons.school,
                size: 16,
                color: isBatchAdvisorComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                isBatchAdvisorComment ? 'You' : 'Student',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBatchAdvisorComment ? const Color(0xFF0D1B2A) : Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment['comment_text'], style: const TextStyle(color: Colors.black, fontSize: 14)),
        ],
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
