import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/emotion_type.dart';

/// Card widget for displaying and selecting emotions
class EmotionCard extends StatelessWidget {
  const EmotionCard({
    super.key,
    required this.emotion,
    required this.isSelected,
    required this.onTap,
    this.size = EmotionCardSize.medium,
    this.showLabel = true,
  });

  final EmotionType emotion;
  final bool isSelected;
  final VoidCallback onTap;
  final EmotionCardSize size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final cardSize = _getCardSize();
    final emojiSize = _getEmojiSize();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardSize,
        height: showLabel ? cardSize + 30 : cardSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emotion circle
            Container(
              width: cardSize,
              height: cardSize,
              decoration: BoxDecoration(
                color: isSelected 
                    ? emotion.color.withOpacity(0.2) 
                    : colorScheme.surface,
                border: Border.all(
                  color: isSelected 
                      ? emotion.color 
                      : colorScheme.outline.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(cardSize / 2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: emotion.color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  emotion.emoji,
                  style: TextStyle(fontSize: emojiSize),
                ),
              ),
            ),
            
            if (showLabel) ...[
              const SizedBox(height: 8),
              Text(
                emotion.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected 
                      ? emotion.color 
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _getCardSize() {
    switch (size) {
      case EmotionCardSize.small:
        return 50;
      case EmotionCardSize.medium:
        return 70;
      case EmotionCardSize.large:
        return 90;
    }
  }

  double _getEmojiSize() {
    switch (size) {
      case EmotionCardSize.small:
        return 20;
      case EmotionCardSize.medium:
        return 28;
      case EmotionCardSize.large:
        return 36;
    }
  }
}

/// Grid widget for displaying emotion cards
class EmotionGrid extends StatelessWidget {
  const EmotionGrid({
    super.key,
    required this.emotions,
    required this.selectedEmotions,
    required this.onEmotionToggled,
    this.allowMultiSelect = true,
    this.maxSelections,
    this.emotionCardSize = EmotionCardSize.medium,
    this.crossAxisCount,
  });

  final List<EmotionType> emotions;
  final List<EmotionType> selectedEmotions;
  final Function(EmotionType emotion) onEmotionToggled;
  final bool allowMultiSelect;
  final int? maxSelections;
  final EmotionCardSize emotionCardSize;
  final int? crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultCrossAxisCount = screenWidth > 600 ? 5 : 4;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount ?? defaultCrossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        final isSelected = selectedEmotions.contains(emotion);
        
        return EmotionCard(
          emotion: emotion,
          isSelected: isSelected,
          size: emotionCardSize,
          onTap: () => _handleEmotionTap(emotion, context),
        );
      },
    );
  }

  void _handleEmotionTap(EmotionType emotion, BuildContext context) {
    if (selectedEmotions.contains(emotion)) {
      // Deselect emotion
      onEmotionToggled(emotion);
    } else {
      // Check selection limits
      if (!allowMultiSelect && selectedEmotions.isNotEmpty) {
        // Single select mode - replace selection
        onEmotionToggled(emotion);
      } else if (maxSelections != null && selectedEmotions.length >= maxSelections!) {
        // Max selections reached
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can select up to $maxSelections emotions'),
            backgroundColor: AppTheme.healingTeal,
          ),
        );
      } else {
        // Add to selection
        onEmotionToggled(emotion);
      }
    }
  }
}

/// Category-grouped emotion selector
class CategorizedEmotionSelector extends StatefulWidget {
  const CategorizedEmotionSelector({
    super.key,
    required this.selectedEmotions,
    required this.onEmotionToggled,
    this.allowMultiSelect = true,
    this.maxSelections,
    this.initialCategory,
  });

  final List<EmotionType> selectedEmotions;
  final Function(EmotionType emotion) onEmotionToggled;
  final bool allowMultiSelect;
  final int? maxSelections;
  final EmotionCategory? initialCategory;

  @override
  State<CategorizedEmotionSelector> createState() => _CategorizedEmotionSelectorState();
}

class _CategorizedEmotionSelectorState extends State<CategorizedEmotionSelector>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late EmotionCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? EmotionCategory.positive;
    _tabController = TabController(
      length: EmotionCategory.values.length,
      vsync: this,
      initialIndex: EmotionCategory.values.indexOf(_selectedCategory),
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = EmotionCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Category tabs
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(
              color: AppTheme.healingTeal,
              borderRadius: BorderRadius.circular(20),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.bodySmall,
            tabs: EmotionCategory.values.map((category) => Tab(
              icon: Icon(category.icon, size: 20),
              text: category.displayName,
            )).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Emotions for selected category
        EmotionGrid(
          emotions: _getEmotionsForCategory(_selectedCategory),
          selectedEmotions: widget.selectedEmotions,
          onEmotionToggled: widget.onEmotionToggled,
          allowMultiSelect: widget.allowMultiSelect,
          maxSelections: widget.maxSelections,
        ),
      ],
    );
  }

  List<EmotionType> _getEmotionsForCategory(EmotionCategory category) {
    return EmotionType.values
        .where((emotion) => emotion.category == category)
        .toList();
  }
}

/// Horizontal scrollable emotion selector
class HorizontalEmotionSelector extends StatelessWidget {
  const HorizontalEmotionSelector({
    super.key,
    required this.emotions,
    required this.selectedEmotions,
    required this.onEmotionToggled,
    this.height = 120,
  });

  final List<EmotionType> emotions;
  final List<EmotionType> selectedEmotions;
  final Function(EmotionType emotion) onEmotionToggled;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: emotions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final emotion = emotions[index];
          final isSelected = selectedEmotions.contains(emotion);
          
          return EmotionCard(
            emotion: emotion,
            isSelected: isSelected,
            size: EmotionCardSize.medium,
            onTap: () => onEmotionToggled(emotion),
          );
        },
      ),
    );
  }
}

/// Quick emotion selector for common emotions
class QuickEmotionSelector extends StatelessWidget {
  const QuickEmotionSelector({
    super.key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
  });

  final EmotionType? selectedEmotion;
  final Function(EmotionType emotion) onEmotionSelected;

  static const List<EmotionType> _quickEmotions = [
    EmotionType.joyful,
    EmotionType.grateful,
    EmotionType.peaceful,
    EmotionType.sad,
    EmotionType.anxious,
    EmotionType.stressed,
    EmotionType.angry,
    EmotionType.tired,
  ];

  @override
  Widget build(BuildContext context) {
    return HorizontalEmotionSelector(
      emotions: _quickEmotions,
      selectedEmotions: selectedEmotion != null ? [selectedEmotion!] : [],
      onEmotionToggled: onEmotionSelected,
      height: 100,
    );
  }
}

/// Emotion card sizes
enum EmotionCardSize {
  small,
  medium,
  large,
}
