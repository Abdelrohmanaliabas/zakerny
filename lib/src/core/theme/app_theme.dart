import 'package:flutter/material.dart';
import '../widgets/fatimid_decorations.dart';

class AppTheme {
  // الألوان الفاطمية الأصيلة (الأزهر والأقمر ومحاريب القاهرة الفاطمية)
  static const emerald = FatimidColors.emeraldPrimary;
  static const deepEmerald = FatimidColors.emeraldDark;
  static const mediumEmerald = FatimidColors.emeraldMedium;
  static const gold = FatimidColors.goldPrimary;
  static const goldLight = FatimidColors.goldLight;
  static const lightSurface = FatimidColors.parchmentLight;
  static const darkSurface = FatimidColors.obsidianDark;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: Brightness.light,
      primary: emerald,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE2F1EC),
      onPrimaryContainer: emerald,
      secondary: gold,
      onSecondary: const Color(0xFF332000),
      secondaryContainer: const Color(0xFFF9F1D8),
      onSecondaryContainer: const Color(0xFF523B06),
      surface: lightSurface,
      onSurface: const Color(0xFF1B2B25),
      surfaceContainerHighest: const Color(0xFFEDE8DD),
      outlineVariant: const Color(0xFFDCD5C6),
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: lightSurface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF143026),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: gold.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: Brightness.dark,
      primary: const Color(0xFF10B981),
      onPrimary: const Color(0xFF04261C),
      primaryContainer: const Color(0xFF0C3D30),
      onPrimaryContainer: const Color(0xFFA7F3D0),
      secondary: gold,
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF382A08),
      onSecondaryContainer: goldLight,
      surface: darkSurface,
      onSurface: const Color(0xFFEAF5F0),
      surfaceContainerHighest: const Color(0xFF152A23),
      outlineVariant: const Color(0xFF234438),
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFEAF7F1),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: FatimidColors.obsidianCard.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: gold.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: scheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          shadowColor: scheme.primary.withValues(alpha: 0.35),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: gold,
        checkmarkColor: Colors.black87,
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: gold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0C1814) : Colors.white,
        selectedItemColor: gold,
        unselectedItemColor: isDark ? const Color(0xFF708C82) : const Color(0xFF869E95),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF13251F) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: gold.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: gold.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: gold,
            width: 1.5,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: gold.withValues(alpha: 0.15),
        thickness: 0.8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? FatimidColors.obsidianCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
