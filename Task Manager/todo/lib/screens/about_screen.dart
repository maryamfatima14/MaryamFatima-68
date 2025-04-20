import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8BBD0), // Baby pink background
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700, // Blue app bar
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white), // White back button
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.blue.shade900,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFFFEBEE), // Light pink background
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
            BoxShadow(
            color: Colors.blue.shade200,
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 5),
            )],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Icon with cute decoration
                Center(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // App Title
                Center(
                  child: Text(
                    '✨ ToDo List App ✨',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Version Info
                _buildInfoRow('📱 Version', '1.0.0'),
                SizedBox(height: 10),

                // Developer Info
                _buildInfoRow('👩‍💻 Developer', 'Maryam Fatima'),
                SizedBox(height: 10),

                // Build Date
                _buildInfoRow('📅 Released', 'April 2025'),
                SizedBox(height: 20),

                // Description
                Text(
                  "This app helps you organize your day, manage tasks, set reminders, and stay productive. Built with 💙 using Flutter.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Cute Footer
                Center(
                  child: Text(
                    "Thank you for using our app!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label + ': ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}