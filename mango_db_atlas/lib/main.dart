import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/animation.dart';

void main() {
  runApp(const MyApp());
}

const String apiUrl = 'http://192.168.147.183:5000/journal'; // Replace with your backend URL

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF5E6E8), // Soft blush
        scaffoldBackgroundColor: const Color(0xFFF8F1F1), // Warm ivory
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'ComicNeue', color: Color(0xFF5D4157)), // Deep mauve
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A5A5), // Dusty rose
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFA68DAD)), // Lilac gray
          ),
          labelStyle: TextStyle(color: const Color(0xFF5D4157)), // Deep mauve
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward().whenComplete(() {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: const Text(
            '🌿 Mood Journal',
            style: TextStyle(fontFamily: 'ComicNeue', fontSize: 40, color: Color(0xFF5D4157), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    JournalPage(),
    HistoryScreen(),
    RecommendationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Journal',
          style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5E6E8),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Add Entry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Recommendations',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5D4157),
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFF5E6E8),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> entries = [];

  final Map<String, Color> moodColors = {
    'Happy': const Color(0xFFFCE4EC),
    'Sad': const Color(0xFFD1E8D4),
    'Neutral': const Color(0xFFF9E7B3),
    'Excited': const Color(0xFFD8BFD8),
    'Stressed': const Color(0xFFFADADD),
  };

  Future<void> fetchEntries() async {
    try {
      final res = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          entries = data.map((entry) => {
            'text': entry['text'] as String,
            'mood': entry['mood'] as String,
            'createdAt': DateTime.parse(entry['createdAt'] as String),
            '_id': entry['_id'] as String,
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch entries: Status ${res.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching history: $e')),
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        fetchEntries();
      } else {
        throw Exception('Failed to delete entry: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            color: moodColors[entry['mood']] ?? const Color(0xFFF8F1F1),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                entry['text'],
                style: const TextStyle(fontFamily: 'ComicNeue', color: Color(0xFF5D4157)),
              ),
              subtitle: Text(
                '${entry['mood']} - ${entry['createdAt'].toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12, color: Color(0xFFA68DAD)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFF5D4157)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text('Are you sure you want to delete this entry?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteEntry(entry['_id']);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Map<String, dynamic>> entries = [];
  final Map<String, List<String>> recommendations = const {
    'Happy': [
      'Keep spreading positivity! 🌟',
      'Try sharing your joy with a friend today.',
      'Write down three things you’re grateful for.'
    ],
    'Sad': [
      'Take a moment to breathe deeply. 🌱',
      'Listen to some calming music.',
      'Reach out to a loved one for a chat.'
    ],
    'Neutral': [
      'Try something new today! 🌿',
      'Take a short walk to refresh your mind.',
      'Set a small goal for the day.'
    ],
    'Excited': [
      'Channel that energy into a fun project! ⭐',
      'Share your excitement with someone.',
      'Capture this moment in a journal entry.'
    ],
    'Stressed': [
      'Take a break and stretch. 🌬️',
      'Try a 5-minute meditation session.',
      'Write down what’s on your mind to clear it.'
    ],
  };

  Future<void> fetchEntries() async {
    try {
      final res = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          entries = data.map((entry) => {
            'text': entry['text'] as String,
            'mood': entry['mood'] as String,
            'createdAt': DateTime.parse(entry['createdAt'] as String),
            '_id': entry['_id'] as String,
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch entries: Status ${res.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching entries: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> moodCount = {};
    for (var entry in entries) {
      moodCount[entry['mood']] = (moodCount[entry['mood']] ?? 0) + 1;
    }

    String dominantMood = moodCount.isEmpty
        ? 'Neutral'
        : moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Based on your recent mood: $dominantMood',
            style: const TextStyle(
              fontFamily: 'ComicNeue',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4157),
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations[dominantMood]?.map((rec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '• $rec',
              style: const TextStyle(fontFamily: 'ComicNeue', color: Color(0xFF5D4157)),
            ),
          )) ??
              [],
        ],
      ),
    );
  }
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> entries = [];
  final TextEditingController controller = TextEditingController();
  String selectedMood = 'Happy';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> moods = ['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'];

  final Map<String, Color> moodColors = {
    'Happy': const Color(0xFFFCE4EC),
    'Sad': const Color(0xFFD1E8D4),
    'Neutral': const Color(0xFFF9E7B3),
    'Excited': const Color(0xFFD8BFD8),
    'Stressed': const Color(0xFFFADADD),
  };

  final Map<String, String> moodEmojis = {
    'Happy': '🌸',
    'Sad': '💧',
    'Neutral': '🌿',
    'Excited': '⭐',
    'Stressed': '🌪️',
  };

  Future<void> fetchEntries() async {
    try {
      final res = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          entries = data.map((entry) => {
            'text': entry['text'] as String,
            'mood': entry['mood'] as String,
            'createdAt': DateTime.parse(entry['createdAt'] as String),
            '_id': entry['_id'] as String,
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch entries: Status ${res.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching entries: $e')),
      );
    }
  }

  Future<void> addEntry(String text, String mood) async {
    try {
      _animationController.reverse();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text, 'mood': mood}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        fetchEntries();
        controller.clear();
        setState(() {
          selectedMood = 'Happy';
        });
      } else {
        throw Exception('Failed to add entry: ${response.statusCode}');
      }
    } catch (e) {
      print('Add entry error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    }
  }

  Future<void> updateEntry(String id, String text, String mood) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text, 'mood': mood}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        fetchEntries();
      } else {
        throw Exception('Failed to update entry: ${response.statusCode}');
      }
    } catch (e) {
      print('Update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating entry: $e')),
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        fetchEntries();
      } else {
        throw Exception('Failed to delete entry: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
    fetchEntries();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'How are you feeling today? 🌸',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedMood,
            decoration: InputDecoration(
              labelText: 'Select Mood',
            ),
            items: moods.map((mood) {
              return DropdownMenuItem(
                value: mood,
                child: Text(mood, style: TextStyle(color: const Color(0xFF5D4157))),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMood = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _animationController.forward();
                      addEntry(controller.text.trim(), selectedMood);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a journal entry')),
                      );
                    }
                  },
                  onHover: (isHovering) {
                    if (mounted && isHovering) {
                      _animationController.forward();
                    }
                  },
                  icon: Text(
                    moodEmojis[selectedMood] ?? '🌸',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  label: const Text('Save Entry', style: TextStyle(color: Colors.white)),
                  iconAlignment: IconAlignment.start,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  color: moodColors[entry['mood']] ?? const Color(0xFFF8F1F1),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      entry['text'],
                      style: const TextStyle(fontFamily: 'ComicNeue', color: Color(0xFF5D4157)),
                    ),
                    subtitle: Text(
                      '${entry['mood']} - ${entry['createdAt'].toLocal().toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFA68DAD)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF5D4157)),
                          onPressed: () async {
                            TextEditingController editController = TextEditingController(text: entry['text']);
                            String newMood = entry['mood'];
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Edit Entry'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: editController,
                                      decoration: const InputDecoration(labelText: 'Edit text'),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: newMood,
                                      items: moods.map((mood) => DropdownMenuItem(value: mood, child: Text(mood))).toList(),
                                      onChanged: (value) => newMood = value!,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      updateEntry(entry['_id'], editController.text.trim(), newMood);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFF5D4157)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this entry?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteEntry(entry['_id']);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
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