import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for customizing prayer tone and length
class PrayerCustomizationPanel extends StatelessWidget {
  const PrayerCustomizationPanel({
    super.key,
    required this.selectedTone,
    required this.selectedLength,
    required this.onToneChanged,
    required this.onLengthChanged,
  });

  final String selectedTone;
  final String selectedLength;
  final Function(String) onToneChanged;
  final Function(String) onLengthChanged;

  static const List<Map<String, String>> _tones = [
    {
      'id': 'warm',
      'name': 'Warm',
      'description': 'Comforting and gentle',
    },
    {
      'id': 'reverent',
      'name': 'Reverent',
      'description': 'Respectful and honored',
    },
    {
      'id': 'intimate',
      'name': 'Intimate',
      'description': 'Personal and close',
    },
    {
      'id': 'hopeful',
      'name': 'Hopeful',
      'description': 'Uplifting and inspiring',
    },
  ];

  static const List<Map<String, String>> _lengths = [
    {
      'id': 'short',
      'name': 'Short',
      'description': '2-3 sentences',
    },
    {
      'id': 'medium',
      'name': 'Medium',
      'description': '4-6 sentences',
    },
    {
      'id': 'long',
      'name': 'Long',
      'description': '7-10 sentences',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tone Selection
        Text(
          'Prayer Tone',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildToneSelector(),
        
        const SizedBox(height: 24),
        
        // Length Selection
        Text(
          'Prayer Length',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildLengthSelector(),
      ],
    );
  }

  Widget _buildToneSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _tones.map((tone) {
          final isSelected = selectedTone == tone['id'];
          
          return GestureDetector(
            onTap: () => onToneChanged(tone['id']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.healingTeal.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.healingTeal 
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? AppTheme.healingTeal 
                          : Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tone['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? AppTheme.healingTeal 
                                : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tone['description']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLengthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _lengths.map((length) {
          final isSelected = selectedLength == length['id'];
          final index = _lengths.indexOf(length);
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onLengthChanged(length['id']!),
              child: Container(
                margin: EdgeInsets.only(
                  right: index < _lengths.length - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.sunriseGold.withOpacity(0.1) 
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.sunriseGold 
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      length['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isSelected 
                            ? AppTheme.sunriseGold 
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      length['description']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
