import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/app/themes/app_colors.dart';

@module
abstract class AppTheme {
  @singleton
  ThemeData get theme {
    // TODO Implement dark theme

    return ThemeData.from(
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        surface: AppColors.lightBackground,
      ),
    ).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme,
      primaryTextTheme: _primaryTextTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  TextTheme get _textTheme {
    final baseTheme =
        Typography.material2021(platform: defaultTargetPlatform).black;

    return baseTheme.copyWith(
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),
    );
  }

  TextTheme get _primaryTextTheme {
    return _textTheme.copyWith(
      bodyLarge: _textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: _textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      bodySmall: _textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      displayLarge:
          _textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w600),
      displayMedium:
          _textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600),
      displaySmall:
          _textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineLarge:
          _textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium:
          _textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall:
          _textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium:
          _textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: _textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: _textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium:
          _textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: _textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.textBoxColor,
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
      ),
      labelStyle: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.red,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
