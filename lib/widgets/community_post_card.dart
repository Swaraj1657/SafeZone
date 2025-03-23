import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Categories for community posts
enum PostCategory {
  alert,
  tip,
  event,
}

/// Extension to get category display properties
extension PostCategoryExtension on PostCategory {
  String get label {
    switch (this) {
      case PostCategory.alert:
        return 'Alert';
      case PostCategory.tip:
        return 'Safety Tip';
      case PostCategory.event:
        return 'Event';
    }
  }

  Color get color {
    switch (this) {
      case PostCategory.alert:
        return AppColors.error;
      case PostCategory.tip:
        return AppColors.success;
      case PostCategory.event:
        return AppColors.primary;
    }
  }
}

/// A card widget that displays community posts
class CommunityPostCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String content;
  final PostCategory category;
  final bool isVerified;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  const CommunityPostCard({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.category,
    this.isVerified = false,
    this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    if (username.isEmpty || content.isEmpty) {
      return const SizedBox.shrink(); // Return empty widget for invalid data
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with username, verified badge, and time
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          username,
                          style: AppTextStyles.subheading,
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: AppTextStyles.caption,
                  ),
                  if (onShare != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: onShare,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Post content
              Text(
                content,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Category chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.label,
                  style: AppTextStyles.caption.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
