import 'package:flutter/material.dart';

import '../models/meditation_session.dart';
import '../../../core/theme/app_theme.dart';

/// Control buttons for meditation session (play, pause, stop, etc.)
class MeditationControls extends StatefulWidget {
  final MeditationSession session;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onStop;
  final VoidCallback? onComplete;
  final bool isLoading;

  const MeditationControls({
    super.key,
    required this.session,
    this.onPlay,
    this.onPause,
    this.onStop,
    this.onComplete,
    this.isLoading = false,
  });

  @override
  State<MeditationControls> createState() => _MeditationControlsState();
}

class _MeditationControlsState extends State<MeditationControls>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.session.state == MeditationState.active) {
      _startPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(MeditationControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.state != oldWidget.session.state) {
      if (widget.session.state == MeditationState.active) {
        _startPulseAnimation();
      } else {
        _stopPulseAnimation();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulseAnimation() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main control button
          _buildMainControlButton(),

          const SizedBox(height: 24),

          // Secondary controls
          _buildSecondaryControls(),

          const SizedBox(height: 16),

          // Session info
          _buildSessionInfo(),
        ],
      ),
    );
  }

  Widget _buildMainControlButton() {
    Widget button;

    switch (widget.session.state) {
      case MeditationState.preparing:
        button = _buildPlayButton();
        break;
      case MeditationState.active:
        button = _buildPauseButton();
        break;
      case MeditationState.paused:
        button = _buildResumeButton();
        break;
      case MeditationState.completed:
        button = _buildCompletedButton();
        break;
      case MeditationState.cancelled:
        button = _buildRestartButton();
        break;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.session.state == MeditationState.active
            ? _pulseAnimation.value
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: button,
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return _buildControlButton(
      icon: Icons.play_arrow,
      label: 'Begin',
      color: AppTheme.primaryColor,
      onPressed: widget.isLoading ? null : widget.onPlay,
      size: 80,
    );
  }

  Widget _buildPauseButton() {
    return _buildControlButton(
      icon: Icons.pause,
      label: 'Pause',
      color: AppTheme.warningColor,
      onPressed: widget.isLoading ? null : widget.onPause,
      size: 80,
    );
  }

  Widget _buildResumeButton() {
    return _buildControlButton(
      icon: Icons.play_arrow,
      label: 'Resume',
      color: AppTheme.primaryColor,
      onPressed: widget.isLoading ? null : widget.onPlay,
      size: 80,
    );
  }

  Widget _buildCompletedButton() {
    return _buildControlButton(
      icon: Icons.check_circle,
      label: 'Completed',
      color: AppTheme.successColor,
      onPressed: null,
      size: 80,
    );
  }

  Widget _buildRestartButton() {
    return _buildControlButton(
      icon: Icons.refresh,
      label: 'Restart',
      color: AppTheme.primaryColor,
      onPressed: widget.isLoading ? null : widget.onPlay,
      size: 80,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    double size = 60,
  }) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: onPressed != null ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    icon,
                    color: Colors.white,
                    size: size * 0.4,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: onPressed != null
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Stop button
        _buildSmallControlButton(
          icon: Icons.stop,
          label: 'Stop',
          onPressed: widget.session.isInProgress ? widget.onStop : null,
        ),

        // Complete button (only during active session)
        if (widget.session.state == MeditationState.active)
          _buildSmallControlButton(
            icon: Icons.check,
            label: 'Complete',
            onPressed: widget.onComplete,
          ),
      ],
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: onPressed != null
                ? AppTheme.surface
                : AppTheme.surface.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: onPressed != null
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: onPressed != null
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            icon: Icons.timer_outlined,
            label: 'Target',
            value: '${widget.session.targetDurationMinutes}m',
          ),
          _buildInfoItem(
            icon: Icons.schedule,
            label: 'Elapsed',
            value: widget.session.formattedActualDuration,
          ),
          _buildInfoItem(
            icon: Icons.category_outlined,
            label: 'Type',
            value: widget.session.type.name.toLowerCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
