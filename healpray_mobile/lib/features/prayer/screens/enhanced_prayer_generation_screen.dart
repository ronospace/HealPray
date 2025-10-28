import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// Prayer type enum
enum PrayerType {
  gratitude,
  healing,
  guidance,
  protection,
  peace,
  strength,
  forgiveness,
  blessing,
}

extension PrayerTypeExtension on PrayerType {
  String get displayName {
    switch (this) {
      case PrayerType.gratitude:
        return 'Gratitude';
      case PrayerType.healing:
        return 'Healing';
      case PrayerType.guidance:
        return 'Guidance';
      case PrayerType.protection:
        return 'Protection';
      case PrayerType.peace:
        return 'Peace';
      case PrayerType.strength:
        return 'Strength';
      case PrayerType.forgiveness:
        return 'Forgiveness';
      case PrayerType.blessing:
        return 'Blessing';
    }
  }

  String get description {
    switch (this) {
      case PrayerType.gratitude:
        return 'Give thanks for your blessings';
      case PrayerType.healing:
        return 'Seek healing and restoration';
      case PrayerType.guidance:
        return 'Ask for wisdom and direction';
      case PrayerType.protection:
        return 'Request safety and security';
      case PrayerType.peace:
        return 'Find calm and tranquility';
      case PrayerType.strength:
        return 'Gain courage and resilience';
      case PrayerType.forgiveness:
        return 'Release and be released';
      case PrayerType.blessing:
        return 'Pray for others\' wellbeing';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerType.gratitude:
        return Icons.favorite;
      case PrayerType.healing:
        return Icons.healing;
      case PrayerType.guidance:
        return Icons.compass_calibration;
      case PrayerType.protection:
        return Icons.shield;
      case PrayerType.peace:
        return Icons.spa;
      case PrayerType.strength:
        return Icons.fitness_center;
      case PrayerType.forgiveness:
        return Icons.handshake;
      case PrayerType.blessing:
        return Icons.auto_awesome;
    }
  }

  List<Color> get colors {
    switch (this) {
      case PrayerType.gratitude:
        return [AppTheme.sunriseGold, AppTheme.hopeOrange];
      case PrayerType.healing:
        return [AppTheme.healingTeal, AppTheme.celestialCyan];
      case PrayerType.guidance:
        return [AppTheme.wisdomGold, AppTheme.sunriseGold];
      case PrayerType.protection:
        return [AppTheme.sacredBlue, AppTheme.celestialCyan];
      case PrayerType.peace:
        return [AppTheme.celestialCyan, AppTheme.healingTeal];
      case PrayerType.strength:
        return [AppTheme.hopeOrange, AppTheme.sunriseGold];
      case PrayerType.forgiveness:
        return [AppTheme.mysticalPurple, AppTheme.sacredBlue];
      case PrayerType.blessing:
        return [AppTheme.wisdomGold, AppTheme.hopeOrange];
    }
  }
}

/// Generated prayer model
class GeneratedPrayer {
  final String id;
  final String content;
  final PrayerType type;
  final DateTime createdAt;
  bool isFavorite;

  GeneratedPrayer({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isFavorite = false,
  });
}

/// Enhanced Prayer Generation Screen
class EnhancedPrayerGenerationScreen extends ConsumerStatefulWidget {
  const EnhancedPrayerGenerationScreen({super.key});

  @override
  ConsumerState<EnhancedPrayerGenerationScreen> createState() =>
      _EnhancedPrayerGenerationScreenState();
}

class _EnhancedPrayerGenerationScreenState
    extends ConsumerState<EnhancedPrayerGenerationScreen>
    with SingleTickerProviderStateMixin {
  PrayerType? _selectedType;
  GeneratedPrayer? _currentPrayer;
  final List<GeneratedPrayer> _favoritePrayers = [];
  bool _isGenerating = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Prayer Generator'),
        actions: [
          if (_favoritePrayers.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${_favoritePrayers.length}'),
                child: const Icon(Icons.bookmark),
              ),
              onPressed: _showFavorites,
            ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: _currentPrayer == null
            ? _buildTypeSelector()
            : _buildPrayerDisplay(),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GlassCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.mysticalPurple, AppTheme.sacredBlue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Prayer Generator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a prayer type to generate a personalized prayer',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Select Prayer Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Prayer type grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: PrayerType.values.length,
            itemBuilder: (context, index) {
              final type = PrayerType.values[index];
              return _buildTypeCard(type);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(PrayerType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => _generatePrayer(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? type.colors
                : [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.colors[0].withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                color: Colors.white,
                size: isSelected ? 40 : 36,
              ),
              const SizedBox(height: 12),
              Text(
                type.displayName,
                style: TextStyle(
                  fontSize: isSelected ? 16 : 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                type.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerDisplay() {
    return Column(
      children: [
        // Prayer Type Badge
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _currentPrayer!.type.colors),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_currentPrayer!.type.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_currentPrayer!.type.displayName} Prayer',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Prayer Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FadeTransition(
              opacity: _fadeController,
              child: GlassCard(
                child: Column(
                  children: [
                    // Prayer Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _currentPrayer!.type.colors),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_currentPrayer!.type.icon, color: Colors.white, size: 32),
                    ),

                    const SizedBox(height: 24),

                    // Prayer Text
                    Text(
                      _currentPrayer!.content,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Amen
                    Text(
                      'Amen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _currentPrayer!.type.colors[0],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: _currentPrayer!.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      label: _currentPrayer!.isFavorite ? 'Saved' : 'Save',
                      onPressed: _toggleFavorite,
                      colors: [AppTheme.sunriseGold, AppTheme.hopeOrange],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onPressed: _sharePrayer,
                      colors: [AppTheme.celestialCyan, AppTheme.healingTeal],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.refresh,
                      label: 'Generate New',
                      onPressed: () => _generatePrayer(_currentPrayer!.type),
                      colors: [AppTheme.mysticalPurple, AppTheme.sacredBlue],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.close,
                      label: 'Close',
                      onPressed: () {
                        setState(() {
                          _currentPrayer = null;
                          _selectedType = null;
                        });
                      },
                      colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required List<Color> colors,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        overlayColor: MaterialStateProperty.all(Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }

  void _generatePrayer(PrayerType type) async {
    setState(() {
      _selectedType = type;
      _isGenerating = true;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final prayer = GeneratedPrayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _getPrayerTemplate(type),
      type: type,
      createdAt: DateTime.now(),
    );

    setState(() {
      _currentPrayer = prayer;
      _isGenerating = false;
    });

    _fadeController.forward(from: 0);
  }

  String _getPrayerTemplate(PrayerType type) {
    switch (type) {
      case PrayerType.gratitude:
        return 'Heavenly Father, I come before You with a heart full of gratitude. Thank You for Your endless love, for the blessings You pour into my life each day, and for the gift of another moment to praise Your name. Help me to always recognize Your hand in all things, both great and small. In Jesus\' name, Amen.';
      case PrayerType.healing:
        return 'Lord Jesus, the Great Physician, I ask for Your healing touch upon my body, mind, and spirit. You who healed the sick and raised the dead, I trust in Your power to restore and renew. Grant me patience during this time and faith to believe in Your perfect timing. Amen.';
      case PrayerType.guidance:
        return 'Father God, I seek Your wisdom and direction for the path ahead. Your Word says that if I lack wisdom, I should ask You, and You will give it generously. Guide my steps, illuminate my way, and help me discern Your will in all my decisions. Lead me not by my understanding, but by Your perfect wisdom. Amen.';
      case PrayerType.protection:
        return 'Almighty God, my refuge and fortress, I place myself under Your protective wings. Shield me from harm, guard my heart and mind, and surround me with Your angels. Keep me safe in Your loving care, both now and always. You are my protector, and in You I trust completely. Amen.';
      case PrayerType.peace:
        return 'Prince of Peace, calm the storms within my heart and grant me Your perfect peace that surpasses all understanding. In the midst of chaos and uncertainty, be my anchor. Still my anxious thoughts and fill me with the tranquility that comes only from You. Let Your peace reign in my life. Amen.';
      case PrayerType.strength:
        return 'Lord, my strength and my song, when I am weak, You are strong. I draw upon Your mighty power to carry me through this day. Renew my energy, fortify my spirit, and help me stand firm in faith. With You, I can face anything that comes my way. Thank You for being my constant source of strength. Amen.';
      case PrayerType.forgiveness:
        return 'Merciful Father, I come seeking Your forgiveness for the ways I have fallen short. Wash me clean with Your grace and help me to forgive those who have wronged me, just as You have forgiven me. Release me from the burden of guilt and help me walk in the freedom of Your love. Amen.';
      case PrayerType.blessing:
        return 'Gracious God, I lift up those I love before Your throne of grace. Pour out Your blessings upon them—protect them, guide them, and fill their lives with Your presence. May they know Your love deeply and experience Your goodness in abundant measure. Bless them and keep them always. Amen.';
    }
  }

  void _toggleFavorite() {
    if (_currentPrayer == null) return;

    setState(() {
      _currentPrayer!.isFavorite = !_currentPrayer!.isFavorite;
      
      if (_currentPrayer!.isFavorite) {
        _favoritePrayers.add(_currentPrayer!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer saved to favorites'),
            backgroundColor: AppTheme.healingTeal,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _favoritePrayers.removeWhere((p) => p.id == _currentPrayer!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _sharePrayer() {
    if (_currentPrayer == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_currentPrayer!.type.displayName} prayer'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.mysticalPurple.withValues(alpha: 0.95),
              AppTheme.sacredBlue.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.bookmark, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Favorite Prayers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _favoritePrayers.length,
                itemBuilder: (context, index) {
                  final prayer = _favoritePrayers[index];
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentPrayer = prayer;
                        });
                        _fadeController.forward(from: 0);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: prayer.type.colors),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(prayer.type.icon, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${prayer.type.displayName} Prayer',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70),
                                onPressed: () {
                                  setState(() {
                                    _favoritePrayers.removeAt(index);
                                    if (prayer.id == _currentPrayer?.id) {
                                      _currentPrayer!.isFavorite = false;
                                    }
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            prayer.content,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
