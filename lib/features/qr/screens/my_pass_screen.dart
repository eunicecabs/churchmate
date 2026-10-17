import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';

/// A member's personal check-in pass. A Youth Leader scans it from the event
/// page. The QR holds only "USR-<account id>", nothing else.
class MyPassScreen extends StatelessWidget {
  const MyPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final roleLabel = user?.role == UserRole.leader ? 'Youth Leader' : 'Youth Member';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('My Check-in Pass', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: user == null
            ? Center(child: Text('Please sign in to see your pass.', style: AppTextStyles.bodyMd))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.margin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.prominent),
                        boxShadow: cardShadow,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration:
                                const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle),
                            child: const Icon(Icons.church, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(user.displayName,
                              textAlign: TextAlign.center, style: AppTextStyles.headlineLgMobile),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary300.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(roleLabel,
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.container),
                              border: Border.all(color: AppColors.primary300.withValues(alpha: 0.4)),
                            ),
                            child: QrImageView(
                              data: 'USR-${user.id}',
                              version: QrVersions.auto,
                              size: 220,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Show this to a Youth Leader when you arrive. It is personal, so please do not share it.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(Icons.brightness_high_outlined, size: 16, color: AppColors.neutralMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Turn your screen brightness up so the leader can scan it.',
                              style: AppTextStyles.bodySm),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}