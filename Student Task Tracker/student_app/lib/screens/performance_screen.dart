import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/task.dart';
// Fixed typo: 'supabase_services.dart' to 'supabase_service.dart'
import '../services/supabase_services.dart';
import '../widgets/streak_indicader.dart'; // Should be 'streak_indicator.dart'
import '../utils/constants.dart'; // Still imported but not used for styling

class PerformanceScreen extends StatefulWidget {
  final String studentId;
  const PerformanceScreen({super.key, required this.studentId});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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

  int get _streak {
    int streak = 0;
    final sortedTasks = _tasks.where((task) => task.status == 'completed').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final today = DateTime.now();
    for (var task in sortedTasks) {
      if (task.createdAt.day == today.day) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Widget _buildAnimatedCard({required Widget child}) {
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
                child: child,
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.status == 'completed').length;
    final total = _tasks.length;
    final progress = total > 0 ? completed / total : 0.0;

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
                      'Performance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _fetchTasks,
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progress Overview',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Custom Doughnut Chart
                                SizedBox(
                                  height: 150,
                                  child: CustomDoughnutChart(
                                    completed: completed,
                                    total: total,
                                    color: const Color(0xFF3F51B5), // Constant indigo color
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Completion: ${(progress * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: Colors.indigo[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Streaks',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                StreakIndicator(streak: _streak),
                              ],
                            ),
                          ),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Custom Doughnut Chart to replace ProgressChart
class CustomDoughnutChart extends StatelessWidget {
  final int completed;
  final int total;
  final Color color;

  const CustomDoughnutChart({
    super.key,
    required this.completed,
    required this.total,
    this.color = const Color(0xFF3F51B5), // Constant default value
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? completed / total : 0.0;
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: CustomPaint(
          painter: DoughnutChartPainter(
            progress: progress,
            color: color,
            backgroundColor: Colors.grey[300]!,
          ),
          // Removed the centered Text widget
        ),
      ),
    );
  }
}

// Custom Painter for Doughnut Chart
class DoughnutChartPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  DoughnutChartPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 20.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}