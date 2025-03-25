import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart'; // Use file_picker for web compatibility
import 'dart:io'; // For handling file paths

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: NotesScreen(toggleTheme: _toggleTheme),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final Function toggleTheme;
  NotesScreen({required this.toggleTheme});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Database _database;
  List<Map<String, dynamic>> _notes = [];
  TextEditingController _noteController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  int? _editingId;
  String? _selectedFolder;
  List<String> _folders = ['All', 'Work', 'Personal', 'Shopping'];
  File? _attachedImage;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'notes.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, folder TEXT, imagePath TEXT)",
        );
      },
      version: 1,
    );
    _fetchNotes();
  }

  Future<void> _fetchNotes({String query = '', String folder = 'All'}) async {
    List<Map<String, dynamic>> notes;
    if (query.isEmpty && folder == 'All') {
      notes = await _database.query('notes');
    } else {
      notes = await _database.query(
        'notes',
        where: 'content LIKE ? AND (folder = ? OR ? = ?)',
        whereArgs: ['%$query%', folder, folder, 'All'],
      );
    }
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addOrUpdateNote() async {
    if (_noteController.text.isNotEmpty) {
      if (_editingId == null) {
        await _database.insert('notes', {
          'content': _noteController.text,
          'folder': _selectedFolder ?? 'All',
          'imagePath': _attachedImage?.path,
        });
      } else {
        await _database.update(
          'notes',
          {
            'content': _noteController.text,
            'folder': _selectedFolder ?? 'All',
            'imagePath': _attachedImage?.path,
          },
          where: 'id = ?',
          whereArgs: [_editingId],
        );
        _editingId = null;
      }
      _noteController.clear();
      _attachedImage = null;
      _fetchNotes();
    }
  }

  Future<void> _deleteNote(int id) async {
    await _database.delete('notes', where: 'id = ?', whereArgs: [id]);
    _fetchNotes();
  }

  void _editNote(Map<String, dynamic> note) {
    setState(() {
      _editingId = note['id'];
      _noteController.text = note['content'];
      _selectedFolder = note['folder'];
      if (note['imagePath'] != null) {
        _attachedImage = File(note['imagePath']);
      }
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Allow only image files
    );

    if (result != null) {
      setState(() {
        _attachedImage = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedFolder ?? 'All',
                items: _folders.map((String folder) {
                  return DropdownMenuItem<String>(
                    value: folder,
                    child: Text(folder),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFolder = newValue;
                    _fetchNotes(folder: newValue!);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _fetchNotes(query: _searchController.text),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Enter a note',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _pickImage, // Attach image
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: _addOrUpdateNote,
                  ),
                ],
              ),
            ),
            if (_attachedImage != null)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.file(
                  _attachedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index]['content']),
                    subtitle: _notes[index]['imagePath'] != null
                        ? Image.file(
                      File(_notes[index]['imagePath']),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editNote(_notes[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteNote(_notes[index]['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}