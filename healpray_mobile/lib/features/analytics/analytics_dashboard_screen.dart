import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/advanced_analytics_service.dart';
import '../../core/services/user_feedback_service.dart';
import '../../core/services/ab_test_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/loading_overlay.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  Map<String, dynamic> _analyticsData = {};
  FeedbackStats? _feedbackStats;
  Map<String, dynamic> _abTestData = {};
  Map<String, dynamic> _dashboardInsights = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load analytics data
      _analyticsData = await AdvancedAnalyticsService.instance.getUserAnalyticsSummary();
      
      // Load feedback stats
      _feedbackStats = await UserFeedbackService.instance.getFeedbackStats();
      
      // Load A/B test data
      _abTestData = ABTestService.instance.getTestSummary();
      
      // Load dashboard insights
      _dashboardInsights = AnalyticsDashboard.getDashboardInsights();
      
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Analytics Dashboard',
        showBackButton: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildUserEngagementTab(),
                  _buildFeedbackTab(),
                  _buildExperimentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Engagement'),
          Tab(text: 'Feedback'),
          Tab(text: 'Experiments'),
        ],
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('App Performance Overview'),
            const SizedBox(height: 16),
            _buildMetricsGrid([
              MetricCard(
                title: 'Session Count',
                value: '${_analyticsData['session_count'] ?? 0}',
                icon: Icons.play_circle_outline,
                color: Colors.blue,
              ),
              MetricCard(
                title: 'Events Queued',
                value: '${_analyticsData['events_queued'] ?? 0}',
                icon: Icons.analytics_outlined,
                color: Colors.green,
              ),
              MetricCard(
                title: 'Total Events',
                value: '${_dashboardInsights['total_events'] ?? 0}',
                icon: Icons.timeline,
                color: Colors.orange,
              ),
              MetricCard(
                title: 'Event Types',
                value: '${_dashboardInsights['unique_event_types'] ?? 0}',
                icon: Icons.category_outlined,
                color: Colors.purple,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Activity'),
            const SizedBox(height: 16),
            _buildRecentActivityCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Top Events'),
            const SizedBox(height: 16),
            _buildTopEventsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEngagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('User Engagement Metrics'),
          const SizedBox(height: 16),
          _buildEngagementCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Device Information'),
          const SizedBox(height: 16),
          _buildDeviceInfoCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Session Details'),
          const SizedBox(height: 16),
          _buildSessionDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Feedback Overview'),
          const SizedBox(height: 16),
          if (_feedbackStats != null) ...[
            _buildMetricsGrid([
              MetricCard(
                title: 'Total Feedback',
                value: '${_feedbackStats!.totalFeedback}',
                icon: Icons.feedback_outlined,
                color: Colors.blue,
              ),
              MetricCard(
                title: 'NPS Score',
                value: _feedbackStats!.npsScore?.toString() ?? 'N/A',
                icon: Icons.star_outline,
                color: Colors.amber,
              ),
              MetricCard(
                title: 'Avg Rating',
                value: _feedbackStats!.averageRating?.toStringAsFixed(1) ?? 'N/A',
                icon: Icons.thumb_up_outlined,
                color: Colors.green,
              ),
              MetricCard(
                title: 'Recent Feedback',
                value: '${_feedbackStats!.recentFeedbackCount}',
                icon: Icons.schedule,
                color: Colors.orange,
              ),
            ]),
            const SizedBox(height: 24),
            _buildFeedbackBreakdownCard(),
          ] else
            _buildNoDataCard('No feedback data available'),
        ],
      ),
    );
  }

  Widget _buildExperimentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('A/B Test Overview'),
          const SizedBox(height: 16),
          _buildMetricsGrid([
            MetricCard(
              title: 'Active Tests',
              value: '${_abTestData['active_tests'] ?? 0}',
              icon: Icons.science_outlined,
              color: Colors.purple,
            ),
            MetricCard(
              title: 'User Assignments',
              value: '${_abTestData['user_assignments'] ?? 0}',
              icon: Icons.person_outline,
              color: Colors.blue,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Active Experiments'),
          const SizedBox(height: 16),
          _buildExperimentsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('User Variants'),
          const SizedBox(height: 16),
          _buildUserVariantsCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMetricsGrid(List<MetricCard> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => _buildMetricCard(metrics[index]),
    );
  }

  Widget _buildMetricCard(MetricCard metric) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            metric.icon,
            size: 28,
            color: metric.color,
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: metric.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            metric.title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Last Hour Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_dashboardInsights['recent_activity_count'] ?? 0} events',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generated at: ${_formatDateTime(_dashboardInsights['generated_at'])}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEventsCard() {
    final topEvents = _dashboardInsights['top_events'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Most Frequent Events',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (topEvents.isEmpty)
              const Text('No events recorded yet')
            else
              ...topEvents.take(5).map((event) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event['event'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${event['count'] ?? 0}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'User Engagement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', _analyticsData['user_id'] ?? 'N/A'),
            _buildInfoRow('Current Session', _analyticsData['current_session_id'] ?? 'N/A'),
            _buildInfoRow('First Launch', _formatDateTime(_analyticsData['first_launch'])),
            _buildInfoRow('Last Active', _formatDateTime(_analyticsData['last_active'])),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    final rawDeviceInfo = _analyticsData['device_info'];
    final deviceInfo = rawDeviceInfo != null
        ? Map<String, dynamic>.from(rawDeviceInfo as Map)
        : <String, dynamic>{};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Device Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Platform', deviceInfo['platform'] ?? 'Unknown'),
            _buildInfoRow('App Version', deviceInfo['app_version'] ?? 'Unknown'),
            _buildInfoRow('Build Number', deviceInfo['build_number'] ?? 'Unknown'),
            _buildInfoRow('Device Model', deviceInfo['device_model'] ?? 'Unknown'),
            _buildInfoRow('OS Version', deviceInfo['os_version'] ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Session Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Session Start', _formatDateTime(_analyticsData['session_start_time'])),
            _buildInfoRow('Total Sessions', '${_analyticsData['session_count'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBreakdownCard() {
    if (_feedbackStats?.categoryBreakdown.isEmpty ?? true) {
      return _buildNoDataCard('No feedback categories available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Feedback by Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._feedbackStats!.categoryBreakdown.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentsCard() {
    final testNames = _abTestData['test_names'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Running Experiments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (testNames.isEmpty)
              const Text('No active experiments')
            else
              ...testNames.map((testName) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        testName.toString().replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserVariantsCard() {
    final rawVariants = _abTestData['user_variants'];
    final userVariants = rawVariants != null 
        ? Map<String, dynamic>.from(rawVariants as Map) 
        : <String, dynamic>{};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_pin, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Your Test Variants',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (userVariants.isEmpty)
              const Text('No variant assignments yet')
            else
              ...userVariants.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(value),
            child: Text(
              _truncateText(value, 20),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: ${_truncateText(text, 30)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class MetricCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
