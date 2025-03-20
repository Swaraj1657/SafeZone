import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/community_post_card.dart';

/// CommunityScreen shows safety alerts and community posts
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Community', style: AppTextStyles.heading),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search safety alerts...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),

          // Category tabs
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryTab(label: 'All Posts', isSelected: true),
                _CategoryTab(label: 'Safety Tips'),
                _CategoryTab(label: 'Alerts'),
                _CategoryTab(label: 'Events'),
              ],
            ),
          ),

          // Posts list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                CommunityPostCard(
                  username: 'Sarah M.',
                  timeAgo: '5m ago',
                  content:
                      'Street lights are not working on Oak Street. Please be careful if walking alone.',
                  category: PostCategory.alert,
                ),
                CommunityPostCard(
                  username: 'Safety Officer',
                  timeAgo: '30m ago',
                  content:
                      'Remember to share your location with trusted contacts when traveling late.',
                  category: PostCategory.tip,
                  isVerified: true,
                ),
                CommunityPostCard(
                  username: 'Community Center',
                  timeAgo: '2h ago',
                  content:
                      'Self-defense workshop this Saturday at 10 AM. All women welcome!',
                  category: PostCategory.event,
                  isVerified: true,
                ),
              ],
            ),
          ),
        ],
      ),
      // Add post button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryTab({
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
