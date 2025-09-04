import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/prayer.dart';

/// Widget for displaying generated prayer text
class PrayerTextDisplay extends StatefulWidget {
  const PrayerTextDisplay({
    super.key,
    required this.prayer,
    required this.onRegenerate,
  });

  final Prayer prayer;
  final VoidCallback onRegenerate;

  @override
  State<PrayerTextDisplay> createState() => _PrayerTextDisplayState();
}

class _PrayerTextDisplayState extends State<PrayerTextDisplay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and regenerate button
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Prayer content
            _buildPrayerContent(),
            
            const SizedBox(height: 32),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.morningGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.healingTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.prayer.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.prayer.tone.toUpperCase()} • ${widget.prayer.length.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onRegenerate,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Generate New Prayer',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom intention if provided
          if (widget.prayer.customIntention != null && 
              widget.prayer.customIntention!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.healingTeal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.healingTeal.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.healingTeal,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Intention',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.healingTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.prayer.customIntention!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Prayer text
          SelectableText(
            widget.prayer.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.8,
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
          
          const SizedBox(height: 20),
          
          // Tags
          if (widget.prayer.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.prayer.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.sunriseGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.sunriseGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.sunriseGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.copy,
              label: 'Copy',
              onPressed: _copyPrayer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.volume_up,
              label: 'Read Aloud',
              onPressed: _readAloud,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: widget.prayer.isFavorite ? Icons.favorite : Icons.favorite_outline,
              label: widget.prayer.isFavorite ? 'Favorited' : 'Favorite',
              onPressed: _toggleFavorite,
              color: widget.prayer.isFavorite ? AppTheme.crisisColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? AppTheme.healingTeal;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: buttonColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: buttonColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: buttonColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyPrayer() {
    Clipboard.setData(ClipboardData(text: widget.prayer.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prayer copied to clipboard'),
        backgroundColor: AppTheme.healingTeal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _readAloud() {
    // TODO: Implement text-to-speech functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Read aloud feature coming soon!'),
        backgroundColor: AppTheme.healingTeal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite() {
    // TODO: Implement favorite toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.prayer.isFavorite 
              ? 'Removed from favorites' 
              : 'Added to favorites',
        ),
        backgroundColor: AppTheme.healingTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
