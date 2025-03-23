import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// CustomBottomNavBar provides navigation between main app sections
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: true,
                onTap: () {},
              ),
              _NavBarItem(
                icon: Icons.location_on,
                label: 'Location',
                onTap: () {},
              ),
              _NavBarItem(icon: Icons.history, label: 'History', onTap: () {}),
              _NavBarItem(icon: Icons.people, label: 'Community', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item widget
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
