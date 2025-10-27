import 'package:flutter/material.dart';
import '../../core/services/user_feedback_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/loading_overlay.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  
  FeedbackCategory _selectedCategory = FeedbackCategory.general;
  int _rating = 5;
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Send Feedback',
        showBackButton: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildRatingSection(),
                const SizedBox(height: 24),
                _buildFeedbackSection(),
                const SizedBox(height: 24),
                _buildEmailSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.feedback, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Your Feedback Matters',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Help us improve HealPray by sharing your thoughts, suggestions, or reporting issues.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: FeedbackCategory.values.map((category) {
                return RadioListTile<FeedbackCategory>(
                  title: Text(_getCategoryDisplayName(category)),
                  subtitle: Text(_getCategoryDescription(category)),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = starValue;
                        });
                      },
                      icon: Icon(
                        starValue <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingLabel(_rating),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Feedback',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Tell us about your experience, suggestions for improvement, or report any issues you encountered...',
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide your feedback';
                }
                if (value.trim().length < 10) {
                  return 'Please provide more detailed feedback (at least 10 characters)';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'your@email.com',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Provide your email if you\'d like us to follow up on your feedback',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Submit Feedback',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Feedback Sent',
        showBackButton: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thank You!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your feedback has been submitted successfully. We appreciate you taking the time to help us improve HealPray.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await UserFeedbackService.instance.submitFeedback(
        feedbackText: _feedbackController.text.trim(),
        category: _selectedCategory,
        rating: _rating,
        metadata: {
          'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          'submitted_at': DateTime.now().toIso8601String(),
        },
      );

      if (success) {
        setState(() {
          _isSubmitted = true;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCategoryDisplayName(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.general:
        return 'General Feedback';
      case FeedbackCategory.featureRequest:
        return 'Feature Request';
      case FeedbackCategory.bugReport:
        return 'Bug Report';
      case FeedbackCategory.usability:
        return 'Usability';
      case FeedbackCategory.performance:
        return 'Performance';
      case FeedbackCategory.content:
        return 'Content';
      case FeedbackCategory.privacy:
        return 'Privacy';
      case FeedbackCategory.accessibility:
        return 'Accessibility';
      case FeedbackCategory.nps:
        return 'App Recommendation';
    }
  }

  String _getCategoryDescription(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.general:
        return 'General comments or suggestions';
      case FeedbackCategory.featureRequest:
        return 'Suggest new features or improvements';
      case FeedbackCategory.bugReport:
        return 'Report bugs or technical issues';
      case FeedbackCategory.usability:
        return 'App is hard to use or confusing';
      case FeedbackCategory.performance:
        return 'App is slow or crashes';
      case FeedbackCategory.content:
        return 'Content quality or accuracy issues';
      case FeedbackCategory.privacy:
        return 'Privacy or data concerns';
      case FeedbackCategory.accessibility:
        return 'Accessibility improvements needed';
      case FeedbackCategory.nps:
        return 'Would you recommend this app?';
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate your experience';
    }
  }
}
