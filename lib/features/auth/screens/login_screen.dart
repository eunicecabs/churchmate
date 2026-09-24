import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLeader = false; // Youth Member vs Youth Leader toggle
  bool _isSignIn = true;  // Sign In vs Register tab

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary900,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent500, width: 2),
                      ),
                      child: const Icon(Icons.church, color: Colors.white, size: 40),
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: AppColors.accent500, shape: BoxShape.circle),
                        child: const Icon(Icons.eco, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('ChurchMate', textAlign: TextAlign.center, style: AppTextStyles.headlineXlMobile),
              const SizedBox(height: AppSpacing.xs),
              Text('Our Daily Bread Presbyterian Church – Dayap',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary700, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.3), borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: Text('• YOUTH MINISTRY PORTAL', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Faith, Fellowship & Service',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: AppSpacing.lg),

              // Main card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.prominent),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Role toggle: Member / Leader
                    Row(
                      children: [
                        Expanded(child: _roleButton('Youth Member', Icons.groups, !_isLeader, () => setState(() => _isLeader = false))),
                        const SizedBox(width: 8),
                        Expanded(child: _roleButton('Youth Leader', Icons.shield_outlined, _isLeader, () => setState(() => _isLeader = true))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign In / Register tab
                    Row(
                      children: [
                        Expanded(child: _tabButton('Sign In', _isSignIn, () => setState(() => _isSignIn = true))),
                        Expanded(child: _tabButton('Register New Member', !_isSignIn, () => setState(() => _isSignIn = false))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (!_isSignIn) ...[
                      Text('Full Name', style: AppTextStyles.labelMd),
                      const SizedBox(height: 6),
                      TextField(controller: _fullNameController, decoration: appInputDecoration(label: 'Juan Dela Cruz', icon: Icons.person_outline)),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    Text('Email or Youth ID', style: AppTextStyles.labelMd),
                    const SizedBox(height: 6),
                    TextField(controller: _emailController, decoration: appInputDecoration(label: 'e.g. youth@dayap.church or ODB-2', icon: Icons.person_outline)),
                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: AppTextStyles.labelMd),
                        if (_isSignIn) Text('Forgot?', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: appInputDecoration(label: 'Enter password', icon: Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    if (!_isSignIn) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text('Confirm Password', style: AppTextStyles.labelMd),
                      const SizedBox(height: 6),
                      TextField(controller: _confirmPasswordController, obscureText: true, decoration: appInputDecoration(label: 'Repeat password', icon: Icons.lock_outline)),
                    ],

                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: wire to AuthService once backend is ready
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                      icon: Icon(_isSignIn ? Icons.arrow_forward : Icons.check),
                      label: Text(_isSignIn ? 'Sign In to ChurchMate' : 'Create Account'),
                      style: AppButtonStyles.primary,
                    ),

                    if (_isSignIn) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text("OR JOIN TODAY'S FELLOWSHIP", style: AppTextStyles.labelSm),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/scan'),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Quick Attendance Scan (No Login)'),
                        style: AppButtonStyles.secondary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Verse card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary300.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  border: Border(left: BorderSide(color: AppColors.accent500, width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Don\'t let anyone look down on you because you are young, but set an example for the believers in speech, in conduct, in love, in faith and in purity."',
                      style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 Timothy 4:12', style: AppTextStyles.labelMd.copyWith(color: AppColors.accent500)),
                        Text('Dayap Youth Theme', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Need assistance registering? Talk to a Pastor or any Youth Council volunteer.',
                  textAlign: TextAlign.center, style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary900 : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.container),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : AppColors.neutralMuted),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelMd.copyWith(color: selected ? Colors.white : AppColors.neutralMuted)),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.base),
        ),
        child: Text(
          label, textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(color: selected ? AppColors.primary900 : AppColors.neutralMuted),
        ),
      ),
    );
  }
}