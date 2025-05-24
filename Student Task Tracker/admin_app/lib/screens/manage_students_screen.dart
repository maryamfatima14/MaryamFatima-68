import 'dart:convert';
import 'dart:io' show Platform, Directory, File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../models/user.dart' as local_user;
import '../services/supabase_service.dart';

class ManageStudentsScreen extends StatefulWidget {
  final VoidCallback onStudentUpdated;

  const ManageStudentsScreen({super.key, required this.onStudentUpdated});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  List<local_user.User> _students = [];
  bool _isLoading = false;
  String? _lastExportedFilePath;
  late final SupabaseService _supabaseService;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _manualNameController = TextEditingController();
  final _manualFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    try {
      _supabaseService = SupabaseService();
    } catch (e) {
      debugPrint('Failed to initialize SupabaseService: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error initializing service: $e')));
    }
    _fetchStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      return true;
    }
    return true;
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _supabaseService.getStudents();
      debugPrint('Fetched ${students.length} students');
      if (mounted) {
        setState(() {
          _students = students;
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching students: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportStudentsToExcel() async {
    if (_students.isEmpty) {
      debugPrint('No students to export: _students list is empty');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No students to export')));
      return;
    }

    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      debugPrint('Storage permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied. Cannot export file.')),
      );
      return;
    }

    debugPrint('Starting export for ${_students.length} students');
    var excel = Excel.createExcel();
    var sheet = excel['Students'];
    sheet.appendRow(<CellValue?>[
      TextCellValue('Name'),
      TextCellValue('Key ID'),
    ]);

    try {
      for (var student in _students) {
        debugPrint('Exporting student: ${student.name}, Key ID: ${student.keyId}');
        sheet.appendRow(<CellValue?>[
          TextCellValue(student.name),
          TextCellValue(student.keyId ?? 'N/A'),
        ]);
      }

      var fileBytes = excel.encode();
      if (fileBytes == null || fileBytes.isEmpty) {
        debugPrint('Excel encoding failed: fileBytes is null or empty');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to encode Excel file')));
        return;
      }

      debugPrint('Encoded Excel file: ${fileBytes.length} bytes');
      final fileName = 'students_${DateTime.now().toIso8601String()}.xlsx';
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          final directory = await getExternalStorageDirectory();
          if (directory == null) {
            debugPrint('Could not access external storage directory');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not access storage directory')),
            );
            return;
          }

          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);
          debugPrint('File saved to: $filePath');
          setState(() {
            _lastExportedFilePath = filePath;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported successfully to: $filePath')),
          );
        } else {
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: Uint8List.fromList(fileBytes),
            ext: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
          debugPrint('File saved successfully via FileSaver: $fileName');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported successfully')));
        }
      } catch (e) {
        debugPrint('Error saving file: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
      }
    } catch (e) {
      debugPrint('Error during export process: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting students: $e')));
    }
  }

  Future<void> _openLastExportedFile() async {
    if (_lastExportedFilePath != null && await File(_lastExportedFilePath!).exists()) {
      final result = await OpenFile.open(_lastExportedFilePath!);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file available to open')),
      );
    }
  }

  Future<void> _addStudentManually() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student Manually'),
        content: SingleChildScrollView(
          child: Form(
            key: _manualFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _manualNameController,
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
                const SizedBox(height: 16),
                const Text(
                  'Login ID will be automatically generated (e.g., CSA-001)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _manualNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_manualFormKey.currentState!.validate()) {
                try {
                  await _supabaseService.addStudent(
                    _manualNameController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student added successfully')));
                    _manualNameController.clear();
                    _fetchStudents();
                    widget.onStudentUpdated();
                  }
                } catch (e) {
                  debugPrint('Error adding student: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding student: $e')));
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editStudent(local_user.User student) async {
    _nameController.text = student.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
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
                const SizedBox(height: 16),
                Text(
                  'Key ID: ${student.keyId} (cannot be edited)', // Updated to show Key ID
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _supabaseService.updateStudent(
                    student.id,
                    _nameController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated successfully')));
                    _fetchStudents();
                    widget.onStudentUpdated();
                  }
                } catch (e) {
                  debugPrint('Error updating student: $e');
                  if (e.toString().contains('duplicate key value violates unique constraint')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: Key ID must be unique')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating student: $e')));
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteStudent(id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted successfully')));
                  _fetchStudents();
                  widget.onStudentUpdated();
                }
              } catch (e) {
                debugPrint('Error deleting student: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting student: $e')));
                }
              }
            },
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkUploadStudents() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      final file = result.files.single;
      if (file.bytes == null) {
        debugPrint('File content is empty or not accessible');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File content is empty or not accessible')),
        );
        return;
      }

      final excel = Excel.decodeBytes(file.bytes!);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null || sheet.rows.isEmpty) {
        debugPrint('Invalid Excel format: No data found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Excel format: No data found')),
        );
        return;
      }

      final headers = sheet.rows.first.map((cell) => cell?.value?.toString().trim().toLowerCase()).toList();
      if (headers.length < 2 || headers[0] != 'name' || headers[1] != 'original id') {
        debugPrint('Invalid Excel format: Expected headers "name" and "original id"');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Excel format: First two columns must be "name" and "original id"')),
        );
        return;
      }

      List<Map<String, String>> students = [];
      for (var row in sheet.rows.skip(1)) {
        if (row.length >= 2 && row[0]?.value != null) {
          final name = row[0]!.value.toString().trim();
          final originalId = row[1]?.value?.toString().trim() ?? '';
          if (name.isNotEmpty) {
            final student = {
              'name': name,
              'ORIGINAL ID': originalId,
            };
            students.add(student);
            debugPrint('Parsed student: $student');
          }
        }
      }

      if (students.isEmpty) {
        debugPrint('No valid student data found in Excel after parsing');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid student data found in Excel')),
        );
        return;
      }

      try {
        debugPrint('Uploading ${students.length} students to Supabase');
        await _supabaseService.bulkUploadStudents(students);
        debugPrint('Bulk uploaded ${students.length} students');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Students uploaded successfully')),
        );
        _fetchStudents();
        widget.onStudentUpdated();
      } catch (e) {
        debugPrint('Error uploading students: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading students: $e')),
        );
      }
    } else {
      debugPrint('No file selected for bulk upload');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
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
                      'Manage Students',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _fetchStudents,
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: _addStudentManually,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Student Manually'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: _bulkUploadStudents,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Bulk Upload Students via Excel'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: _exportStudentsToExcel,
                            icon: const Icon(Icons.download),
                            label: const Text('Export Students'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        if (_lastExportedFilePath != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: _openLastExportedFile,
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Open Last Exported File'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _students.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No students found',
                              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return Card(
                              child: ListTile(
                                title: Text(student.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${student.id}'),
                                    Text('Key ID: ${student.keyId}'), // Updated to show Key ID
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editStudent(student),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteStudent(student.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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