import 'package:flutter/material.dart';
import '../widgets/sos_button.dart';
import '../utils/constants.dart';

/// HomeScreen is the main screen of the application
/// It contains the SOS button and bottom navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            // User Greeting Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hello, Sarah!', // This would come from user authentication
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Main Content with SOS Button
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SOSButton(),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Hold the SOS button to alert',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'This will notify your emergency contacts and nearby authorities',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.75),
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
}
