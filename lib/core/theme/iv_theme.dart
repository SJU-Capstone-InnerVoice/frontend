// core/theme/iv_theme.dart

import 'package:flutter/material.dart';
import 'iv_colors.dart';

class IVTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: IVColors.primary,
    scaffoldBackgroundColor: IVColors.background,
    colorScheme: ColorScheme.light(
      primary: IVColors.primary,
      secondary: IVColors.secondary,
      background: IVColors.background,
      error: IVColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: IVColors.primary,
      foregroundColor: IVColors.textLight,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: IVColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: IVColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: IVColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: IVColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: IVColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        color: IVColors.textLight,
        fontWeight: FontWeight.w600,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: IVColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: IVColors.primary,
        foregroundColor: IVColors.textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IVColors.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: IVColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: IVColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: IVColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: IVColors.error),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: IVColors.primary,
      unselectedItemColor: IVColors.textSecondary,
      backgroundColor: IVColors.background,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardTheme(
      color: IVColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.black12,
    ),
    dividerTheme: const DividerThemeData(
      color: IVColors.divider,
      thickness: 1,
    ),
  );
}