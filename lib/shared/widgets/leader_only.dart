import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/constants/roles.dart';
import '../../core/services/auth_service.dart';

/// Route guard: shows [child] only to a signed-in Youth Leader. A Youth
/// Member who somehow reaches the screen (deep link, old navigation stack)
/// sees a "leaders only" message instead of the page.
class LeaderOnly extends StatelessWidget {
  final Widget child;
  const LeaderOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user?.role == UserRole.leader) return child;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.neutralMuted),
              const SizedBox(height: AppSpacing.sm),
              Text('Youth Leaders only', style: AppTextStyles.headlineMd),
              const SizedBox(height: 4),
              Text('This page is only available to Youth Leaders.',
                  textAlign: TextAlign.center, style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ),
    );
  }
}
