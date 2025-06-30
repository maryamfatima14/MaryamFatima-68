import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final _client = SupabaseConfig.client;

class CRGRPortal extends StatelessWidget {
  final AppUser user;
  const CRGRPortal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF52357B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x2252357B),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFFEAEFEF), size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.role + ' Portal',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEAEFEF),
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Welcome, ${user.username}!',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFEAEFEF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFFEAEFEF), size: 28),
                        tooltip: 'Logout',
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Features Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Submit Complaint',
                      Icons.report_problem,
                      Colors.red,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CRRaiseComplaintPage(user: user),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'My Complaints',
                      Icons.list_alt,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CRViewComplaintsPage(user: user),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Department Info',
                      Icons.business,
                      Colors.green,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CRDepartmentInfoPage(user: user),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Batch Info',
                      Icons.school,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CRBatchInfoPage(user: user),
                        ),
                      ),
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

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF52357B).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFF52357B).withOpacity(0.15), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.10),
              radius: 32,
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF52357B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CR Raise Complaint Page
class CRRaiseComplaintPage extends StatefulWidget {
  final AppUser user;
  const CRRaiseComplaintPage({super.key, required this.user});

  @override
  State<CRRaiseComplaintPage> createState() => _CRRaiseComplaintPageState();
}

class _CRRaiseComplaintPageState extends State<CRRaiseComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  String _selectedRecipientType = 'BatchAdvisor';
  List<Map<String, dynamic>> _recipients = [];
  bool _isAnonymous = false;
  bool _isLoading = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadRecipients();
  }

  Future<void> _loadRecipients() async {
    try {
      final recipients = await UserService.getUsersByRole(_selectedRecipientType);
      setState(() {
        _recipients = recipients.map((user) => user.toMap()).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recipients: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipients available'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await ComplaintService.uploadImage(_selectedImage!);
      }

      await ComplaintService.addComplaint(
        studentId: widget.user.id,
        recipientId: _recipients.first['id'],
        complaintText: _complaintController.text.trim(),
        isAnonymous: _isAnonymous,
        imageUrl: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recipient Type',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(value: 'BatchAdvisor', label: Text('Batch Advisor'), icon: Icon(Icons.person)),
                            ButtonSegment<String>(value: 'HOD', label: Text('HOD'), icon: Icon(Icons.admin_panel_settings)),
                          ],
                          selected: {_selectedRecipientType},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedRecipientType = newSelection.first;
                            });
                            _loadRecipients();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complaint Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _complaintController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Complaint Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter complaint description';
                            }
                            return null;
                          },
                        ),
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
                            ),
                            const Text('Submit anonymously'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Attach Image'),
                            ),
                            const SizedBox(width: 8),
                            if (_selectedImage != null)
                              Expanded(
                                child: Text(
                                  'Image selected: ${_selectedImage!.name}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Complaint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CR View Complaints Page
class CRViewComplaintsPage extends StatefulWidget {
  final AppUser user;
  const CRViewComplaintsPage({super.key, required this.user});

  @override
  State<CRViewComplaintsPage> createState() => _CRViewComplaintsPageState();
}

class _CRViewComplaintsPageState extends State<CRViewComplaintsPage> {
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final complaints = await ComplaintService.getComplaintsByStudent(widget.user.id);
      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load complaints: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        actions: [
          IconButton(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _complaints.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No complaints found', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _complaints[index];
                      final status = complaint['status'];
                      final createdAt = DateTime.parse(complaint['created_at']);
                      
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

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            complaint['complaint_text'] ?? 'No text',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (complaint['recipient'] != null)
                                Text('To: ${complaint['recipient']['username']} (${complaint['recipient']['role']})'),
                              Text('Date: ${createdAt.toString().substring(0, 10)}'),
                              if (complaint['is_anonymous'] == true)
                                const Text('Anonymous', style: TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

// CR Department Info Page
class CRDepartmentInfoPage extends StatefulWidget {
  final AppUser user;
  const CRDepartmentInfoPage({super.key, required this.user});

  @override
  State<CRDepartmentInfoPage> createState() => _CRDepartmentInfoPageState();
}

class _CRDepartmentInfoPageState extends State<CRDepartmentInfoPage> {
  Map<String, dynamic>? _departmentInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartmentInfo();
  }

  Future<void> _loadDepartmentInfo() async {
    try {
      // Get CR/GR assignment info based on user role with HOD name
      final assignment = await _client
          .from('cr_gr_assignments')
          .select('*, department:department_id(*, hod:hod_id(username, full_name))')
          .eq('user_id', widget.user.id)
          .eq('assignment_type', widget.user.role)
          .maybeSingle();
      
      print('Department assignment found: $assignment'); // Debug print
      
      setState(() {
        _departmentInfo = assignment != null ? assignment['department'] : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading department info: $e'); // Debug print
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load department info: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Information'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _departmentInfo == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No department assigned', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Department Details',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Name', _departmentInfo!['name'] ?? 'N/A'),
                            _buildInfoRow('Code', _departmentInfo!['code'] ?? 'N/A'),
                            if (_departmentInfo!['hod'] != null)
                              _buildInfoRow('HOD', _departmentInfo!['hod']['full_name'] ?? _departmentInfo!['hod']['username'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// CR Batch Info Page
class CRBatchInfoPage extends StatefulWidget {
  final AppUser user;
  const CRBatchInfoPage({super.key, required this.user});

  @override
  State<CRBatchInfoPage> createState() => _CRBatchInfoPageState();
}

class _CRBatchInfoPageState extends State<CRBatchInfoPage> {
  Map<String, dynamic>? _batchInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatchInfo();
  }

  Future<void> _loadBatchInfo() async {
    try {
      // Get CR/GR assignment info based on user role with Batch Advisor name
      final assignment = await _client
          .from('cr_gr_assignments')
          .select('*, batch:batch_id(*, batch_advisor:batch_advisor_id(username, full_name))')
          .eq('user_id', widget.user.id)
          .eq('assignment_type', widget.user.role)
          .maybeSingle();
      
      print('Batch assignment found: $assignment'); // Debug print
      
      setState(() {
        _batchInfo = assignment != null ? assignment['batch'] : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading batch info: $e'); // Debug print
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batch info: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Information'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _batchInfo == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No batch assigned', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Batch Details',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Name', _batchInfo!['name'] ?? 'N/A'),
                            _buildInfoRow('Academic Year', _batchInfo!['academic_year'] ?? 'N/A'),
                            if (_batchInfo!['batch_advisor'] != null)
                              _buildInfoRow('Batch Advisor', _batchInfo!['batch_advisor']['full_name'] ?? _batchInfo!['batch_advisor']['username'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 
