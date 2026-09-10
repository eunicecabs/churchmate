import 'package:flutter/material.dart';

/// Central place for app-wide styling. Keep colors/fonts here rather than
/// hardcoding them in individual screens.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: const Color(0xFF2E5395),
  fontFamily: 'Roboto',
);
