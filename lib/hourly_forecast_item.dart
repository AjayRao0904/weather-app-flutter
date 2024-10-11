import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String timeV;
  final IconData icon;
  final String label;

  const HourlyForecastItem({
    super.key,
    required this.icon,
    required this.label,
    required this.timeV,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              timeV,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Icon(
              icon,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
