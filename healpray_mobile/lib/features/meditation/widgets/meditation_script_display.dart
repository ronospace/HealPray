import 'package:flutter/material.dart';

import '../models/meditation_session.dart';
import '../../../core/theme/app_theme.dart';

/// Widget to display meditation script content during a session
class MeditationScriptDisplay extends StatefulWidget {
  final MeditationSession session;
  final ScrollController? scrollController;
  final VoidCallback? onScriptEnd;

  const MeditationScriptDisplay({
    super.key,
    required this.session,
    this.scrollController,
    this.onScriptEnd,
  });

  @override
  State<MeditationScriptDisplay> createState() =>
      _MeditationScriptDisplayState();
}

class _MeditationScriptDisplayState extends State<MeditationScriptDisplay> {
  late ScrollController _scrollController;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final script = widget.session.scriptContent;

    if (script == null || script.isEmpty) {
      return _buildSilentMeditation();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Script header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title ?? 'Meditation Script',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.session.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.session.description!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Script content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    script,
                    style: AppTheme.bodyLarge.copyWith(
                      height: 1.8,
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _scrollToTop,
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: 'Scroll to top',
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _toggleAutoScroll,
                icon: Icon(
                  _isAutoScrolling ? Icons.pause : Icons.play_arrow,
                ),
                tooltip: _isAutoScrolling ? 'Pause auto-scroll' : 'Auto-scroll',
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _scrollToBottom,
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: 'Scroll to bottom',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSilentMeditation() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement,
            size: 80,
            color: AppTheme.primaryColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Silent Meditation',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Sit in peaceful silence and let your mind find its natural rhythm. Focus on your breath, or simply be present in this moment.',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.session.targetDurationMinutes} minutes of silence',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
    });

    if (_isAutoScrolling) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() async {
    if (!_isAutoScrolling) return;

    const scrollDuration = Duration(milliseconds: 100);
    const scrollAmount = 1.0;

    while (_isAutoScrolling && mounted) {
      await Future.delayed(scrollDuration);

      if (_scrollController.hasClients && _isAutoScrolling) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          // Reached the end
          setState(() {
            _isAutoScrolling = false;
          });
          widget.onScriptEnd?.call();
        } else {
          _scrollController.animateTo(
            currentScroll + scrollAmount,
            duration: scrollDuration,
            curve: Curves.linear,
          );
        }
      }
    }
  }
}
