import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/simple_mood_entry.dart';

/// Chart widget for visualizing mood data over time
class MoodChartWidget extends StatelessWidget {
  final List<SimpleMoodEntry> entries;

  const MoodChartWidget({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChartHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No data to display',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    final averageScore = entries.fold<double>(0, (sum, entry) => sum + entry.score) / entries.length;
    final highestScore = entries.map((e) => e.score).reduce((a, b) => a > b ? a : b);
    final lowestScore = entries.map((e) => e.score).reduce((a, b) => a < b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildChartStat('Avg', averageScore.toStringAsFixed(1), AppTheme.healingTeal),
        _buildChartStat('High', highestScore.toString(), AppTheme.sunriseGold),
        _buildChartStat('Low', lowestScore.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildChartStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    // Sort entries by timestamp
    final sortedEntries = List<SimpleMoodEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: MoodChartPainter(sortedEntries),
    );
  }
}

/// Custom painter for the mood chart
class MoodChartPainter extends CustomPainter {
  final List<SimpleMoodEntry> entries;
  
  MoodChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.healingTeal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.healingTeal.withOpacity(0.3),
          AppTheme.healingTeal.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = AppTheme.healingTeal
      ..style = PaintingStyle.fill;

    // Calculate positions
    final points = <Offset>[];
    final fillPoints = <Offset>[
      Offset(0, size.height), // Start from bottom-left
    ];

    for (int i = 0; i < entries.length; i++) {
      final x = (i / (entries.length - 1)) * size.width;
      final y = size.height - ((entries[i].score - 1) / 9) * size.height; // Scale 1-10 to chart height
      
      points.add(Offset(x, y));
      fillPoints.add(Offset(x, y));
    }

    fillPoints.add(Offset(size.width, size.height)); // End at bottom-right

    // Draw filled area
    if (fillPoints.length > 2) {
      final fillPath = Path()..addPolygon(fillPoints, true);
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // Draw grid lines (optional)
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Horizontal grid lines for mood scores
    for (int i = 1; i <= 10; i++) {
      final y = size.height - ((i - 1) / 9) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
