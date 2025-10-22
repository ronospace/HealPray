import 'dart:math';
import 'package:flutter/material.dart';

import '../models/meditation_session.dart';
import '../../../core/theme/app_theme.dart';

/// Circular timer widget for meditation sessions
class MeditationTimerWidget extends StatelessWidget {
  const MeditationTimerWidget({
    super.key,
    required this.session,
    required this.isActive,
  });

  final MeditationSession session;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final progress = session.targetDurationMinutes > 0
        ? (session.actualDurationSeconds / (session.targetDurationMinutes * 60))
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main circular timer
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: MeditationTimerPainter(
                    progress: progress,
                    isActive: isActive,
                  ),
                ),
              ),

              // Center content
              Column(
                children: [
                  // Time remaining
                  Text(
                    _formatTimeRemaining(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status text
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (session.state == MeditationState.paused) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pause, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Paused',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Progress indicator
          _buildProgressIndicator(progress),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0:00',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            Text(
              '${session.targetDurationMinutes}:00',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.healingTeal),
          minHeight: 4,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).round()}% Complete',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTimeRemaining() {
    final targetSeconds = session.targetDurationMinutes * 60;
    final remainingSeconds =
        (targetSeconds - session.actualDurationSeconds).clamp(0, targetSeconds);

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getStatusText() {
    switch (session.state) {
      case MeditationState.preparing:
        return 'Preparing...';
      case MeditationState.active:
        return 'Breathe deeply';
      case MeditationState.paused:
        return 'Take your time';
      case MeditationState.completed:
        return 'Complete!';
      case MeditationState.cancelled:
        return 'Session ended';
    }
  }
}

/// Custom painter for the meditation timer circle
class MeditationTimerPainter extends CustomPainter {
  const MeditationTimerPainter({
    required this.progress,
    required this.isActive,
  });

  final double progress;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.healingTeal,
          AppTheme.healingBlue,
          AppTheme.spiritualPurple,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Inner glow for active state
    if (isActive) {
      final glowPaint = Paint()
        ..color = AppTheme.healingTeal.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius - 20, glowPaint);
    }

    // Center dot
    final centerDotPaint = Paint()
      ..color =
          isActive ? AppTheme.healingTeal : Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerDotPaint);
  }

  @override
  bool shouldRepaint(MeditationTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
