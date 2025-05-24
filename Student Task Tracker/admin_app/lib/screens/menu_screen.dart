import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'Login_screen.dart'; // Import your LoginScreen

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  bool _pushNotifications = true;
  bool _allowStop = false; // Kept for consistency, but not used
  bool _isLocationExpanded = false;

  // Animation controllers
  late AnimationController _profileScaleController;
  late Animation<double> _profileScaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Coordinates for Jannat Colony, Vehari, Pakistan
  static const LatLng _jannatColonyVehari = LatLng(30.0333, 72.3500);

  @override
  void initState() {
    super.initState();
    // Profile picture scale animation
    _profileScaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _profileScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _profileScaleController, curve: Curves.easeOutBack),
    );
    _profileScaleController.forward();

    // Fade animation for menu items
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _profileScaleController.dispose();
    _fadeController.dispose();
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
              // Header Section with Animated Profile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _profileScaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _profileScaleAnimation.value,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: const AssetImage('assets/images/profile.jpg'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Maryam Fatima',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '5.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu Items Section with Fade Animation
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      children: [
                        _buildAnimatedMenuItem(
                          context,
                          title: 'Notifications',
                          expandedContent: Column(
                            children: [
                              _buildToggleItem(
                                title: 'Push notifications',
                                value: _pushNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _pushNotifications = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        _buildAnimatedMenuItem(
                          context,
                          title: 'Location',
                          expandedContent: _isLocationExpanded
                              ? SizedBox(
                            height: 300,
                            child: flutter_map.FlutterMap(
                              options: flutter_map.MapOptions(
                                initialCenter: _jannatColonyVehari,
                                initialZoom: 15,
                              ),
                              children: [
                                flutter_map.TileLayer(
                                  urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.example.admin_app',
                                ),
                                flutter_map.MarkerLayer(
                                  markers: [
                                    flutter_map.Marker(
                                      point: _jannatColonyVehari,
                                      width: 80,
                                      height: 80,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              : null,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isLocationExpanded = expanded;
                            });
                          },
                        ),
                        _buildAnimatedMenuItem(
                          context,
                          title: 'Privacy settings',
                          expandedContent: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'Allow STOP to contact you for news and promotions',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Buttons with Bounce Animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAnimatedButton(
                      onPressed: () {
                        // Navigate to LoginScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    _buildAnimatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu clicked')),
                        );
                      },
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Lottie.asset(
                          'assets/animations/menu.json',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Lottie Error: $error'); // Log error for debugging
                            return const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 80,
                            ); // Fallback if animation fails
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuItem(
      BuildContext context, {
        required String title,
        Widget? expandedContent,
        ValueChanged<bool>? onExpansionChanged,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.blue),
        children: expandedContent != null ? [expandedContent] : [],
        onExpansionChanged: onExpansionChanged, // Fixed typo
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        backgroundColor: Colors.blue.withOpacity(0.05),
        collapsedBackgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue[100],
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {}); // Trigger scale animation
        },
        onTapUp: (_) {
          onPressed();
        },
        child: child,
      ),
    );
  }
}