import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                Text('Book Details', style: AppTextStyles.headlineMd),
                const Spacer(),
                const Icon(Icons.share_outlined),
                const SizedBox(width: 12),
                const Icon(Icons.bookmark_outline),
              ]),
              const SizedBox(height: AppSpacing.sm),
              _pill('YOUTH SANCTUARY ARCHIVE', AppColors.primary700),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: Container(
                  width: 140, height: 190,
                  decoration: BoxDecoration(color: AppColors.primary900, borderRadius: BorderRadius.circular(AppRadius.base)),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(child: _pill('Available to Borrow', AppColors.statusSuccess)),
              const SizedBox(height: 6),
              Center(child: Text('Mere Christianity', style: AppTextStyles.headlineXlMobile)),
              Center(child: Text('C.S. Lewis', style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary700))),
              Center(child: Text('HarperOne • 227 pages • English Edition', style: AppTextStyles.bodySm)),
              const SizedBox(height: AppSpacing.md),

              Row(children: [
                Expanded(child: _statBox('4.9', '42 Reviews')),
                Expanded(child: _statBox('14 Days', 'Loan Period')),
                Expanded(child: _statBox('3 of 4', 'Copies Left')),
              ]),
              const SizedBox(height: AppSpacing.sm),

              _card(child: Row(children: [
                const Icon(Icons.place_outlined, color: AppColors.primary700),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SANCTUARY LIBRARY LOCATION', style: AppTextStyles.labelSm),
                  Text('Section B • Shelf 2 • Copy #1', style: AppTextStyles.labelLg),
                ])),
                Text('Map View', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
              ])),
              const SizedBox(height: AppSpacing.sm),
              Text('Free church ministry loan • Renewable once via app before 14th day.', style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.md),

              _card(goldBorder: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('THEMATIC SCRIPTURE', style: AppTextStyles.labelSm.copyWith(color: AppColors.accent500)),
                const SizedBox(height: 6),
                Text('"Always be prepared to give an answer to everyone who asks you to give the reason for the hope that you have. But do this with gentleness and respect."', style: AppTextStyles.bodyMd.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('1 Peter 3:15', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
                  Text('Recommended for Youth Apologetics', style: AppTextStyles.bodySm),
                ]),
              ])),
              const SizedBox(height: AppSpacing.md),

              Text('Overview', style: AppTextStyles.headlineMd),
              const SizedBox(height: 6),
              Text(
                "Adapted from Lewis's historic wartime BBC radio broadcasts, Mere Christianity provides a brilliant, approachable defense of the common ground upon which all Christian convictions stand.",
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _tag('#Apologetics'), _tag('#ChristianLiving'), _tag('#FaithFoundations'),
              ]),
              const SizedBox(height: AppSpacing.md),

              Text('Community Voices', style: AppTextStyles.headlineMd),
              const SizedBox(height: 6),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const CircleAvatar(radius: 16, backgroundColor: AppColors.primary300, child: Icon(Icons.person, color: Colors.white, size: 16)),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bro. Joshua Ramos', style: AppTextStyles.labelMd),
                    Text('Varsity Fellowship • 3 days ago', style: AppTextStyles.bodySm),
                  ])),
                  const Icon(Icons.star, size: 14, color: AppColors.accent500),
                ]),
                const SizedBox(height: 6),
                Text('"Changed my perspective during college! A must-read for students preparing to explain their faith."', style: AppTextStyles.bodySm),
              ])),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.lock_open), label: const Text('Reserve & Borrow This Book'), style: AppButtonStyles.primary),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add to Ministry Reading List'), style: AppButtonStyles.secondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child, bool goldBorder = false}) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow, border: goldBorder ? const Border(left: BorderSide(color: AppColors.accent500, width: 4)) : null),
    child: child,
  );

  Widget _statBox(String value, String label) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.base), boxShadow: cardShadow),
    child: Column(children: [Text(value, style: AppTextStyles.labelLg), Text(label, style: AppTextStyles.bodySm, textAlign: TextAlign.center)]),
  );

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
  );
}