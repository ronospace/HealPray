import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';

/// Widget for selecting conversation context/type
class ConversationContextSelector extends StatelessWidget {
  const ConversationContextSelector({
    super.key,
    required this.currentContext,
    required this.onContextChanged,
  });

  final ChatContext currentContext;
  final Function(ChatContext) onContextChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.lightGray, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose conversation type:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ChatContext.values.map((context) {
              final isSelected = context == currentContext;
              final contextInfo = _getContextInfo(context);

              return GestureDetector(
                onTap: () => onContextChanged(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.healingTeal
                        : contextInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppTheme.healingTeal : contextInfo.color,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        contextInfo.icon,
                        size: 18,
                        color: isSelected ? Colors.white : contextInfo.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        contextInfo.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : contextInfo.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _getContextDescription(currentContext),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  ContextInfo _getContextInfo(ChatContext context) {
    switch (context) {
      case ChatContext.spiritual:
        return ContextInfo(
          icon: Icons.psychology,
          label: 'Spiritual',
          color: AppTheme.healingTeal,
        );
      case ChatContext.prayer:
        return ContextInfo(
          icon: Icons.accessibility_new,
          label: 'Prayer',
          color: AppTheme.calmBlue,
        );
      case ChatContext.mood:
        return ContextInfo(
          icon: Icons.favorite_outline,
          label: 'Emotional',
          color: AppTheme.sunriseGold,
        );
      case ChatContext.crisis:
        return ContextInfo(
          icon: Icons.support_agent,
          label: 'Crisis',
          color: Colors.red,
        );
      case ChatContext.meditation:
        return ContextInfo(
          icon: Icons.self_improvement,
          label: 'Meditation',
          color: Colors.purple,
        );
      case ChatContext.guidance:
        return ContextInfo(
          icon: Icons.lightbulb_outline,
          label: 'Guidance',
          color: AppTheme.midnightBlue,
        );
      default:
        return ContextInfo(
          icon: Icons.chat_bubble_outline,
          label: 'General',
          color: Colors.grey,
        );
    }
  }

  String _getContextDescription(ChatContext context) {
    switch (context) {
      case ChatContext.spiritual:
        return 'General spiritual guidance and support for your faith journey';
      case ChatContext.prayer:
        return 'Prayer requests, prayer guidance, and spiritual intercession';
      case ChatContext.mood:
        return 'Emotional support with spiritual wisdom and comfort';
      case ChatContext.crisis:
        return 'Immediate spiritual support during difficult times (professional help recommended)';
      case ChatContext.meditation:
        return 'Guided meditation, contemplation, and spiritual reflection';
      case ChatContext.guidance:
        return 'Life decisions and guidance through spiritual principles';
      default:
        return 'Open conversation about faith, life, and spirituality';
    }
  }
}

/// Data class for context information
class ContextInfo {
  const ContextInfo({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
