import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum LocationType { police, hospital, safetyCenter }

/// Card widget to display safety location information
class SafetyLocationCard extends StatelessWidget {
  final String name;
  final String distance;
  final LocationType type;

  const SafetyLocationCard({
    super.key,
    required this.name,
    required this.distance,
    required this.type,
  });

  IconData get _locationIcon {
    switch (type) {
      case LocationType.police:
        return Icons.local_police;
      case LocationType.hospital:
        return Icons.local_hospital;
      case LocationType.safetyCenter:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_locationIcon, color: AppColors.primary),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          distance,
          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.navigation_outlined, color: AppColors.primary),
          onPressed: () {
            // TODO: Implement navigation
          },
        ),
      ),
    );
  }
}
