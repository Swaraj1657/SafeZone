import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/incident_card.dart';

/// HistoryScreen displays past incidents and alerts
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('History', style: AppTextStyles.heading),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'All', isSelected: true, onTap: () {}),
                  _FilterChip(label: 'Alerts', onTap: () {}),
                  _FilterChip(label: 'Safe Routes', onTap: () {}),
                  _FilterChip(label: 'Reports', onTap: () {}),
                ],
              ),
            ),
          ),

          // Incident list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                IncidentCard(
                  date: '2024-03-15',
                  time: '18:30',
                  location: 'Oak Street',
                  description: 'SOS Alert Triggered - Emergency contacts were notified',
                  status: IncidentStatus.resolved,
                  onTap: () {
                    // Handle incident tap
                  },
                ),
                IncidentCard(
                  date: '2024-03-14',
                  time: '21:15',
                  location: 'Office to Home',
                  description: 'Safe Route Navigation completed',
                  status: IncidentStatus.resolved,
                  onTap: () {
                    // Handle incident tap
                  },
                ),
                IncidentCard(
                  date: '2024-03-13',
                  time: '19:45',
                  location: 'Downtown Area',
                  description: 'Suspicious activity reported - Under investigation',
                  status: IncidentStatus.pending,
                  onTap: () {
                    // Handle incident tap
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}