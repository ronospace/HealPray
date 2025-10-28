import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// Prayer Request model
class PrayerRequest {
  final String id;
  final String userName;
  final String userAvatar;
  final String title;
  final String content;
  final DateTime postedAt;
  final int prayerCount;
  final List<String> tags;
  final bool isUrgent;

  PrayerRequest({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.title,
    required this.content,
    required this.postedAt,
    required this.prayerCount,
    required this.tags,
    this.isUrgent = false,
  });
}

/// Community Prayers screen with prayer wall and circles
class CommunityPrayersScreen extends ConsumerStatefulWidget {
  const CommunityPrayersScreen({super.key});

  @override
  ConsumerState<CommunityPrayersScreen> createState() => _CommunityPrayersScreenState();
}

class _CommunityPrayersScreenState extends ConsumerState<CommunityPrayersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  // Sample data
  final List<PrayerRequest> _prayerWall = [
    PrayerRequest(
      id: '1',
      userName: 'Sarah Johnson',
      userAvatar: '👩‍🦰',
      title: 'Pray for my mother\'s surgery',
      content: 'My mother is having surgery tomorrow. Please pray for a successful operation and quick recovery.',
      postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      prayerCount: 47,
      tags: ['Health', 'Family'],
      isUrgent: true,
    ),
    PrayerRequest(
      id: '2',
      userName: 'Michael Chen',
      userAvatar: '👨',
      title: 'Job interview guidance',
      content: 'I have an important job interview next week. Praying for wisdom and confidence.',
      postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      prayerCount: 23,
      tags: ['Career', 'Guidance'],
    ),
    PrayerRequest(
      id: '3',
      userName: 'Emily Davis',
      userAvatar: '👩',
      title: 'Peace in relationships',
      content: 'Need prayers for healing and restoration in my family relationships.',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      prayerCount: 89,
      tags: ['Relationships', 'Peace'],
    ),
  ];

  final List<Map<String, dynamic>> _prayerCircles = [
    {
      'name': 'Parents Prayer Circle',
      'members': 127,
      'icon': Icons.family_restroom,
      'color': AppTheme.healingTeal,
      'description': 'Supporting parents through prayer',
    },
    {
      'name': 'Health & Healing',
      'members': 342,
      'icon': Icons.favorite,
      'color': AppTheme.hopeOrange,
      'description': 'Prayers for physical and emotional healing',
    },
    {
      'name': 'Career & Purpose',
      'members': 89,
      'icon': Icons.work,
      'color': AppTheme.wisdomGold,
      'description': 'Finding God\'s purpose in your career',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.public), text: 'Prayer Wall'),
            Tab(icon: Icon(Icons.groups), text: 'Circles'),
          ],
        ),
      ),
      body: AnimatedGradientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPrayerWallTab(),
            _buildPrayerCirclesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPrayerRequest,
        icon: const Icon(Icons.add),
        label: const Text('Share Request'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }

  Widget _buildPrayerWallTab() {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Urgent'),
                _buildFilterChip('Health'),
                _buildFilterChip('Family'),
                _buildFilterChip('Career'),
                _buildFilterChip('Relationships'),
              ],
            ),
          ),
        ),

        // Prayer Requests List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _prayerWall.length,
            itemBuilder: (context, index) {
              return _buildPrayerRequestCard(_prayerWall[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCirclesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _prayerCircles.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Icon(Icons.diversity_3, color: AppTheme.celestialCyan, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Join Prayer Circles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with others who share similar prayer needs',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final circle = _prayerCircles[index - 1];
        return _buildCircleCard(circle);
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedFilter = label),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        selectedColor: AppTheme.healingTeal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildPrayerRequestCard(PrayerRequest request) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.mysticalPurple, AppTheme.sacredBlue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    request.userAvatar,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          request.userName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (request.isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTimeAgo(request.postedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: AppTheme.mysticalPurple.withValues(alpha: 0.95),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Share', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Report', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Prayer Title
          Text(
            request.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Prayer Content
          Text(
            request.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: request.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Action Bar
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _prayForRequest(request),
                  icon: const Icon(Icons.favorite, size: 18),
                  label: Text('Pray (${request.prayerCount})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.healingTeal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCard(Map<String, dynamic> circle) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _joinCircle(circle),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: (circle['color'] as Color).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                circle['icon'] as IconData,
                color: circle['color'] as Color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    circle['description'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.white.withValues(alpha: 0.7), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${circle['members']} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  void _prayForRequest(PrayerRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Praying for ${request.userName}\'s request'),
        backgroundColor: AppTheme.healingTeal,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _joinCircle(Map<String, dynamic> circle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Join ${circle['name']}?', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Connect with ${circle['members']} others who share similar prayer needs.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joined ${circle['name']}'),
                  backgroundColor: AppTheme.healingTeal,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _createPrayerRequest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreatePrayerRequestScreen(),
      ),
    );
  }
}

/// Create Prayer Request Screen
class CreatePrayerRequestScreen extends StatefulWidget {
  const CreatePrayerRequestScreen({super.key});

  @override
  State<CreatePrayerRequestScreen> createState() => _CreatePrayerRequestScreenState();
}

class _CreatePrayerRequestScreenState extends State<CreatePrayerRequestScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isUrgent = false;

  final List<String> _availableTags = [
    'Health',
    'Family',
    'Career',
    'Relationships',
    'Guidance',
    'Peace',
    'Strength',
    'Gratitude',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Share Prayer Request'),
        actions: [
          TextButton(
            onPressed: _submitRequest,
            child: const Text(
              'Share',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              GlassCard(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'What do you need prayer for?',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),

              const SizedBox(height: 16),

              // Content Field
              GlassCard(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Share more details (optional)...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  minLines: 5,
                ),
              ),

              const SizedBox(height: 24),

              // Urgent Toggle
              GlassCard(
                child: Row(
                  children: [
                    Icon(Icons.priority_high, color: _isUrgent ? Colors.red : Colors.white70),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark as Urgent',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Request immediate prayer support',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isUrgent,
                      onChanged: (value) => setState(() => _isUrgent = value),
                      activeColor: Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tags Section
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    selectedColor: AppTheme.healingTeal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRequest() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title for your prayer request'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Prayer request shared with community'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }
}
