import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import 'user_management_screen.dart';
import 'task_management_screen.dart';
import 'reports_screen.dart';
import '../widgets/custom_card.dart';
import 'menu_screen.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const CustomCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stats = await _supabaseService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stats: $e')),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MenuScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
                      : RefreshIndicator(
                    onRefresh: _fetchStats,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          _buildStatCards(),
                          const SizedBox(height: 24),
                          Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          _buildActionButtons(context),
                          const SizedBox(height: 24),
                          Text('Task Analytics', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          _buildTaskChart(),
                        ],
                      ),
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

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        CustomCard(
          title: 'Total Students',
          value: _stats['total_students']?.toString() ?? '0',
          icon: Icons.people,
          gradient: LinearGradient(colors: [Colors.indigo[400]!, Colors.indigo[200]!]),
        ),
        CustomCard(
          title: 'Tasks Today',
          value: _stats['tasks_today']?.toString() ?? '0',
          icon: Icons.today,
          gradient: LinearGradient(colors: [Colors.amber[400]!, Colors.amber[200]!]),
        ),
        CustomCard(
          title: 'Pending',
          value: _stats['pending_tasks']?.toString() ?? '0',
          icon: Icons.pending,
          gradient: LinearGradient(colors: [Colors.orange[400]!, Colors.orange[200]!]),
        ),
        CustomCard(
          title: 'Completed',
          value: _stats['completed_tasks']?.toString() ?? '0',
          icon: Icons.check_circle,
          gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[200]!]),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
          icon: const Icon(Icons.person_add),
          label: const Text('Manage Students'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskManagementScreen())),
          icon: const Icon(Icons.assignment),
          label: const Text('Assign Tasks'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
          icon: const Icon(Icons.analytics),
          label: const Text('View Reports'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
        ),
      ],
    );
  }

  Widget _buildTaskChart() {
    final pendingTasks = (_stats['pending_tasks'] ?? 0).toDouble();
    final completedTasks = (_stats['completed_tasks'] ?? 0).toDouble();
    final maxY = [pendingTasks, completedTasks].reduce((a, b) => a > b ? a : b) + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending vs Completed Tasks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value == 0 ? 'Pending' : 'Completed',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value.toInt() == maxY.toInt() || value.toInt() == 1 || (value.toInt() > 1 && value.toInt() < maxY.toInt())) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: pendingTasks,
                          color: Colors.orange[600],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: completedTasks,
                          color: Colors.green[600],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
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
    );
  }
}