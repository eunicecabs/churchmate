import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  static const _rememberKey = 'remember_email';

  bool _isLeader = false; // Youth Member vs Youth Leader toggle
  bool _isSignIn = true; // Sign In vs Register tab
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Inline messages. null = no error. '' = red border only (no text).
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _shake.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  void _goHome() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_rememberKey);
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = saved;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_rememberKey, _emailController.text.trim());
    } else {
      await prefs.remove(_rememberKey);
    }
  }

  bool _looksLikeEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  void _clearErrors() {
    if (_nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null &&
        _formError == null) {
      return;
    }
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _formError = null;
    });
  }

  void _showErrors({String? name, String? email, String? password, String? confirm, String? form}) {
    if (!mounted) return;
    setState(() {
      _nameError = name;
      _emailError = email;
      _passwordError = password;
      _confirmError = confirm;
      _formError = form;
    });
    _shake.forward(from: 0);
  }

  void _applyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        _showErrors(email: '', password: 'Incorrect email or password. Please check and try again.');
        break;
      case 'invalid-email':
        _showErrors(email: "That doesn't look like an email address.");
        break;
      case 'email-already-in-use':
        _showErrors(email: 'This email is already registered. Try signing in instead.');
        break;
      case 'weak-password':
        _showErrors(password: 'Password is too weak. Use at least 6 characters.');
        break;
      case 'password-mismatch':
        _showErrors(confirm: 'Passwords do not match.');
        break;
      case 'user-disabled':
        _showErrors(form: 'This account has been disabled. Please contact a Youth Leader.');
        break;
      case 'too-many-requests':
        _showErrors(form: 'Too many attempts. Please wait a few minutes and try again.');
        break;
      case 'network-request-failed':
        _showErrors(form: 'No internet connection. Please check your connection and try again.');
        break;
      default:
        _showErrors(form: e.message ?? 'Something went wrong (${e.code}). Please try again.');
    }
  }

  // ---------- actions ----------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    String? nameMsg, emailMsg, passMsg, confirmMsg;
    if (!_isSignIn && name.isEmpty) nameMsg = 'Please enter your full name.';
    if (email.isEmpty) {
      emailMsg = 'Please enter your email.';
    } else if (!_looksLikeEmail(email)) {
      emailMsg = "That doesn't look like an email address.";
    }
    if (password.isEmpty) {
      passMsg = 'Please enter your password.';
    } else if (!_isSignIn && password.length < 6) {
      passMsg = 'Use at least 6 characters.';
    }
    if (!_isSignIn && confirm != password) confirmMsg = 'Passwords do not match.';

    if (nameMsg != null || emailMsg != null || passMsg != null || confirmMsg != null) {
      _showErrors(name: nameMsg, email: emailMsg, password: passMsg, confirm: confirmMsg);
      return;
    }
    _clearErrors();

    final auth = context.read<AuthService>();
    setState(() => _isLoading = true);
    try {
      if (_isSignIn) {
        await auth.login(
          email: email,
          password: password,
          expectedRole: _isLeader ? UserRole.leader : UserRole.member,
        );
        await _saveRememberedEmail();
      } else {
        await auth.register(
          fullName: name,
          email: email,
          password: password,
          role: _isLeader ? UserRole.leader : UserRole.member,
        );
      }
      _goHome();
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth error: ${e.code} - ${e.message}');
      _applyAuthError(e);
    } catch (e) {
      debugPrint('Sign-in error: $e');
      _showErrors(form: 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    final auth = context.read<AuthService>();
    setState(() => _isGoogleLoading = true);
    try {
      final user = await auth.signInWithGoogle(role: _isLeader ? UserRole.leader : UserRole.member);
      if (user == null) return; // user cancelled the picker
      _goHome();
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in error: ${e.code} - ${e.message}');
      _applyAuthError(e);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _showErrors(form: 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrors(email: 'Enter your email first, then tap "Forgot?".');
      return;
    }
    try {
      await context.read<AuthService>().sendPasswordResetEmail(email);
      _showSnack('Password reset email sent to $email.');
    } on FirebaseAuthException catch (e) {
      _applyAuthError(e);
    }
  }

  // ---------- small UI pieces ----------

  InputDecoration _decor(String label, IconData icon, {required bool error}) {
    final base = appInputDecoration(label: label, icon: icon);
    if (!error) return base;
    final red = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.container),
      borderSide: const BorderSide(color: AppColors.statusAlert, width: 1.5),
    );
    return base.copyWith(
      fillColor: AppColors.statusAlert.withValues(alpha: 0.05),
      border: red,
      enabledBorder: red,
      focusedBorder: red,
      prefixIcon: Icon(icon, color: AppColors.statusAlert, size: 20),
    );
  }

  Widget _errorText(String? message) {
    final show = message != null && message.isNotEmpty;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.statusAlert),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(message,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.statusAlert)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _errorBanner(String? message) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.statusAlert.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.base),
                border: Border.all(color: AppColors.statusAlert.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.statusAlert),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(message,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.statusAlert)),
                  ),
                ],
              ),
            ),
    );
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.lg),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 24 * (1 - value)), child: child),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary900,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent500, width: 2),
                        ),
                        child: const Icon(Icons.church, color: Colors.white, size: 40),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                              color: AppColors.accent500, shape: BoxShape.circle),
                          child: const Icon(Icons.eco, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('ChurchMate',
                    textAlign: TextAlign.center, style: AppTextStyles.headlineXlMobile),
                const SizedBox(height: AppSpacing.xs),
                Text('Our Daily Bread Presbyterian Church – Dayap',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.primary700, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.primary300.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Text('• YOUTH MINISTRY PORTAL',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Faith, Fellowship & Service',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: AppSpacing.lg),

                // Main card (shakes on error)
                AnimatedBuilder(
                  animation: _shake,
                  builder: (context, child) {
                    final t = _shake.value;
                    final dx = sin(t * pi * 6) * 10 * (1 - t);
                    return Transform.translate(offset: Offset(dx, 0), child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.prominent),
                      boxShadow: cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role toggle: Member / Leader
                          Row(
                            children: [
                              Expanded(
                                  child: _roleButton('Youth Member', Icons.groups, !_isLeader,
                                      () => setState(() => _isLeader = false))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _roleButton('Youth Leader', Icons.shield_outlined, _isLeader,
                                      () => setState(() => _isLeader = true))),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Sign In / Register tab
                          Row(
                            children: [
                              Expanded(
                                  child: _tabButton('Sign In', _isSignIn, () {
                                _clearErrors();
                                setState(() => _isSignIn = true);
                              })),
                              Expanded(
                                  child: _tabButton('Register New Member', !_isSignIn, () {
                                _clearErrors();
                                setState(() => _isSignIn = false);
                              })),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Full name (register only, slides open)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            alignment: Alignment.topCenter,
                            child: _isSignIn
                                ? const SizedBox(width: double.infinity)
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text('Full Name', style: AppTextStyles.labelMd),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _fullNameController,
                                        textCapitalization: TextCapitalization.words,
                                        onChanged: (_) => _clearErrors(),
                                        decoration: _decor('Juan Dela Cruz', Icons.person_outline,
                                            error: _nameError != null),
                                      ),
                                      _errorText(_nameError),
                                      const SizedBox(height: AppSpacing.sm),
                                    ],
                                  ),
                          ),

                          // Email
                          Text('Email', style: AppTextStyles.labelMd),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => _clearErrors(),
                            decoration: _decor('e.g. youth@dayap.church', Icons.email_outlined,
                                error: _emailError != null),
                          ),
                          _errorText(_emailError),
                          const SizedBox(height: AppSpacing.sm),

                          // Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Password', style: AppTextStyles.labelMd),
                              if (_isSignIn)
                                GestureDetector(
                                  onTap: _forgotPassword,
                                  child: Text('Forgot?',
                                      style: AppTextStyles.labelMd
                                          .copyWith(color: AppColors.primary700)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: (_) => _clearErrors(),
                            decoration: _decor('Enter password', Icons.lock_outline,
                                    error: _passwordError != null)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          _errorText(_passwordError),

                          // Confirm password (register only, slides open)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            alignment: Alignment.topCenter,
                            child: _isSignIn
                                ? const SizedBox(width: double.infinity)
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: AppSpacing.sm),
                                      Text('Confirm Password', style: AppTextStyles.labelMd),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _confirmPasswordController,
                                        obscureText: true,
                                        onChanged: (_) => _clearErrors(),
                                        decoration: _decor('Repeat password', Icons.lock_outline,
                                            error: _confirmError != null),
                                      ),
                                      _errorText(_confirmError),
                                    ],
                                  ),
                          ),

                          // Remember me (sign in only)
                          if (_isSignIn) ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.primary900,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                  ),
                                  Text('Remember me', style: AppTextStyles.bodySm),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.sm),
                          _errorBanner(_formError),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(_isSignIn ? Icons.arrow_forward : Icons.check),
                            label: Text(_isSignIn ? 'Sign In to ChurchMate' : 'Create Account'),
                            style: AppButtonStyles.primary,
                          ),

                          const SizedBox(height: AppSpacing.md),
                          Row(children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('OR', style: AppTextStyles.labelSm),
                            ),
                            const Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: _isGoogleLoading ? null : _continueWithGoogle,
                            icon: _isGoogleLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.g_mobiledata, size: 26),
                            label: const Text('Continue with Google'),
                            style: AppButtonStyles.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Verse card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary300.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.container),
                    border: const Border(left: BorderSide(color: AppColors.accent500, width: 4)),
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
                          Text('1 Timothy 4:12',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.accent500)),
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
            Text(label,
                style: AppTextStyles.labelMd
                    .copyWith(color: selected ? Colors.white : AppColors.neutralMuted)),
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
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd
              .copyWith(color: selected ? AppColors.primary900 : AppColors.neutralMuted),
        ),
      ),
    );
  }
}