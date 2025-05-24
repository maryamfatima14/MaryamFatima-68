import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as local_user;
import '../services/supabase_service.dart';
import 'manage_students_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<local_user.User> _students = [];
  List<local_user.User> _filteredStudents = [];
  bool _isLoading = false;
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents([String query = '']) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final students = await _supabaseService.getStudents();
      setState(() {
        _students = students;
        _filteredStudents = students
            .where((student) =>
            student.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        debugPrint('Fetched students: ${_students.length}');
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching students: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addStudent() async {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Student Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  debugPrint('Attempting to add student: ${_nameController.text.trim()}');
                  final id = await _supabaseService.addStudent(_nameController.text.trim());
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Student added successfully! ID: $id'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _fetchStudents();
                  }
                } catch (e) {
                  debugPrint('Failed to add student: $e');
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add student: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[700]!, Colors.indigo[300]!],
            stops: const [0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: () => _fetchStudents(),
                    ),
                  ],
                ),
              ),
              // Content Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search Students',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filteredStudents = _students
                                  .where((student) =>
                                  student.name.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _addStudent,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Onboard'), // Changed to "Onboard"
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48), // Consistent height
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ManageStudentsScreen(
                                          onStudentUpdated: _fetchStudents,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.manage_accounts),
                                  label: const Text('Manage'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48), // Consistent height
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Student list or loading/no data state
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _filteredStudents.isEmpty
                            ? const Center(
                          child: Text(
                            'No students found',
                            style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                          ),
                        )
                            : Column(
                          children: _filteredStudents.map((student) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF4CAF50),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width - 150,
                                                  child: Text(
                                                    student.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width - 150,
                                                  child: Text(
                                                    'ID: ${student.id}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black54,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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