import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

final _client = SupabaseConfig.client;

class AdminFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const AdminFeatureTile({required this.icon, required this.title, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _showAdminMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AdminMenuSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.apartment,
        'title': 'Departments',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageDepartmentsScreen())),
      },
      {
        'icon': Icons.group,
        'title': 'Batches',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBatchesScreen())),
      },
      {
        'icon': Icons.person_add,
        'title': 'Batch Advisors',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignBatchAdvisorsScreen())),
      },
      {
        'icon': Icons.admin_panel_settings,
        'title': 'HOD Accounts',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateHODScreen())),
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Complaints',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintStatsScreen())),
      },
      {
        'icon': Icons.upload_file,
        'title': 'Import Data',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => ImportDataScreen())),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gradient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x220D1B2A),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      tooltip: 'Menu',
                      onPressed: () => _showAdminMenu(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                      tooltip: 'Logout',
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    const Icon(Icons.dashboard_customize, color: Color(0xFF0D1B2A)),
                    const SizedBox(width: 8),
                    Text(
                      'Admin Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return GestureDetector(
                      onTap: feature['onTap'] as VoidCallback,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF0D1B2A).withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: Color(0xFF0D1B2A).withOpacity(0.15), width: 1.2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFF0D1B2A).withOpacity(0.10),
                              radius: 32,
                              child: Icon(feature['icon'] as IconData, color: Color(0xFF0D1B2A), size: 36),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                feature['title'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuSheet extends StatefulWidget {
  @override
  State<_AdminMenuSheet> createState() => _AdminMenuSheetState();
}

class _AdminMenuSheetState extends State<_AdminMenuSheet> {
  int _selectedIndex = -1;
  static const LatLng _center = LatLng(30.0419, 72.3556); // Vehari, Pakistan

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile (centered)
          Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/animations/admin.png'),
              ),
              const SizedBox(height: 12),
              const Text('Welcome Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
            ],
          ),
          const SizedBox(height: 24),
          // Menu options
          _buildMenuTile('Privacy settings', 0, icon: Icons.privacy_tip),
          _buildMenuTile('Location', 1, icon: Icons.location_on),
          const SizedBox(height: 16),
          if (_selectedIndex == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E1DD).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Your privacy is important. We do not share your data with third parties. All information is kept confidential.',
                style: TextStyle(fontSize: 15, color: Color(0xFF0D1B2A)),
              ),
            ),
          if (_selectedIndex == 1)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    center: _center,
                    zoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin, color: Color(0xFF0D1B2A), size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, int index, {required IconData icon}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? -1 : index;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E1DD).withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0D1B2A), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0D1B2A)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF0D1B2A)),
          ],
        ),
      ),
    );
  }
}

// Scaffold screens for each feature
class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});
  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  List<Map<String, dynamic>> _departments = [];
  List<AppUser> _hods = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadHODs();
  }

  Future<void> _loadDepartments() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final departments = await _client
          .from('departments')
          .select('*, hod:hod_id(username, id)')
          .order('name');
      setState(() {
        _departments = List<Map<String, dynamic>>.from(departments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load departments: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadHODs() async {
    try {
      final hods = await UserService.getUsersByRole('HOD');
      setState(() => _hods = hods);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load HODs: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDepartmentDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    AppUser? selectedHOD;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Department Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Department Code'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppUser>(
                value: selectedHOD,
                decoration: const InputDecoration(labelText: 'Assign HOD (Optional)'),
                items: _hods.map((hod) => DropdownMenuItem(
                  value: hod,
                  child: Text(hod.username),
                )).toList(),
                onChanged: (hod) => setDialogState(() => selectedHOD = hod),
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
                if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                  try {
                    await _client.from('departments').insert({
                      'name': nameController.text.trim(),
                      'code': codeController.text.trim().toUpperCase(),
                      'hod_id': selectedHOD?.id,
                    });
                    Navigator.pop(context);
                    _loadDepartments();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Department added successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add department: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDepartmentDialog(Map<String, dynamic> department) {
    final nameController = TextEditingController(text: department['name']);
    final codeController = TextEditingController(text: department['code']);
    AppUser? selectedHOD = department['hod'] != null ? 
      AppUser(
        id: department['hod']['id'],
        username: department['hod']['username'],
        password: '',
        role: 'HOD',
        createdAt: DateTime.now(),
      ) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Department Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Department Code'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppUser>(
                value: selectedHOD,
                decoration: const InputDecoration(labelText: 'Assign HOD (Optional)'),
                items: _hods.map((hod) => DropdownMenuItem(
                  value: hod,
                  child: Text(hod.username),
                )).toList(),
                onChanged: (hod) => setDialogState(() => selectedHOD = hod),
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
                if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                  try {
                    await _client.from('departments').update({
                      'name': nameController.text.trim(),
                      'code': codeController.text.trim().toUpperCase(),
                      'hod_id': selectedHOD?.id,
                    }).eq('id', department['id']);
                    Navigator.pop(context);
                    _loadDepartments();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Department updated successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update department: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDepartment(String departmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: const Text('Are you sure you want to delete this department? This will also delete all associated batches.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _client.from('departments').delete().eq('id', departmentId);
                Navigator.pop(context);
                _loadDepartments();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Department deleted successfully!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete department: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Departments'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDepartments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _departments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.apartment, size: 60, color: Colors.pink),
                          const SizedBox(height: 16),
                          const Text('No departments found.', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddDepartmentDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Department'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(dept['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dept['code'] != null && dept['code'].toString().trim().isNotEmpty)
                                  Text('Code: ${dept['code']}'),
                                if (dept['hod'] != null) Text('HOD: ${dept['hod']['username']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showEditDepartmentDialog(dept),
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => _deleteDepartment(dept['id']),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: _departments.isEmpty ? null : FloatingActionButton(
        onPressed: _showAddDepartmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ManageBatchesScreen extends StatefulWidget {
  const ManageBatchesScreen({super.key});
  @override
  State<ManageBatchesScreen> createState() => _ManageBatchesScreenState();
}

class _ManageBatchesScreenState extends State<ManageBatchesScreen> {
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _departments = [];
  List<AppUser> _batchAdvisors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBatches();
    _loadDepartments();
    _loadBatchAdvisors();
  }

  Future<void> _loadBatches() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final batches = await _client
          .from('batches')
          .select('*, department:department_id(name, code), batch_advisor:batch_advisor_id(username, id)')
          .order('name');
      setState(() {
        _batches = List<Map<String, dynamic>>.from(batches);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batches: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _client.from('departments').select('*').order('name');
      setState(() => _departments = List<Map<String, dynamic>>.from(departments));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load departments: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadBatchAdvisors() async {
    try {
      final advisors = await UserService.getUsersByRole('BatchAdvisor');
      setState(() => _batchAdvisors = advisors);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batch advisors: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddBatchDialog() {
    final nameController = TextEditingController();
    final yearController = TextEditingController();
    Map<String, dynamic>? selectedDepartment;
    AppUser? selectedAdvisor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Batch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Batch Name'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Academic Year (e.g., 2024-25)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments.map((dept) => DropdownMenuItem(
                  value: dept,
                  child: Text('${dept['name']} (${dept['code']})'),
                )).toList(),
                onChanged: (dept) => setDialogState(() => selectedDepartment = dept),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppUser>(
                value: selectedAdvisor,
                decoration: const InputDecoration(labelText: 'Assign Batch Advisor (Optional)'),
                items: _batchAdvisors.map((advisor) => DropdownMenuItem(
                  value: advisor,
                  child: Text(advisor.username),
                )).toList(),
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
                if (nameController.text.isNotEmpty && 
                    yearController.text.isNotEmpty && 
                    selectedDepartment != null) {
                  try {
                    await _client.from('batches').insert({
                      'name': nameController.text.trim(),
                      'academic_year': yearController.text.trim(),
                      'department_id': selectedDepartment!['id'],
                      'batch_advisor_id': selectedAdvisor?.id,
                    });
                    Navigator.pop(context);
                    _loadBatches();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Batch added successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add batch: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBatchDialog(Map<String, dynamic> batch) {
    final nameController = TextEditingController(text: batch['name']);
    final yearController = TextEditingController(text: batch['academic_year']);
    Map<String, dynamic>? selectedDepartment = batch['department'];
    AppUser? selectedAdvisor = batch['batch_advisor'] != null ? 
      AppUser(
        id: batch['batch_advisor']['id'],
        username: batch['batch_advisor']['username'],
        password: '',
        role: 'BatchAdvisor',
        createdAt: DateTime.now(),
      ) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Batch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Batch Name'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Academic Year'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments.map((dept) => DropdownMenuItem(
                  value: dept,
                  child: Text('${dept['name']} (${dept['code']})'),
                )).toList(),
                onChanged: (dept) => setDialogState(() => selectedDepartment = dept),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppUser>(
                value: selectedAdvisor,
                decoration: const InputDecoration(labelText: 'Assign Batch Advisor (Optional)'),
                items: _batchAdvisors.map((advisor) => DropdownMenuItem(
                  value: advisor,
                  child: Text(advisor.username),
                )).toList(),
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
                if (nameController.text.isNotEmpty && 
                    yearController.text.isNotEmpty && 
                    selectedDepartment != null) {
                  try {
                    await _client.from('batches').update({
                      'name': nameController.text.trim(),
                      'academic_year': yearController.text.trim(),
                      'department_id': selectedDepartment!['id'],
                      'batch_advisor_id': selectedAdvisor?.id,
                    }).eq('id', batch['id']);
                    Navigator.pop(context);
                    _loadBatches();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Batch updated successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update batch: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBatch(String batchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text('Are you sure you want to delete this batch? This will also delete all associated students.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _client.from('batches').delete().eq('id', batchId);
                Navigator.pop(context);
                _loadBatches();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batch deleted successfully!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete batch: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Batches'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadBatches,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _batches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group, size: 60, color: Colors.pink),
                          const SizedBox(height: 16),
                          const Text('No batches found.', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddBatchDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Batch'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _batches.length,
                      itemBuilder: (context, index) {
                        final batch = _batches[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(batch['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Year: ${batch['academic_year']}'),
                                Text('Department: ${batch['department']['name']} (${batch['department']['code']})'),
                                if (batch['batch_advisor'] != null) Text('Advisor: ${batch['batch_advisor']['username']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showEditBatchDialog(batch),
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => _deleteBatch(batch['id']),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: _batches.isEmpty ? null : FloatingActionButton(
        onPressed: _showAddBatchDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExcelUploadScreen extends StatefulWidget {
  const ExcelUploadScreen({super.key});
  @override
  State<ExcelUploadScreen> createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  bool _isUploading = false;
  String? _selectedFile;
  List<List<dynamic>> _excelRows = [];
  String _uploadSummary = '';

  Future<void> _pickAndDisplayExcel() async {
    setState(() { _isUploading = true; _uploadSummary = ''; _excelRows = []; });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() => _selectedFile = result.files.single.name);
        Uint8List? bytes = result.files.single.bytes;
        if (bytes == null && result.files.single.path != null) {
          bytes = File(result.files.single.path!).readAsBytesSync();
        }
        if (bytes == null) {
          setState(() { _uploadSummary = 'Upload failed: Could not read file bytes.'; });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to read file bytes.'), backgroundColor: Colors.red),
            );
          }
          setState(() { _isUploading = false; });
          return;
        }
        try {
          var excelFile = excel.Excel.decodeBytes(bytes);
          List<List<dynamic>> allRows = [];
          for (var table in excelFile.tables.keys) {
            for (var row in excelFile.tables[table]!.rows) {
              allRows.add(row.map((cell) => cell?.value ?? '').toList());
            }
          }
          setState(() {
            _excelRows = allRows;
            _uploadSummary = 'Upload complete! ${_excelRows.length} rows loaded.';
          });
        } catch (e) {
          setState(() { _uploadSummary = 'Upload failed: Not a valid Excel file.'; });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: Not a valid Excel file.'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      setState(() { _uploadSummary = 'Upload failed: $e'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload Excel data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Excel Data'),
      ),
      body: ExcelUploadContent(
        isUploading: _isUploading,
        selectedFile: _selectedFile,
        excelRows: _excelRows,
        uploadSummary: _uploadSummary,
        onPickAndDisplayExcel: _pickAndDisplayExcel,
        onDeleteFile: () {
          setState(() {
            _selectedFile = null;
            _excelRows = [];
            _uploadSummary = '';
          });
        },
      ),
    );
  }
}

class ExcelUploadContent extends StatelessWidget {
  final bool isUploading;
  final String? selectedFile;
  final List<List<dynamic>> excelRows;
  final String uploadSummary;
  final VoidCallback onPickAndDisplayExcel;
  final VoidCallback onDeleteFile;

  const ExcelUploadContent({
    super.key,
    required this.isUploading,
    required this.selectedFile,
    required this.excelRows,
    required this.uploadSummary,
    required this.onPickAndDisplayExcel,
    required this.onDeleteFile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    'Excel Upload',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can upload any Excel (.xlsx) file. All rows and columns will be displayed below.',
                    style: TextStyle(fontSize: 14),
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
                children: [
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : onPickAndDisplayExcel,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Select & Upload Excel File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (selectedFile != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Selected: $selectedFile', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete uploaded file',
                          onPressed: onDeleteFile,
                        ),
                      ],
                    ),
                  ],
                  if (isUploading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  if (uploadSummary.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(uploadSummary, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Remove Expanded here, just show the table or a message
          if (excelRows.isEmpty)
            const Center(child: Text('No data loaded.'))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: excelRows.isNotEmpty
                    ? List.generate(excelRows[0].length, (i) => DataColumn(label: Text('Col ${i + 1}')))
                    : [],
                rows: excelRows
                    .map((row) => DataRow(
                          cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class AssignBatchAdvisorsScreen extends StatefulWidget {
  const AssignBatchAdvisorsScreen({super.key});
  @override
  State<AssignBatchAdvisorsScreen> createState() => _AssignBatchAdvisorsScreenState();
}

class _AssignBatchAdvisorsScreenState extends State<AssignBatchAdvisorsScreen> {
  List<Map<String, dynamic>> _batches = [];
  List<AppUser> _batchAdvisors = [];
  bool _isLoading = true;

  // For creating a new batch advisor
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreating = false;

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
          .order('name');
      
      setState(() {
        _batches = List<Map<String, dynamic>>.from(batches);
        _isLoading = false;
      });
    } catch (e) {
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
    AppUser? selectedAdvisor = batch['batch_advisor'] != null ? 
      AppUser(
        id: batch['batch_advisor']['id'],
        username: batch['batch_advisor']['username'],
        password: '',
        role: 'BatchAdvisor',
        createdAt: DateTime.now(),
      ) : null;

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
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/batch_advisors_export.xlsx');
      await file.writeAsBytes(bytes!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Batch Advisors exported: ${file.path}'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
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
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _loadBatches();
              _loadBatchAdvisors();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Create Batch Advisor Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
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
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
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
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isCreating
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
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
                  // Batch List
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
                ],
              ),
            ),
    );
  }
}

class CreateHODScreen extends StatefulWidget {
  const CreateHODScreen({super.key});
  @override
  State<CreateHODScreen> createState() => _CreateHODScreenState();
}

class _CreateHODScreenState extends State<CreateHODScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  List<Map<String, dynamic>> _departments = [];
  Map<String, dynamic>? _selectedDepartment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _client
          .from('departments')
          .select('*, hod:hod_id(username, id)')
          .order('name');
      setState(() => _departments = List<Map<String, dynamic>>.from(departments));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load departments: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createHODAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create HOD user account
      await UserService.addUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        'HOD',
      );

      // Fetch the created HOD user
      final hodUser = await UserService.authenticateUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        'HOD',
      );

      // If department is selected, assign HOD to department
      if (_selectedDepartment != null && hodUser != null) {
        await _client.from('departments').update({
          'hod_id': hodUser.id,
        }).eq('id', _selectedDepartment!['id']);
      }

      // Clear form
      _formKey.currentState!.reset();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() => _selectedDepartment = null);

      // Reload departments to show updated HOD assignments
      await _loadDepartments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HOD account created successfully!${_selectedDepartment != null ? ' Assigned to ${_selectedDepartment!['name']}.' : ''}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create HOD account: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportHODs() async {
    setState(() { _isLoading = true; });
    try {
      final hods = await _client.from('users').select('username, password').eq('role', 'HOD');
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['HODs'];
      sheet.appendRow(['Username/Email', 'Password', 'Role']);
      for (var h in hods) {
        sheet.appendRow([
          h['username'] ?? '',
          h['password'] ?? '',
          'HOD',
        ]);
      }
      final bytes = excelFile.encode();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/hods_export.xlsx');
      await file.writeAsBytes(bytes!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HODs exported: ${file.path}'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
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
        title: const Text('HOD Accounts'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDepartments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create HOD Account Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New HOD Account',
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
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Assign to Department (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<Map<String, dynamic>>(
                            value: null,
                            child: Text('No Department'),
                          ),
                          ..._departments.map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text('${dept['name']} (${dept['code']})'),
                          )),
                        ],
                        onChanged: (dept) => setState(() => _selectedDepartment = dept),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createHODAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Creating...'),
                                  ],
                                )
                              : const Text('Create HOD Account'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _exportHODs,
                        icon: const Icon(Icons.download),
                        label: const Text('Export HODs'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Department HOD Assignments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Department HOD Assignments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ..._departments.map((dept) => ListTile(
                      title: Text(dept['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dept['code'] != null && dept['code'].toString().trim().isNotEmpty)
                            Text('Code: ${dept['code']}'),
                          if (dept['hod'] != null) Text('HOD: ${dept['hod']['username']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        ],
                      ),
                      trailing: dept['hod'] != null
                          ? Text('HOD: ${dept['hod']['username']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                          : const SizedBox.shrink(),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComplaintStatsScreen extends StatefulWidget {
  const ComplaintStatsScreen({super.key});
  @override
  State<ComplaintStatsScreen> createState() => _ComplaintStatsScreenState();
}

class _ComplaintStatsScreenState extends State<ComplaintStatsScreen> {
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _complaints = [];
  Map<String, dynamic> _overallStats = {};
  bool _isLoading = true;
  String _selectedTimeFilter = 'All Time';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadDepartments(),
        _loadComplaints(),
      ]);
      _calculateStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDepartments() async {
    final departments = await _client.from('departments').select('*').order('name');
    setState(() => _departments = List<Map<String, dynamic>>.from(departments));
  }

  Future<void> _loadComplaints() async {
    final complaints = await _client
        .from('complaints')
        .select('*, student:student_tracking_id(username, role), recipient:recipient_id(username, role)')
        .order('created_at', ascending: false);
    setState(() => _complaints = List<Map<String, dynamic>>.from(complaints));
  }

  void _calculateStats() {
    final now = DateTime.now();
    final filteredComplaints = _complaints.where((complaint) {
      final createdAt = DateTime.parse(complaint['created_at']);
      
      switch (_selectedTimeFilter) {
        case 'Today':
          return createdAt.isAfter(DateTime(now.year, now.month, now.day));
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return createdAt.isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day));
        case 'This Month':
          return createdAt.isAfter(DateTime(now.year, now.month, 1));
        default:
          return true; // All Time
      }
    }).toList();

    final total = filteredComplaints.length;
    final pending = filteredComplaints.where((c) => c['status'] == 'Pending').length;
    final inProgress = filteredComplaints.where((c) => c['status'] == 'In Progress').length;
    final resolved = filteredComplaints.where((c) => c['status'] == 'Resolved').length;
    final rejected = filteredComplaints.where((c) => c['status'] == 'Rejected').length;

    setState(() {
      _overallStats = {
        'total': total,
        'pending': pending,
        'inProgress': inProgress,
        'resolved': resolved,
        'rejected': rejected,
      };
    });
  }

  List<Map<String, dynamic>> _getDepartmentStats() {
    final departmentStats = <Map<String, dynamic>>[];
    
    for (final dept in _departments) {
      final deptComplaints = _complaints.where((complaint) {
        // This is a simplified approach - in a real app you'd have proper department tracking
        return complaint['student'] != null && complaint['student']['role'] == 'Student';
      }).toList();

      final total = deptComplaints.length;
      final pending = deptComplaints.where((c) => c['status'] == 'Pending').length;
      final resolved = deptComplaints.where((c) => c['status'] == 'Resolved').length;
      final rejected = deptComplaints.where((c) => c['status'] == 'Rejected').length;

      departmentStats.add({
        'department': dept,
        'total': total,
        'pending': pending,
        'resolved': resolved,
        'rejected': rejected,
      });
    }

    return departmentStats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time Filter
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time Period',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _selectedTimeFilter,
                            isExpanded: true,
                            items: ['All Time', 'Today', 'This Week', 'This Month'].map((period) {
                              return DropdownMenuItem(value: period, child: Text(period));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedTimeFilter = value!);
                              _calculateStats();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Overall Statistics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Statistics',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard('Total', _overallStats['total'] ?? 0, Colors.blue),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard('Pending', _overallStats['pending'] ?? 0, Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard('In Progress', _overallStats['inProgress'] ?? 0, Colors.purple),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard('Resolved', _overallStats['resolved'] ?? 0, Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard('Rejected', _overallStats['rejected'] ?? 0, Colors.red),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(), // Empty for alignment
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Department Statistics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Department Statistics',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ..._getDepartmentStats().map((stat) => _buildDepartmentStatCard(stat)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Recent Complaints
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Complaints',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ..._complaints.take(5).map((complaint) => _buildComplaintCard(complaint)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentStatCard(Map<String, dynamic> stat) {
    final dept = stat['department'];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(dept['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dept['code'] != null && dept['code'].toString().trim().isNotEmpty)
              Text('Code: ${dept['code']}'),
            Text('Total: ${stat['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Pending: ${stat['pending']}', style: const TextStyle(color: Colors.orange)),
            Text('Resolved: ${stat['resolved']}', style: const TextStyle(color: Colors.green)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Total: ${stat['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Pending: ${stat['pending']}', style: const TextStyle(color: Colors.orange)),
            Text('Resolved: ${stat['resolved']}', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          complaint['complaint_text'] ?? 'No text',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (complaint['student'] != null) Text('From: ${complaint['student']['username']}'),
            Text('Date: ${createdAt.toString().substring(0, 10)}'),
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
  }
}

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBatchId;
  List<Map<String, dynamic>> _batches = [];
  bool _isLoading = false;
  String _message = '';
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
    _loadStudents();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await _client.from('batches').select('*').order('name');
      setState(() => _batches = List<Map<String, dynamic>>.from(batches));
    } catch (e) {
      setState(() => _message = 'Failed to load batches: $e');
    }
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _client.from('users').select('id, full_name, roll_number, batch_id').eq('role', 'Student');
      setState(() => _students = List<Map<String, dynamic>>.from(students));
    } catch (e) {
      setState(() => _message = 'Failed to load students: $e');
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _message = ''; });
    try {
      await _client.from('users').insert({
        'username': _idController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': 'Student',
        'batch_id': _selectedBatchId,
        'full_name': _nameController.text.trim(),
        'roll_number': _idController.text.trim(),
      });
      setState(() { _message = 'Student added successfully!'; });
      _nameController.clear();
      _idController.clear();
      _passwordController.clear();
      _selectedBatchId = null;
      await _loadStudents();
    } catch (e) {
      setState(() { _message = 'Failed to add student: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteStudent(String id) async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      await _client.from('users').delete().eq('id', id);
      await _loadStudents();
      setState(() { _message = 'Student deleted.'; });
    } catch (e) {
      setState(() { _message = 'Delete failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    final nameController = TextEditingController(text: student['full_name'] ?? '');
    final idController = TextEditingController(text: student['roll_number'] ?? '');
    String? selectedBatchId = student['batch_id']?.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
            ),
            DropdownButtonFormField<String>(
              value: selectedBatchId,
              items: _batches.map((b) => DropdownMenuItem(
                value: b['id'].toString(),
                child: Text(b['name']),
              )).toList(),
              onChanged: (v) => selectedBatchId = v,
              decoration: const InputDecoration(labelText: 'Batch'),
              validator: (v) => v == null ? 'Select batch' : null,
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
                await _client.from('users').update({
                  'full_name': nameController.text.trim(),
                  'roll_number': idController.text.trim(),
                  'password': _passwordController.text.trim(),
                  'batch_id': selectedBatchId,
                }).eq('id', student['id']);
                Navigator.pop(context);
                await _loadStudents();
                setState(() { _message = 'Student updated.'; });
              } catch (e) {
                setState(() { _message = 'Update failed: $e'; });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportStudents() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      final students = await _client.from('users').select('full_name, roll_number, batch_id').eq('role', 'Student');
      final batchMap = {for (var b in _batches) b['id']: b['name']};
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Students'];
      sheet.appendRow(['Name', 'ID', 'Batch']);
      for (var s in students) {
        sheet.appendRow([
          s['full_name'] ?? '',
          s['roll_number'] ?? '',
          batchMap[s['batch_id']] ?? '',
        ]);
      }
      final bytes = excelFile.encode();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/students_export.xlsx');
      await file.writeAsBytes(bytes!);
      setState(() { _message = 'File saved at: ${file.path}'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved at: ${file.path}'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() { _message = 'Export failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: AddStudentContent(
        formKey: _formKey,
        nameController: _nameController,
        idController: _idController,
        passwordController: _passwordController,
        selectedBatchId: _selectedBatchId,
        batches: _batches,
        isLoading: _isLoading,
        message: _message,
        students: _students,
        onBatchChanged: (v) => setState(() => _selectedBatchId = v),
        onAddStudent: _addStudent,
        onExportStudents: _exportStudents,
        onEditStudent: _showEditStudentDialog,
        onDeleteStudent: _deleteStudent,
      ),
    );
  }
}

class AddStudentContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController passwordController;
  final String? selectedBatchId;
  final List<Map<String, dynamic>> batches;
  final bool isLoading;
  final String message;
  final List<Map<String, dynamic>> students;
  final ValueChanged<String?> onBatchChanged;
  final VoidCallback onAddStudent;
  final VoidCallback onExportStudents;
  final void Function(Map<String, dynamic>) onEditStudent;
  final void Function(String) onDeleteStudent;

  const AddStudentContent({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.idController,
    required this.passwordController,
    required this.selectedBatchId,
    required this.batches,
    required this.isLoading,
    required this.message,
    required this.students,
    required this.onBatchChanged,
    required this.onAddStudent,
    required this.onExportStudents,
    required this.onEditStudent,
    required this.onDeleteStudent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter ID' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedBatchId,
                  items: batches.map((b) => DropdownMenuItem(
                    value: b['id'].toString(),
                    child: Text(b['name']),
                  )).toList(),
                  onChanged: onBatchChanged,
                  decoration: const InputDecoration(labelText: 'Batch'),
                  validator: (v) => v == null ? 'Select batch' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : onAddStudent,
                  child: const Text('Add Student'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onExportStudents,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Students'),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(message, style: TextStyle(color: message.contains('success') ? Colors.green : Colors.red)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('All Students', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          // Remove Expanded here, just show the list or a message
          if (students.isEmpty)
            const Center(child: Text('No students found.'))
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];
                  final batchName = batches.firstWhere(
                    (b) => b['id'] == s['batch_id'],
                    orElse: () => {'name': 'Unknown'},
                  )['name'];
                  return Card(
                    child: ListTile(
                      title: Text(s['full_name'] ?? ''),
                      subtitle: Text('ID: ${s['roll_number'] ?? ''} | Batch: $batchName'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => onEditStudent(s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onDeleteStudent(s['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// New screen that combines ExcelUploadScreen and AddStudentScreen
class ImportDataScreen extends StatefulWidget {
  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  // Excel upload state
  bool _isUploading = false;
  String? _selectedFile;
  List<List<dynamic>> _excelRows = [];
  String _uploadSummary = '';

  // Add student state
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBatchId;
  List<Map<String, dynamic>> _batches = [];
  bool _isLoading = false;
  String _message = '';
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
    _loadStudents();
  }

  Future<void> _pickAndDisplayExcel() async {
    setState(() { _isUploading = true; _uploadSummary = ''; _excelRows = []; });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() => _selectedFile = result.files.single.name);
        Uint8List? bytes = result.files.single.bytes;
        if (bytes == null && result.files.single.path != null) {
          bytes = File(result.files.single.path!).readAsBytesSync();
        }
        if (bytes == null) {
          setState(() { _uploadSummary = 'Upload failed: Could not read file bytes.'; });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to read file bytes.'), backgroundColor: Colors.red),
            );
          }
          setState(() { _isUploading = false; });
          return;
        }
        try {
          var excelFile = excel.Excel.decodeBytes(bytes);
          List<List<dynamic>> allRows = [];
          for (var table in excelFile.tables.keys) {
            for (var row in excelFile.tables[table]!.rows) {
              allRows.add(row.map((cell) => cell?.value ?? '').toList());
            }
          }
          setState(() {
            _excelRows = allRows;
            _uploadSummary = 'Upload complete! ${_excelRows.length} rows loaded.';
          });
        } catch (e) {
          setState(() { _uploadSummary = 'Upload failed: Not a valid Excel file.'; });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: Not a valid Excel file.'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      setState(() { _uploadSummary = 'Upload failed: $e'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload Excel data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await _client.from('batches').select('*').order('name');
      setState(() => _batches = List<Map<String, dynamic>>.from(batches));
    } catch (e) {
      setState(() => _message = 'Failed to load batches: $e');
    }
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _client.from('users').select('id, full_name, roll_number, batch_id').eq('role', 'Student');
      setState(() => _students = List<Map<String, dynamic>>.from(students));
    } catch (e) {
      setState(() => _message = 'Failed to load students: $e');
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _message = ''; });
    try {
      await _client.from('users').insert({
        'username': _idController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': 'Student',
        'batch_id': _selectedBatchId,
        'full_name': _nameController.text.trim(),
        'roll_number': _idController.text.trim(),
      });
      setState(() { _message = 'Student added successfully!'; });
      _nameController.clear();
      _idController.clear();
      _passwordController.clear();
      _selectedBatchId = null;
      await _loadStudents();
    } catch (e) {
      setState(() { _message = 'Failed to add student: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _exportStudents() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      final students = await _client.from('users').select('full_name, roll_number, batch_id').eq('role', 'Student');
      final batchMap = {for (var b in _batches) b['id']: b['name']};
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Students'];
      sheet.appendRow(['Name', 'ID', 'Batch']);
      for (var s in students) {
        sheet.appendRow([
          s['full_name'] ?? '',
          s['roll_number'] ?? '',
          batchMap[s['batch_id']] ?? '',
        ]);
      }
      final bytes = excelFile.encode();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/students_export.xlsx');
      await file.writeAsBytes(bytes!);
      setState(() { _message = 'File saved at: ${file.path}'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved at: ${file.path}'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() { _message = 'Export failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    final nameController = TextEditingController(text: student['full_name'] ?? '');
    final idController = TextEditingController(text: student['roll_number'] ?? '');
    String? selectedBatchId = student['batch_id']?.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
            ),
            DropdownButtonFormField<String>(
              value: selectedBatchId,
              items: _batches.map((b) => DropdownMenuItem(
                value: b['id'].toString(),
                child: Text(b['name']),
              )).toList(),
              onChanged: (v) => selectedBatchId = v,
              decoration: const InputDecoration(labelText: 'Batch'),
              validator: (v) => v == null ? 'Select batch' : null,
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
                await _client.from('users').update({
                  'full_name': nameController.text.trim(),
                  'roll_number': idController.text.trim(),
                  'password': _passwordController.text.trim(),
                  'batch_id': selectedBatchId,
                }).eq('id', student['id']);
                Navigator.pop(context);
                await _loadStudents();
                setState(() { _message = 'Student updated.'; });
              } catch (e) {
                setState(() { _message = 'Update failed: $e'; });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(String id) async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      await _client.from('users').delete().eq('id', id);
      await _loadStudents();
      setState(() { _message = 'Student deleted.'; });
    } catch (e) {
      setState(() { _message = 'Delete failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Excel Upload Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: ExcelUploadContent(
                  isUploading: _isUploading,
                  selectedFile: _selectedFile,
                  excelRows: _excelRows,
                  uploadSummary: _uploadSummary,
                  onPickAndDisplayExcel: _pickAndDisplayExcel,
                  onDeleteFile: () {
                    setState(() {
                      _selectedFile = null;
                      _excelRows = [];
                      _uploadSummary = '';
                    });
                  },
                ),
              ),
            ),
            // Add Student Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: AddStudentContent(
                  formKey: _formKey,
                  nameController: _nameController,
                  idController: _idController,
                  passwordController: _passwordController,
                  selectedBatchId: _selectedBatchId,
                  batches: _batches,
                  isLoading: _isLoading,
                  message: _message,
                  students: _students,
                  onBatchChanged: (v) => setState(() => _selectedBatchId = v),
                  onAddStudent: _addStudent,
                  onExportStudents: _exportStudents,
                  onEditStudent: _showEditStudentDialog,
                  onDeleteStudent: _deleteStudent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 