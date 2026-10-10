// Shows the signed-in user's real info (name, email, role, photo) and lets
// them edit their profile, reset their password, or log out.
// Reached from the avatar icon in the Dashboard's top bar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.container)),
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusAlert),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Grab the navigator before the async gap / provider teardown.
    final navigator = Navigator.of(context);
    await context.read<AuthService>().logout();

    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  Future<void> _resetPassword(BuildContext context) async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;

    if (auth.isGoogleUser) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.container)),
          title: const Text('Managed by Google'),
          content: const Text(
              'This account signs in with Google, so its password is managed by your Google account, not ChurchMate. Change it from your Google Account settings.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Got it')),
          ],
        ),
      );
      return;
    }

    try {
      await auth.sendPasswordResetEmail(user.email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password reset email sent to ${user.email}.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not send reset email. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  boxShadow: cardShadow,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary300,
                      backgroundImage:
                          (user?.photoUrl != null) ? NetworkImage(user!.photoUrl!) : null,
                      child: (user?.photoUrl == null)
                          ? const Icon(Icons.person, color: Colors.white, size: 28)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.fullName ?? 'Signed-in User', style: AppTextStyles.headlineMd),
                          const SizedBox(height: 2),
                          Text(user?.email ?? '', style: AppTextStyles.bodySm),
                          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(user.phone!, style: AppTextStyles.bodySm),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary300.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              (user?.role ?? 'member').toUpperCase(),
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
                style: AppButtonStyles.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('ACCOUNT', style: AppTextStyles.labelSm),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_reset_outlined, color: AppColors.primary700),
                      title: Text('Reset Password', style: AppTextStyles.labelLg),
                      subtitle: Text(
                        context.watch<AuthService>().isGoogleUser
                            ? 'Managed by your Google account'
                            : 'Send a reset link to your email',
                        style: AppTextStyles.bodySm,
                      ),
                      onTap: () => _resetPassword(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.statusAlert),
                      title: Text('Log Out',
                          style: AppTextStyles.labelLg.copyWith(color: AppColors.statusAlert)),
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
