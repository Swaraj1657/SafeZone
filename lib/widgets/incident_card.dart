import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum IncidentStatus {
  pending,
  resolved,
}

/// Card widget to display incident information
class IncidentCard extends StatelessWidget {
  final String date;
  final String time;
  final String location;
  final String description;
  final IncidentStatus status;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.status,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case IncidentStatus.pending:
        return AppColors.error;
      case IncidentStatus.resolved:
        return AppColors.success;
    }
  }

  String get _statusText {
    switch (status) {
      case IncidentStatus.pending:
        return 'Pending';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: AppTextStyles.subheading,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                location,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
