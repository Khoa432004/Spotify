import 'package:flutter/material.dart';

/// Widget cho tiêu đề của các section
class SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;

  const SectionHeader({super.key, required this.title, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
