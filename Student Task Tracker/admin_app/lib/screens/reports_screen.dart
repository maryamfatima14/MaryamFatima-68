import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _performance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPerformance();
    // Subscribe to task updates to refresh performance data in real-time
    _supabaseService.subscribeToTasks((tasks) {
      if (mounted) {
        debugPrint('Task update received, refreshing performance data');
        _fetchPerformance();
      }
    });
  }

  Future<void> _fetchPerformance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final performance = await _supabaseService.getStudentPerformance();
      debugPrint('Fetched performance data: $performance');
      // Log performance scores to verify values
      for (var student in performance) {
        debugPrint('Student: ${student['name']}, Score: ${student['performance_score']}');
      }
      setState(() {
        _performance = performance;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching performance: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching performance: $e')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
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
              // Simplified Header without Profile Pic
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reports & Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _fetchPerformance,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Leaderboard', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _performance.isEmpty
                            ? const Center(child: Text('No performance data available'))
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _performance.length,
                          itemBuilder: (context, index) {
                            final student = _performance[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: index < 3
                                      ? [Colors.amber[600], Colors.grey[400], Colors.brown[300]][index]
                                      : Colors.indigo[100],
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: index < 3 ? Colors.black87 : Colors.indigo[800],
                                    ),
                                  ),
                                ),
                                title: Text(student['name']),
                                subtitle: Text(
                                  'Completed: ${student['completed_tasks']}/${student['total_tasks']}\nScore: ${student['performance_score'].toStringAsFixed(1)}%',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text('Performance Graph', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Student Completion Rates', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 220, // Increased height to accommodate 100% label
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: _performance.length * 100.0, // Dynamic width based on number of bars
                                      child: BarChart(
                                        BarChartData(
                                          alignment: BarChartAlignment.spaceAround,
                                          maxY: 110, // Increased to ensure 100% label is visible
                                          minY: 0,
                                          barGroups: _performance.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final student = entry.value;
                                            // Ensure performance_score is a double and within range
                                            double score = (student['performance_score'] ?? 0).toDouble();
                                            if (score < 0) score = 0;
                                            if (score > 100) score = 100;
                                            return BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: score,
                                                  color: Colors.indigo[600],
                                                  width: 12,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final index = value.toInt();
                                                  if (index < _performance.length) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Text(
                                                        _performance[index]['name'].split(' ').first,
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                                reservedSize: 40,
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                interval: 25, // Labels at 0, 25, 50, 75, 100
                                                getTitlesWidget: (value, meta) {
                                                  if (value.toInt() <= 100) { // Ensure 100% is shown
                                                    return Text(
                                                      '${value.toInt()}%',
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          gridData: FlGridData(show: false),
                                          barTouchData: BarTouchData(enabled: false),
                                        ),
                                      ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}