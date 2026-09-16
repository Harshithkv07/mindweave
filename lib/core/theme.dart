import 'package:flutter/material.dart';

/// Accessibility-first design tokens and dimensional constants for MindWeave.
/// Enforces WCAG AAA compliance, large touch targets, and high-legibility sizing
/// optimized for seniors and individuals with cognitive or motor impairments.
class AppDimensions {
  AppDimensions._();

  /// Minimum interactive touch target size (WCAG 2.5.5 / 2.5.8 AAA standard)
  static const double minTouchTarget = 48.0;

  /// Generous standard touch target for primary senior actions
  static const double standardTouchTarget = 56.0;

  /// High-legibility minimum font size to avoid visual strain
  static const double minLegibleFontSize = 15.0;

  /// Rounded corner radiuses
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusExtraLarge = 24.0;
  static const double radiusPill = 100.0;

  /// Content padding constants
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0);
  static const EdgeInsets inputPadding =
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
}

/// High-contrast accessible color palette for MindWeave.
/// Guarantees contrast ratios > 7:1 (WCAG AAA) for primary text and controls.
class AppColors {
  AppColors._();

  // Primary High-Contrast Brand Tones (Deep Navy / Royal Indigo)
  static const Color primaryDark = Color(0xFF0F3876); // High contrast dark blue
  static const Color primary = Color(0xFF1E40AF); // Crisp royal blue
  static const Color primaryLight = Color(0xFF3B82F6); // Soft bright blue
  static const Color primaryContainer = Color(0xFFDBEAFE); // Tinted container
  static const Color onPrimaryContainer = Color(0xFF0A2540); // Deep dark text

  // Secondary Clinical Tones (Deep Soothing Teal)
  static const Color secondary = Color(0xFF0F766E); // Medical accessible teal
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF042F2E);

  // Tertiary Sensory Tones (Warm Amber / Bronze)
  static const Color tertiary = Color(0xFFB45309); // High contrast amber
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiaryContainer = Color(0xFF78350F);

  // Neutral High-Contrast Surfaces (Crisp light mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFCBD5E1);
  static const Color borderFocus = Color(0xFF0F3876);

  // High-Legibility Text Colors (WCAG AAA compliant against light backgrounds)
  static const Color textPrimary = Color(0xFF0F172A); // Ultra-dark slate (> 14:1)
  static const Color textSecondary = Color(0xFF334155); // Dark charcoal (> 7:1)
  static const Color textMuted = Color(0xFF475569); // Muted slate (> 5.5:1)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Feedback Colors (High contrast with soft pill backgrounds)
  static const Color success = Color(0xFF15803D); // Deep green
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF14532D);

  static const Color warning = Color(0xFFB45309); // Dark amber
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);

  static const Color error = Color(0xFFB91C1C); // Crimson red
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF0369A1); // Deep cyan
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF075985);

  // Dark Mode High-Contrast Surfaces
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF151E2E);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
}

/// Accessibility-first UI theme configuration for MindWeave.
/// Provides scalable typography, rounded button shapes, minimum 48x48 touch targets,
/// and high-contrast color schemes.
class AppTheme {
  AppTheme._();

  /// Large scalable typography configured with generous line heights and strong weights
  /// for effortless reading across mobile and tablet screens.
  static final TextTheme _scalableTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34.0,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.25,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      height: 1.45,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 1.45,
      color: AppColors.textMuted,
    ),
    labelLarge: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      height: 1.35,
      letterSpacing: 0.2,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.textMuted,
    ),
  );

  /// Primary Light Theme (WCAG AAA High-Contrast)
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Arial',
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.backgroundLight,
      outline: AppColors.borderLight,
      outlineVariant: Color(0xFFE2E8F0),
      shadow: Color(0x1A0F172A),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _scalableTextTheme,

      // Material interactive minimum 48x48 tap targets
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          fontFamily: 'Arial',
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 26.0,
        ),
      ),

      // Rounded Button Themes with minimum 48x48 logical pixels
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.standardTouchTarget),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: 2,
          padding: AppDimensions.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arial',
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.standardTouchTarget),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: AppDimensions.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arial',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.standardTouchTarget),
          foregroundColor: AppColors.primaryDark,
          padding: AppDimensions.buttonPadding,
          side: const BorderSide(
            color: AppColors.primaryDark,
            width: 2.0, // High-visibility border
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arial',
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arial',
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
          padding: const EdgeInsets.all(12.0),
          foregroundColor: AppColors.textPrimary,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        sizeConstraints: const BoxConstraints.tightFor(
          width: AppDimensions.standardTouchTarget,
          height: AppDimensions.standardTouchTarget,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
      ),

      // Card Theme with high contrast outline & rounded edges
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceLight,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
      ),

      // Input Decoration Theme with high contrast focus & minimum 48px height
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: AppDimensions.inputPadding,
        labelStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.borderFocus,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
      ),

      // Highly Legible Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        height: 80.0,
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryContainer,
        elevation: 6,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 15.0,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontFamily: 'Arial',
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 28.0,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          );
        }),
      ),

      // Dialog & BottomSheet Themes
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          fontFamily: 'Arial',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 17.0,
          color: AppColors.textSecondary,
          height: 1.45,
          fontFamily: 'Arial',
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusExtraLarge),
          ),
        ),
      ),
    );
  }

  /// Dark Theme Option (High-Contrast for night or photophobia accessibility)
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Arial',
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF60A5FA),
      onPrimary: Color(0xFF0F172A),
      primaryContainer: Color(0xFF1E3A8A),
      onPrimaryContainer: Color(0xFFDBEAFE),
      secondary: Color(0xFF2DD4BF),
      onSecondary: Color(0xFF042F2E),
      secondaryContainer: Color(0xFF115E59),
      onSecondaryContainer: Color(0xFFCCFBF1),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF451A03),
      tertiaryContainer: Color(0xFF78350F),
      onTertiaryContainer: Color(0xFFFEF3C7),
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.backgroundDark,
      outline: AppColors.borderDark,
      outlineVariant: Color(0xFF1E293B),
      shadow: Colors.black,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _scalableTextTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.standardTouchTarget),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: AppDimensions.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(
            color: AppColors.borderDark,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
