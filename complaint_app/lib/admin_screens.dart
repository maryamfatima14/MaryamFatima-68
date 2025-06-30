import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'utils/save_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';

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

  Widget _buildSimplifiedLayout(BuildContext context, List<Map<String, dynamic>> featuresToShow) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 0, top: 0, bottom: 0),
              child: Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFEAEFEF),
                size: 38,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 8),
                Text(
                  'Welcome to',
                  style: TextStyle(
                    color: Color(0xFFEAEFEF),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Color(0xFFEAEFEF),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFEAEFEF), size: 26),
              onPressed: () => _showAdminMenu(context),
              tooltip: 'Menu',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Avatar section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF52357B), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/animations/admin.png'),
                  ),
                ),
              ),
            ),
            // Grid content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: featuresToShow.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.18,
                  ),
                  itemBuilder: (context, index) {
                    final feature = featuresToShow[index];
                    if (feature['dummy'] == true) {
                      return const SizedBox.shrink();
                    }
                    return _AdminFeatureTileLight(
                      icon: feature['icon'] as IconData,
                      title: feature['title'] as String,
                      onTap: feature['onTap'] as VoidCallback,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.analytics,
        'title': 'Status',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStatusScreen())),
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
      {
        'icon': Icons.group,
        'title': 'Students',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentsScreen())),
      },
      {
        'icon': Icons.manage_accounts,
        'title': 'Fix User Accounts',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => FixUserAccountsScreen())),
      },
    ];

    // Center the last tile if odd number of tiles
    List<Map<String, dynamic>> featuresToShow = List.from(features);
    if (featuresToShow.length % 2 == 1) {
      featuresToShow.add({'dummy': true});
    }

    return _buildSimplifiedLayout(context, featuresToShow);
  }
}

class _AdminFeatureTileLight extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _AdminFeatureTileLight({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF52357B).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Color(0xFF52357B).withOpacity(0.10), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Color(0xFFEAEFEF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Color(0xFF52357B), size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF52357B),
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
  static const LatLng _center = LatLng(30.0419, 72.3556);
  bool _isSharingLocation = false;

  Future<void> _shareLocation() async {
    setState(() => _isSharingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isSharingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.'), backgroundColor: Colors.red),
        );
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isSharingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.'), backgroundColor: Colors.red),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isSharingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.'), backgroundColor: Colors.red),
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final url = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      await Share.share('My location: $url');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share location: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSharingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF52357B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuTile('Location', 0, icon: Icons.location_on),
          GestureDetector(
            onTap: _isSharingLocation ? null : _shareLocation,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF52357B).withOpacity(0.18), width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(Icons.share_location, color: const Color(0xFF52357B)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _isSharingLocation ? 'Sharing Location...' : 'Share Location',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF52357B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_isSharingLocation)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF52357B)),
                    ),
                  if (!_isSharingLocation)
                    Icon(Icons.arrow_forward_ios, size: 18, color: const Color(0xFF52357B)),
                ],
              ),
            ),
          ),
          _buildMenuTile('Privacy Policy', 1, icon: Icons.privacy_tip),
          _buildMenuTile('Logout', 2, icon: Icons.logout),
          const SizedBox(height: 16),
          if (_selectedIndex == 0)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEFEF).withOpacity(0.10),
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
                          child: const Icon(Icons.location_pin, color: Color(0xFFEAEFEF), size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedIndex == 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEFEF).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Your privacy is important. We do not share your data with third parties. All information is kept confidential.',
                style: TextStyle(fontSize: 15, color: Color(0xFFEAEFEF)),
              ),
            ),
          if (_selectedIndex == 2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEFEF).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Logout from the admin panel.',
                style: TextStyle(fontSize: 15, color: Color(0xFFEAEFEF)),
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
        if (title == 'Logout') {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF52357B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF52357B).withOpacity(0.18), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF52357B)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : const Color(0xFF52357B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: isSelected ? Colors.white : const Color(0xFF52357B)),
          ],
        ),
      ),
    );
  }
}

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});
  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _hods = [];
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
      final hods = await _client
          .from('hods_view')
          .select('*')
          .order('username');
      setState(() => _hods = List<Map<String, dynamic>>.from(hods));
    } catch (e) {
      setState(() => _error = 'Failed to load HODs: $e');
    }
  }

  void _showAddDepartmentDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    Map<String, dynamic>? selectedHOD;

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
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedHOD,
                decoration: const InputDecoration(labelText: 'Assign HOD (Optional)'),
                items: _hods.map((hod) => DropdownMenuItem(
                  value: hod,
                  child: Text(hod['username'] ?? ''),
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
                      'hod_id': selectedHOD?['id']?.toString(),
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
    Map<String, dynamic>? selectedHOD = department['hod'] != null
      ? _hods.firstWhereOrNull((hod) => hod['id'] == department['hod']['id'])
      : null;

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
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedHOD,
                decoration: const InputDecoration(labelText: 'Assign HOD (Optional)'),
                items: _hods.map((hod) => DropdownMenuItem(
                  value: hod,
                  child: Text(hod['username'] ?? ''),
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
                      'hod_id': selectedHOD?['id']?.toString(),
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
      body: SafeArea(
        child: _isLoading
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
                    : _buildDepartmentList(),
      ),
    );
  }

  Widget _buildDepartmentList() {
    return ListView.builder(
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
  List<Map<String, dynamic>> _batchAdvisors = [];
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
      final advisors = await _client
          .from('users')
          .select('id, username, full_name')
          .eq('role', 'BatchAdvisor')
          .order('username');
      print('Loaded ${advisors.length} batch advisors');
      setState(() => _batchAdvisors = List<Map<String, dynamic>>.from(advisors));
    } catch (e) {
      print('Error loading batch advisors: $e');
      setState(() => _batchAdvisors = []);
    }
  }

  int _getAssignedBatchAdvisorsCount() {
    try {
      final assignedAdvisorIds = _batches
          .where((b) => b['batch_advisor'] != null && b['batch_advisor']['id'] != null)
          .map((b) => b['batch_advisor']['id'])
          .toSet();
      return assignedAdvisorIds.length;
    } catch (e) {
      print('Error calculating assigned batch advisors: $e');
      return 0;
    }
  }

  void _showAddBatchDialog() {
    final nameController = TextEditingController();
    final yearController = TextEditingController();
    Map<String, dynamic>? selectedDepartment;
    Map<String, dynamic>? selectedAdvisor;

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
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedAdvisor,
                decoration: const InputDecoration(labelText: 'Assign Batch Advisor (Optional)'),
                items: _batchAdvisors.map((advisor) => DropdownMenuItem(
                  value: advisor,
                  child: Text(advisor['username']),
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
                      'department_id': selectedDepartment!['id'].toString(),
                      'batch_advisor_id': selectedAdvisor?['id']?.toString(),
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
    Map<String, dynamic>? selectedDepartment = _departments.firstWhereOrNull(
      (dept) => dept['id'] == batch['department']['id'],
    );
    Map<String, dynamic>? selectedAdvisor = batch['batch_advisor'] != null
      ? _batchAdvisors.firstWhereOrNull((advisor) => advisor['id'] == batch['batch_advisor']['id'])
      : null;

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
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedAdvisor,
                decoration: const InputDecoration(labelText: 'Assign Batch Advisor (Optional)'),
                items: _batchAdvisors.map((advisor) => DropdownMenuItem(
                  value: advisor,
                  child: Text(advisor['username']),
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
                      'department_id': selectedDepartment!['id'].toString(),
                      'batch_advisor_id': selectedAdvisor?['id']?.toString(),
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
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        actions: [
          IconButton(
            onPressed: _loadBatches,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : _batches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.school, size: 60, color: Colors.pink),
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
                    : _buildBatchList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBatchDialog,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBatchList() {
    return ListView.builder(
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
                if (batch['academic_year'] != null) Text('Year: ${batch['academic_year']}'),
                if (batch['department'] != null) Text('Department: ${batch['department']['name']}'),
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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  Map<String, dynamic>? _selectedDepartment;
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = false;
  String _message = '';
  List<Map<String, dynamic>> _hods = [];
  String? _lastExportedHODsFilePath;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadHODs();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _client.from('departments').select('*').order('name');
      setState(() => _departments = List<Map<String, dynamic>>.from(departments));
    } catch (e) {
      setState(() => _message = 'Failed to load departments: $e');
    }
  }

  Future<void> _loadHODs() async {
    try {
      final hods = await _client
          .from('hods_view')
          .select('*')
          .order('username');
      setState(() => _hods = List<Map<String, dynamic>>.from(hods));
    } catch (e) {
      setState(() => _message = 'Failed to load HODs: $e');
    }
  }

  Future<void> _createHODAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _message = ''; });
    try {
      await _client.from('users').insert({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': 'HOD',
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'department_id': _selectedDepartment?['id']?.toString(),
      });
      setState(() { _message = 'HOD account created successfully!'; });
      _usernameController.clear();
      _passwordController.clear();
      _fullNameController.clear();
      _emailController.clear();
      _selectedDepartment = null;
      await _loadHODs();
    } catch (e) {
      setState(() { _message = 'Failed to create HOD account: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _exportHODs() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      final hods = await _client
          .from('users')
          .select('username, full_name, email, department:department_id(name)')
          .eq('role', 'HOD');
      final departmentMap = {for (var d in _departments) d['id']: d['name']};
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['HODs'];
      sheet.appendRow(['Username', 'Full Name', 'Email', 'Department']);
      for (var hod in hods) {
        sheet.appendRow([
          hod['username'] ?? '',
          hod['full_name'] ?? '',
          hod['email'] ?? '',
          hod['department']?['name'] ?? '',
        ]);
      }
      final bytes = excelFile.encode();
      if (kIsWeb) {
        saveFileWeb(Uint8List.fromList(bytes!), 'hods_export.xlsx');
        setState(() { _message = 'File downloaded!'; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/hods_export.xlsx');
        await file.writeAsBytes(bytes!);
        setState(() {
          _message = 'File saved at: ${file.path}';
          _lastExportedHODsFilePath = file.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved at: ${file.path}'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setState(() { _message = 'Export failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showEditHODDialog(Map<String, dynamic> hod) {
    final usernameController = TextEditingController(text: hod['username'] ?? '');
    final fullNameController = TextEditingController(text: hod['full_name'] ?? '');
    final emailController = TextEditingController(text: hod['email'] ?? '');
    Map<String, dynamic>? selectedDepartment = hod['department'] != null
      ? _departments.firstWhereOrNull((dept) => dept['id'] == hod['department']['id'])
      : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit HOD'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department (Optional)'),
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
                onChanged: (dept) => setDialogState(() => selectedDepartment = dept),
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
                    'username': usernameController.text.trim(),
                    'full_name': fullNameController.text.trim(),
                    'email': emailController.text.trim(),
                    'department_id': selectedDepartment?['id']?.toString(),
                  }).eq('id', hod['id']);
                  Navigator.pop(context);
                  await _loadHODs();
                  setState(() { _message = 'HOD updated successfully!'; });
                } catch (e) {
                  setState(() { _message = 'Update failed: $e'; });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteHOD(String hodId) async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      await _client.from('users').delete().eq('id', hodId);
      await _loadHODs();
      setState(() { _message = 'HOD deleted successfully!'; });
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
        title: const Text('Create HOD Accounts'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create HOD Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedDepartment,
                          decoration: const InputDecoration(labelText: 'Department (Optional)'),
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createHODAccount,
                          child: const Text('Create HOD Account'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _exportHODs,
                          icon: const Icon(Icons.download),
                          label: const Text('Export HODs'),
                        ),
                        if (_lastExportedHODsFilePath != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await OpenFile.open(_lastExportedHODsFilePath!);
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open Exported File'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        if (_isLoading) ...[
                          const SizedBox(height: 20),
                          const LinearProgressIndicator(),
                        ],
                        if (_message.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(_message, style: TextStyle(color: _message.contains('success') ? Colors.green : Colors.red)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All HODs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_hods.isEmpty)
                        const Center(child: Text('No HODs found.'))
                      else
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: _hods.length,
                            itemBuilder: (context, index) {
                              final hod = _hods[index];
                              return Card(
                                child: ListTile(
                                  title: Text(hod['full_name'] ?? ''),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Username: ${hod['username'] ?? ''}'),
                                      if (hod['email'] != null) Text('Email: ${hod['email']}'),
                                      if (hod['department_id'] != null) Text('Department ID: ${hod['department_id']}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditHODDialog(hod),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteHOD(hod['id']),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStatusScreen extends StatefulWidget {
  const AdminStatusScreen({super.key});
  @override
  State<AdminStatusScreen> createState() => _AdminStatusScreenState();
}

class _AdminStatusScreenState extends State<AdminStatusScreen> {
  Map<String, dynamic> _stats = {};
  Map<String, List<Map<String, dynamic>>> _userLists = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _client.from('users').select('*').inFilter('role', ['Student', 'CR', 'GR']),
        _client.from('users').select('*').eq('role', 'HOD'),
        _client.from('users').select('*').eq('role', 'BatchAdvisor'),
        _client.from('departments').select('id'),
        _client.from('batches').select('id'),
        _client.from('complaints').select('status'),
      ]);

      final students = results[0] as List;
      final hods = results[1] as List;
      final advisors = results[2] as List;
      final departmentCount = results[3].length;
      final batchCount = results[4].length;
      
      final complaints = results[5] as List;
      final totalComplaints = complaints.length;
      final pendingComplaints = complaints.where((c) => c['status'] == 'Pending').length;
      final resolvedComplaints = complaints.where((c) => c['status'] == 'Resolved').length;

      setState(() {
        _stats = {
          'students': students.length,
          'hods': hods.length,
          'advisors': advisors.length,
          'departments': departmentCount,
          'batches': batchCount,
          'totalComplaints': totalComplaints,
          'pendingComplaints': pendingComplaints,
          'resolvedComplaints': resolvedComplaints,
        };
        
        _userLists = {
          'students': List<Map<String, dynamic>>.from(students),
          'hods': List<Map<String, dynamic>>.from(hods),
          'advisors': List<Map<String, dynamic>>.from(advisors),
        };
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Status'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEAEFEF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : SingleChildScrollView(
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
                                  'User Statistics',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard('Students', _stats['students'] ?? 0, Colors.blue),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildStatCard('HODs', _stats['hods'] ?? 0, Colors.green),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard('Batch Advisors', _stats['advisors'] ?? 0, Colors.orange),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(),
                                    ),
                                  ],
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
                                  'System Statistics',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard('Departments', _stats['departments'] ?? 0, Colors.purple),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildStatCard('Batches', _stats['batches'] ?? 0, Colors.teal),
                                    ),
                                  ],
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
                                  'Complaint Statistics',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard('Total', _stats['totalComplaints'] ?? 0, Colors.indigo),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildStatCard('Pending', _stats['pendingComplaints'] ?? 0, Colors.orange),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard('Resolved', _stats['resolvedComplaints'] ?? 0, Colors.green),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

  void _showUserDetails(String userType) {
    final users = _userLists[userType] ?? [];
    final title = userType == 'students' ? 'Students' : 
                  userType == 'hods' ? 'HODs' : 
                  userType == 'advisors' ? 'Batch Advisors' : 'Users';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title (${users.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final createdAt = DateTime.parse(user['created_at'] ?? DateTime.now().toIso8601String());
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          user['username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role: ${user['role'] ?? 'Unknown'}'),
                            Text('Created: ${createdAt.toString().substring(0, 10)}'),
                            if (user['full_name'] != null) Text('Name: ${user['full_name']}'),
                            if (user['email'] != null) Text('Email: ${user['email']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
          final localCreated = createdAt.toLocal();
          return localCreated.year == now.year &&
                 localCreated.month == now.month &&
                 localCreated.day == now.day;
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return createdAt.isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day));
        case 'This Month':
          return createdAt.isAfter(DateTime(now.year, now.month, 1));
        default:
          return true;
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
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
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

class ImportDataScreen extends StatefulWidget {
  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  bool _isUploading = false;
  String? _selectedFile;
  List<List<dynamic>> _excelRows = [];
  String _uploadSummary = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBatchId;
  List<Map<String, dynamic>> _batches = [];
  bool _isLoading = false;
  String _message = '';
  List<Map<String, dynamic>> _students = [];
  String? _lastExportedFilePath;

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
      final students = await _client
          .from('users')
          .select('id, full_name, roll_number, batch_id, role')
          .inFilter('role', ['Student', 'CR', 'GR'])
          .order('full_name');
      setState(() => _students = List<Map<String, dynamic>>.from(students));
    } catch (e) {
      setState(() => _message = 'Failed to load students: $e');
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _message = ''; });
    try {
      if (_selectedBatchId == null) {
        setState(() { _message = 'Please select a batch!'; _isLoading = false; });
        return;
      }
      final batch = await _client
          .from('batches')
          .select('department_id')
          .eq('id', _selectedBatchId!.toString())
          .maybeSingle();
      final departmentId = batch?['department_id'];
      if (departmentId == null) {
        setState(() { _message = 'Selected batch has no department assigned!'; _isLoading = false; });
        return;
      }

      await _client.from('users').insert({
        'username': _idController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': 'Student',
        'batch_id': _selectedBatchId!.toString(),
        'department_id': departmentId.toString(),
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
      final students = await _client
          .from('users')
          .select('full_name, roll_number, batch_id, role')
          .inFilter('role', ['Student', 'CR', 'GR'])
          .order('full_name');
      final batchMap = {for (var b in _batches) b['id']: b['name']};
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Students'];
      sheet.appendRow(['Name', 'ID', 'Batch', 'Role']);
      for (var s in students) {
        sheet.appendRow([
          s['full_name'] ?? '',
          s['roll_number'] ?? '',
          batchMap[s['batch_id']] ?? '',
          s['role'] ?? '',
        ]);
      }
      final bytes = excelFile.encode();
      if (kIsWeb) {
        saveFileWeb(Uint8List.fromList(bytes!), 'students_export.xlsx');
        setState(() { _message = 'File downloaded!'; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/students_export.xlsx');
        await file.writeAsBytes(bytes!);
        setState(() {
          _message = 'File saved at: ${file.path}';
          _lastExportedFilePath = file.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved at: ${file.path}'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setState(() { _message = 'Export failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _fixStudentDepartmentIds() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      final studentsWithoutDept = await _client
          .from('users')
          .select('id, batch_id')
          .inFilter('role', ['Student', 'CR', 'GR'])
          .or('department_id.is.null');
      
      int fixedCount = 0;
      for (final student in studentsWithoutDept) {
        if (student['batch_id'] != null) {
          final batch = await _client
              .from('batches')
              .select('department_id')
              .eq('id', student['batch_id'])
              .maybeSingle();
          
          if (batch != null && batch['department_id'] != null) {
            await _client
                .from('users')
                .update({'department_id': batch['department_id'].toString()})
                .eq('id', student['id']);
            fixedCount++;
          }
        }
      }
      
      setState(() { 
        _message = 'Fixed department_id for $fixedCount students!'; 
        _isLoading = false; 
      });
      
      await _loadStudents();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fixed department_id for $fixedCount students!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() { 
        _message = 'Failed to fix department_ids: $e'; 
        _isLoading = false; 
      });
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
                String? departmentId;
                if (selectedBatchId != null) {
                  final batch = await _client
                      .from('batches')
                      .select('department_id')
                      .eq('id', selectedBatchId!.toString())
                      .maybeSingle();
                  departmentId = batch?['department_id'];
                }

                await _client.from('users').update({
                  'full_name': nameController.text.trim(),
                  'roll_number': idController.text.trim(),
                  'password': _passwordController.text.trim(),
                  'batch_id': selectedBatchId?.toString(),
                  'department_id': departmentId?.toString(),
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
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
        ),
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
  final VoidCallback onFixDepartmentIds;
  final void Function(Map<String, dynamic>) onEditStudent;
  final void Function(String) onDeleteStudent;
  final String? lastExportedFilePath;
  final VoidCallback? onOpenExportedFile;

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
    required this.onFixDepartmentIds,
    required this.onEditStudent,
    required this.onDeleteStudent,
    this.lastExportedFilePath,
    this.onOpenExportedFile,
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onFixDepartmentIds,
                  icon: const Icon(Icons.build),
                  label: const Text('Fix Department IDs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
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
                      subtitle: Text('ID: ${s['roll_number'] ?? ''} | Batch: $batchName | Role: ${s['role'] ?? 'Student'}'),
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

class FixUserAccountsScreen extends StatefulWidget {
  const FixUserAccountsScreen({super.key});
  @override
  State<FixUserAccountsScreen> createState() => _FixUserAccountsScreenState();
}

class _FixUserAccountsScreenState extends State<FixUserAccountsScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      final users = await _client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      setState(() {
        _users = List<Map<String, dynamic>>.from(users);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { 
        _isLoading = false; 
        _message = 'Failed to load users: $e'; 
      });
    }
  }

  Future<void> _fixBatchAdvisorRole(String userId, String username) async {
    try {
      await _client
          .from('users')
          .update({'role': 'BatchAdvisor'})
          .eq('id', userId);
      
      setState(() { _message = 'Fixed role for user: $username'; });
      await _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully fixed role for $username'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() { _message = 'Failed to fix role: $e'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fix role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId, String username) async {
    try {
      await _client.from('users').delete().eq('id', userId);
      setState(() { _message = 'Deleted user: $username'; });
      await _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted user: $username'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() { _message = 'Failed to delete user: $e'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fix User Accounts'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Account Issues',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This screen helps you identify and fix user account issues. Look for users with incorrect roles or other problems.',
                              style: TextStyle(fontSize: 14),
                            ),
                            if (_message.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _message,
                                style: TextStyle(
                                  color: _message.contains('Failed') ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                              'All Users',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (_users.isEmpty)
                              const Center(child: Text('No users found.'))
                            else
                              ..._users.map((user) => _buildUserCard(user)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final username = user['username'] ?? '';
    final role = user['role'] ?? '';
    final createdAt = DateTime.parse(user['created_at'] ?? DateTime.now().toIso8601String());
    
    final hasIssues = role.isEmpty || 
                     (username.contains('teacher') && role != 'BatchAdvisor') ||
                     (username.contains('@') && !username.contains('@university.com'));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: hasIssues ? Colors.orange.withOpacity(0.1) : null,
      child: ListTile(
        title: Text(
          username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasIssues ? Colors.orange[800] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: $role'),
            Text('Created: ${createdAt.toString().substring(0, 10)}'),
            if (hasIssues)
              Text(
                '⚠️ Potential issue detected',
                style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (username.contains('teacher') && role != 'BatchAdvisor')
              IconButton(
                icon: const Icon(Icons.build, color: Colors.blue),
                tooltip: 'Fix role to BatchAdvisor',
                onPressed: () => _fixBatchAdvisorRole(user['id'], username),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete user',
              onPressed: () => _showDeleteConfirmation(user['id'], username),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user: $username?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(userId, username);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class StudentsScreen extends StatefulWidget {
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBatchId;
  List<Map<String, dynamic>> _batches = [];
  bool _isLoading = false;
  String _message = '';
  List<Map<String, dynamic>> _students = [];
  String? _lastExportedFilePath;

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
      final students = await _client
          .from('users')
          .select('id, full_name, roll_number, batch_id, role')
          .inFilter('role', ['Student', 'CR', 'GR'])
          .order('full_name');
      setState(() => _students = List<Map<String, dynamic>>.from(students));
    } catch (e) {
      setState(() => _message = 'Failed to load students: $e');
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _message = ''; });
    try {
      if (_selectedBatchId == null) {
        setState(() { _message = 'Please select a batch!'; _isLoading = false; });
        return;
      }
      final batch = await _client
          .from('batches')
          .select('department_id')
          .eq('id', _selectedBatchId!.toString())
          .maybeSingle();
      final departmentId = batch?['department_id'];
      if (departmentId == null) {
        setState(() { _message = 'Selected batch has no department assigned!'; _isLoading = false; });
        return;
      }

      await _client.from('users').insert({
        'username': _idController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': 'Student',
        'batch_id': _selectedBatchId!.toString(),
        'department_id': departmentId.toString(),
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
      final students = await _client
          .from('users')
          .select('full_name, roll_number, batch_id, role')
          .inFilter('role', ['Student', 'CR', 'GR'])
          .order('full_name');
      final batchMap = {for (var b in _batches) b['id']: b['name']};
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Students'];
      sheet.appendRow(['Name', 'ID', 'Batch', 'Role']);
      for (var s in students) {
        sheet.appendRow([
          s['full_name'] ?? '',
          s['roll_number'] ?? '',
          batchMap[s['batch_id']] ?? '',
          s['role'] ?? '',
        ]);
      }
      final bytes = excelFile.encode();
      if (kIsWeb) {
        saveFileWeb(Uint8List.fromList(bytes!), 'students_export.xlsx');
        setState(() { _message = 'File downloaded!'; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/students_export.xlsx');
        await file.writeAsBytes(bytes!);
        setState(() {
          _message = 'File saved at: ${file.path}';
          _lastExportedFilePath = file.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved at: ${file.path}'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setState(() { _message = 'Export failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _fixStudentDepartmentIds() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      final studentsWithoutDept = await _client
          .from('users')
          .select('id, batch_id')
          .inFilter('role', ['Student', 'CR', 'GR'])
          .or('department_id.is.null');
      
      int fixedCount = 0;
      for (final student in studentsWithoutDept) {
        if (student['batch_id'] != null) {
          final batch = await _client
              .from('batches')
              .select('department_id')
              .eq('id', student['batch_id'])
              .maybeSingle();
          
          if (batch != null && batch['department_id'] != null) {
            await _client
                .from('users')
                .update({'department_id': batch['department_id'].toString()})
                .eq('id', student['id']);
            fixedCount++;
          }
        }
      }
      
      setState(() { 
        _message = 'Fixed department_id for $fixedCount students!'; 
        _isLoading = false; 
      });
      
      await _loadStudents();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fixed department_id for $fixedCount students!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() { 
        _message = 'Failed to fix department_ids: $e'; 
        _isLoading = false; 
      });
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
                String? departmentId;
                if (selectedBatchId != null) {
                  final batch = await _client
                      .from('batches')
                      .select('department_id')
                      .eq('id', selectedBatchId!.toString())
                      .maybeSingle();
                  departmentId = batch?['department_id'];
                }

                await _client.from('users').update({
                  'full_name': nameController.text.trim(),
                  'roll_number': idController.text.trim(),
                  'password': _passwordController.text.trim(),
                  'batch_id': selectedBatchId?.toString(),
                  'department_id': departmentId?.toString(),
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
        title: const Text('Students'),
        backgroundColor: const Color(0xFF52357B),
        foregroundColor: const Color(0xFFEAEFEF),
      ),
      backgroundColor: const Color(0xFFE0E1DD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                onFixDepartmentIds: _fixStudentDepartmentIds,
                onEditStudent: _showEditStudentDialog,
                onDeleteStudent: _deleteStudent,
                lastExportedFilePath: _lastExportedFilePath,
                onOpenExportedFile: () async {
                  if (_lastExportedFilePath != null) {
                    await OpenFile.open(_lastExportedFilePath!);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
