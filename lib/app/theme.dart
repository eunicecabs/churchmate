import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ChurchMate design system — pulled directly from warm_sanctuary/DESIGN.md
/// (Stitch AI export). Use these everywhere instead of hardcoding hex values,
/// so every screen automatically stays consistent.
class AppColors {
  static const primary900 = Color(0xFF1E5631);
  static const primary700 = Color(0xFF2F7A4D);
  static const primary300 = Color(0xFF8FB99B);
  static const accent500 = Color(0xFFD4AF37);
  static const background = Color(0xFFF7F5E6);
  static const surface = Color(0xFFFFFFFF);
  static const neutralDark = Color(0xFF1F2937);
  static const neutralMuted = Color(0xFF5C6F61);
  static const statusSuccess = Color(0xFF10B981);
  static const statusPending = Color(0xFFF59E0B);
  static const statusAlert = Color(0xFFE11D48);
}

class AppRadius {
  static const base = 8.0;
  static const container = 16.0;
  static const prominent = 24.0;
  static const full = 999.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const margin = 20.0;
  static const marginSm = 16.0;
}

class AppTextStyles {
  static final headlineXlMobile = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 34 / 28,
    letterSpacing: -0.02 * 28,
    color: AppColors.neutralDark,
  );
  static final headlineLgMobile = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
    color: AppColors.neutralDark,
  );
  static final headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.neutralDark,
  );
  static final bodyLg = GoogleFonts.plusJakartaSans(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 26 / 17,
    color: AppColors.neutralDark,
  );
  static final bodyMd = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: AppColors.neutralDark,
  );
  static final bodySm = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.neutralMuted,
  );
  static final labelLg = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    color: AppColors.neutralDark,
  );
  static final labelMd = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 16 / 13,
    letterSpacing: 0.01 * 13,
    color: AppColors.neutralDark,
  );
  static final labelSm = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.04 * 11,
    color: AppColors.neutralMuted,
  );
}

class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary900,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.container)),
    elevation: 0,
  );

  static ButtonStyle secondary = OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primary700,
    minimumSize: const Size.fromHeight(50),
    side: const BorderSide(color: AppColors.primary700, width: 1.5),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.container)),
  );

  static ButtonStyle accent = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent500,
    foregroundColor: AppColors.neutralDark,
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.container)),
    elevation: 0,
  );
}

InputDecoration appInputDecoration({required String label, IconData? icon}) {
  return InputDecoration(
    hintText: label,
    prefixIcon: icon != null
        ? Icon(icon, color: AppColors.neutralMuted, size: 20)
        : null,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.container),
      borderSide:
          BorderSide(color: AppColors.primary300.withValues(alpha: 0.4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.container),
      borderSide:
          BorderSide(color: AppColors.primary300.withValues(alpha: 0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.container),
      borderSide: const BorderSide(color: AppColors.primary700, width: 1.5),
    ),
  );
}

final cardShadow = [
  BoxShadow(
      color: AppColors.primary900.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2)),
  BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 3,
      offset: const Offset(0, 1)),
];

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary900,
    primary: AppColors.primary900,
    secondary: AppColors.accent500,
  ),
  textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtonStyles.primary),
  outlinedButtonTheme:
      OutlinedButtonThemeData(style: AppButtonStyles.secondary),
);
