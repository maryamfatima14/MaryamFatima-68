import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart'; // Fixed typo: 'supabase_services.dart' to 'supabase_service.dart'
import '../services/supabase_services.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart'; // Assuming AppColors is defined here
import 'notification_settings_screen.dart'; // Assuming this exists

class TaskListScreen extends StatefulWidget {
  final String studentId;
  const TaskListScreen({super.key, required this.studentId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  String _filter = 'all';
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _supabaseService.subscribeToTasks((updatedTasks) {
      setState(() {
        _tasks = updatedTasks.where((task) => task.assignedTo == widget.studentId).toList();
      });
    });
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tasks = await _supabaseService.getTasksForStudent(widget.studentId);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markTaskComplete(Task task) async {
    try {
      await Supabase.instance.client
          .from('tasks')
          .update({'status': 'completed'})
          .eq('id', task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task marked as completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<Task> get _filteredTasks {
    if (_filter == 'pending') {
      return _tasks.where((task) => task.status == 'pending').toList();
    } else if (_filter == 'completed') {
      return _tasks.where((task) => task.status == 'completed').toList();
    }
    return _tasks;
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
                      'My Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationSettingsScreen(
                                  notificationsEnabled: _notificationsEnabled,
                                ),
                              ),
                            );
                            if (result != null && result is bool) {
                              setState(() {
                                _notificationsEnabled = result;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          color: Colors.white,
                          onPressed: _fetchTasks,
                        ),
                      ],
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.indigo[700]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _filter,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Tasks')),
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filter = value!;
                              });
                            },
                            underline: Container(),
                            style: TextStyle(color: Colors.indigo[700]),
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.indigo[700]),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _filteredTasks.isEmpty
                            ? ListView(
                          children: const [
                            Center(child: Text('No tasks available')),
                          ],
                        )
                            : ListView.builder(
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: AnimatedTaskCard(
                                task: task,
                                onComplete: task.status == 'pending'
                                    ? () => _markTaskComplete(task)
                                    : null,
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

class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onComplete;

  const AnimatedTaskCard({super.key, required this.task, this.onComplete});

  @override
  _AnimatedTaskCardState createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation: 6 * _scaleAnimation.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TaskCard(
                  task: widget.task,
                  onComplete: widget.onComplete,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}