import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8BBD0), // Baby pink background
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700, // Blue app bar
        title: const Text(
          'Privacy Policy',
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
                // Privacy Icon
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
                      Icons.lock,
                      size: 50,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Privacy Policy Text
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: "🔐 Your Privacy Matters\n\n",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: "We take your privacy seriously. Here's how we protect your data:\n\n",
                      ),
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: " We do NOT collect personal data\n",
                      ),
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: " Your tasks are stored locally on your device\n",
                      ),
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: " No data is shared with third-parties\n\n",
                      ),
                      TextSpan(
                        text: "You're in full control of your information. ",
                      ),
                      TextSpan(
                        text: "We believe in transparency and your right to privacy.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Cute Footer
                Center(
                  child: Text(
                    "Thank you for trusting us with your data!",
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
}