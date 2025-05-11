// core/theme/iv_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';
import 'iv_colors.dart';

class IVTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: GoogleFonts.ibmPlexSansKr().fontFamily,
    primaryColor: IVColors.primary,
    scaffoldBackgroundColor: IVColors.background,
    colorScheme: ColorScheme.light(
      primary: IVColors.primary,
      secondary: IVColors.secondary,
      background: IVColors.background,
      error: IVColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: IVColors.background,
      foregroundColor: IVColors.textLight,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: IVColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: IVColors.textPrimary,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: IVColors.textPrimary,
        size: 24,
      ),
    ),
    textTheme: GoogleFonts.ibmPlexSansKrTextTheme().copyWith(
      displayLarge: const TextStyle(
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
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[300]!;
          }
          return Colors.orange;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[600]!;
          }
          return Colors.white;
        }),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IVColors.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: IVColors.textSecondary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: IVColors.divider,
      thickness: 1,
    ),
  );
}