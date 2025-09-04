import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Selectable preference card for onboarding
class PreferenceCard extends StatelessWidget {
  const PreferenceCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: isSelected ? 1.02 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.sunriseGold.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.sunriseGold
                  : Colors.white.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.sunriseGold.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fullWidth 
                ? MainAxisAlignment.start 
                : MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isSelected 
                      ? AppTheme.sunriseGold
                      : Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w500,
                  ),
                  textAlign: fullWidth ? TextAlign.start : TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              
              if (fullWidth) ...[
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.sunriseGold
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.sunriseGold
                          : Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppTheme.midnightBlue,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
