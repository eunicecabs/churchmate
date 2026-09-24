import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  static const _cycleSeconds = 102; // 01:42, matches the design reference
  int _secondsLeft = _cycleSeconds;
  late String _token;
  Timer? _timer;
  int _checkedIn = 48;
  final int _expected = 65;

  @override
  void initState() {
    super.initState();
    _token = _generateToken();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_secondsLeft <= 1) {
          // Code expired — generate a brand new one, proving it's time-sensitive
          _token = _generateToken();
          _secondsLeft = _cycleSeconds;
        } else {
          _secondsLeft--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _generateToken() {
    final suffix = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'ODB-YOUTH-2024-1020-$suffix';
  }

  String get _formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pct = _checkedIn / _expected;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle),
                    child: const Icon(Icons.church, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text('Event QR Code', style: AppTextStyles.headlineMd),
                  const Spacer(),
                  const CircleAvatar(radius: 16, backgroundColor: AppColors.primary300, child: Icon(Icons.person, color: Colors.white, size: 16)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Event info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [_pill('ODB Presbyterian • Dayap', AppColors.primary700), const SizedBox(width: 6), _pill('Active', AppColors.statusSuccess)]),
                          const SizedBox(height: 4),
                          Text('Youth Fellowship: Rooted & Grounded', style: AppTextStyles.headlineMd),
                          Row(children: [
                            const Icon(Icons.place_outlined, size: 14, color: AppColors.neutralMuted),
                            const SizedBox(width: 2),
                            Text('Main Sanctuary • Sunday 4:00 PM', style: AppTextStyles.bodySm),
                          ]),
                        ],
                      ),
                    ),
                    const Icon(Icons.tune, color: AppColors.neutralMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // QR card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.prominent), boxShadow: cardShadow),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.25), borderRadius: BorderRadius.circular(AppRadius.full)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.refresh, size: 14, color: AppColors.primary900),
                        const SizedBox(width: 6),
                        Text('Refreshes in ', style: AppTextStyles.bodySm),
                        Text(_formattedTime, style: AppTextStyles.labelMd.copyWith(color: AppColors.statusPending)),
                        const SizedBox(width: 6),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.statusSuccess, shape: BoxShape.circle)),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.container)),
                      child: QrImageView(
                        data: _token,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: AppColors.background,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primary900),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.primary900),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.base)),
                      child: Text('TOKEN: $_token', style: AppTextStyles.labelSm.copyWith(letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Point youth member camera at code. Valid for in-person sanctuary attendance.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Stats card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$_checkedIn', style: AppTextStyles.headlineXlMobile.copyWith(fontSize: 32)),
                              const SizedBox(width: 6),
                              Text('Checked In', style: AppTextStyles.labelLg),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 52, height: 52,
                          child: Stack(alignment: Alignment.center, children: [
                            CircularProgressIndicator(
                              value: pct, strokeWidth: 5,
                              backgroundColor: AppColors.primary300.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary700),
                            ),
                            Text('${(pct * 100).round()}%', style: AppTextStyles.labelSm),
                          ]),
                        ),
                      ],
                    ),
                    Text('out of $_expected expected (${(pct * 100).round()}% capacity)', style: AppTextStyles.bodySm),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: pct, minHeight: 8,
                        backgroundColor: AppColors.primary300.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _checkedIn = (_checkedIn + 1).clamp(0, _expected));
                },
                icon: const Icon(Icons.fullscreen),
                label: const Text('Full-Screen Kiosk Mode'),
                style: AppButtonStyles.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.print_outlined, size: 18), label: const Text('Print Poster'), style: AppButtonStyles.secondary)),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.list_alt_outlined, size: 18), label: const Text('Manual Roster'), style: AppButtonStyles.secondary)),
              ]),
              const SizedBox(height: AppSpacing.md),

              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.base)),
                child: Row(children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.accent500),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Mount this device at hip-to-chest height under good entrance lighting for instant phone scan reads.', style: AppTextStyles.bodySm)),
                ]),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}