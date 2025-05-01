import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bmi_app/constants.dart';

class IconContent extends StatelessWidget {
  const IconContent({
    super.key,
    required this.gender,
    required this.label,
    required this.isActive,
  });

  final Gender gender;  // Using enum for gender type safety
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (gender) {
      case Gender.male:
        icon = FontAwesomeIcons.mars;
        break;
      case Gender.female:
        icon = FontAwesomeIcons.venus;
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 80.0,
          color: isActive ? kActiveIconColor : kInactiveIconColor,
        ),
        const SizedBox(height: 15.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 18.0,
            color: isActive ? kActiveTextColor : kInactiveTextColor,
          ),
        ),
      ],
    );
  }
}

// Add this to your constants.dart file or at the top of this file

// Add these to your constants.dart:
// const Color kActiveIconColor = Colors.white;
// const Color kInactiveIconColor = Color(0xFF8D8E98);
// const Color kActiveTextColor = Colors.white;
// const Color kInactiveTextColor = Color(0xFF8D8E98);