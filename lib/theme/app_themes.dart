import 'package:flutter/material.dart';

/// A config of themes used in the app
class AppThemes {
  static const _lightAppColors = _AppColors.light();

  static final light = ThemeData.light().copyWith(
    scaffoldBackgroundColor: _lightAppColors.scaffoldBackgroundColor,
    colorScheme: const ColorScheme.light().copyWith(
      primary: _lightAppColors.accentColor,
      secondary: _lightAppColors.accentColor,
    ),
    appBarTheme: AppBarTheme(
      color: _lightAppColors.accentColor,
      foregroundColor: _lightAppColors.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
    ),
    //TODO this is because _PackagesView from about.dart uses card color for background color
    cardColor: _lightAppColors.scaffoldBackgroundColor,
  );
}

class _AppColors {
  final Color scaffoldBackgroundColor;
  final Color accentColor;
  final Color disabledColor;

  const _AppColors.light()
      : scaffoldBackgroundColor = const Color(0xffffffff),
        accentColor = const Color(0xff009688),
        disabledColor = const Color(0xffafafaf);
}
