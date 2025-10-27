import 'package:flutter/material.dart';
import '../../core/services/user_feedback_service.dart';
import '../../core/theme/app_theme.dart';

class NPSSurveyWidget extends StatefulWidget {
  final VoidCallback? onCompleted;
  final VoidCallback? onDismissed;

  const NPSSurveyWidget({
    super.key,
    this.onCompleted,
    this.onDismissed,
  });

  @override
  State<NPSSurveyWidget> createState() => _NPSSurveyWidgetState();
}

class _NPSSurveyWidgetState extends State<NPSSurveyWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  int? _selectedScore;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  bool _showReasonField = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
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
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildScoreSelection(),
                  if (_showReasonField) _buildReasonField(),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.thumb_up_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How likely are you to recommend HealPray?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your feedback helps us improve',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _dismiss,
            icon: const Icon(Icons.close),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score buttons
          Row(
            children: List.generate(11, (index) {
              final score = index;
              final isSelected = _selectedScore == score;
              final color = _getScoreColor(score);
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => _selectScore(score),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          score.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Not at all likely',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Extremely likely',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          if (_selectedScore != null) ...[
            const SizedBox(height: 16),
            Text(
              _getScoreLabel(_selectedScore!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getScoreColor(_selectedScore!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s the main reason for your score?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _getReasonHint(_selectedScore ?? 0),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _dismiss,
              child: const Text('Maybe later'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedScore != null && !_isLoading ? _submitNPS : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectScore(int score) {
    setState(() {
      _selectedScore = score;
      _showReasonField = true;
    });
  }

  Future<void> _submitNPS() async {
    if (_selectedScore == null) return;

    setState(() => _isLoading = true);

    try {
      await UserFeedbackService.instance.submitNPS(
        score: _selectedScore!,
        reason: _reasonController.text.trim().isEmpty 
            ? null 
            : _reasonController.text.trim(),
      );

      // Show thank you message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      widget.onCompleted?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismissed?.call();
    });
  }

  Color _getScoreColor(int score) {
    if (score <= 6) {
      return Colors.red; // Detractors
    } else if (score <= 8) {
      return Colors.orange; // Passives
    } else {
      return Colors.green; // Promoters
    }
  }

  String _getScoreLabel(int score) {
    if (score <= 6) {
      return 'Detractor - Unlikely to recommend';
    } else if (score <= 8) {
      return 'Passive - Might recommend';
    } else {
      return 'Promoter - Very likely to recommend';
    }
  }

  String _getReasonHint(int score) {
    if (score <= 6) {
      return 'What can we improve to better serve you?';
    } else if (score <= 8) {
      return 'What would make you more likely to recommend us?';
    } else {
      return 'What do you love most about HealPray?';
    }
  }
}

/// Dialog wrapper for NPS survey
class NPSSurveyDialog extends StatelessWidget {
  const NPSSurveyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: NPSSurveyWidget(
        onCompleted: () => Navigator.of(context).pop(),
        onDismissed: () => Navigator.of(context).pop(),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NPSSurveyDialog(),
    );
  }
}

/// Bottom sheet wrapper for NPS survey
class NPSSurveyBottomSheet extends StatelessWidget {
  const NPSSurveyBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: NPSSurveyWidget(
        onCompleted: () => Navigator.of(context).pop(),
        onDismissed: () => Navigator.of(context).pop(),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NPSSurveyBottomSheet(),
    );
  }
}
