import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4EC), // Light pink background
      appBar: AppBar(
        title: const Text("Settings ⚙️", style: TextStyle(color: Colors.black)), // Black text
        backgroundColor: Colors.blue, // Blue app bar
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          _buildSettingItem(
            context,
            Icons.notifications,
            'Notifications',
            'Manage reminders',
            '/notificationSettings',
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            context,
            Icons.lock,
            'Privacy',
            'App privacy settings',
            '/privacy',
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            context,
            Icons.info,
            'About',
            'Know more about the app',
            '/about',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, String routeName) {
    return Card(
      color: Colors.white, // White background for cards
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.blue, width: 2), // Blue border
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black), // Black icon
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.black, // Black text
              fontWeight: FontWeight.bold,
              fontSize: 18
          ),
        ),
        subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black) // Black text
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black), // Black icon
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}