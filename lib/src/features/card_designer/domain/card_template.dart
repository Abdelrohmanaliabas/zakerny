import 'package:flutter/material.dart';

enum CardThemeType {
  fatimidGold,
  propheticEmerald,
  midnightRoyal,
  whiteMarble,
}

class CardThemePreset {
  const CardThemePreset({
    required this.type,
    required this.name,
    required this.backgroundGradient,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.accentColor,
    required this.referenceColor,
  });

  final CardThemeType type;
  final String name;
  final Gradient backgroundGradient;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color accentColor;
  final Color referenceColor;

  static const presets = [
    CardThemePreset(
      type: CardThemeType.fatimidGold,
      name: 'الذهب الفاطمي',
      backgroundColor: Color(0xFF0F1511),
      backgroundGradient: LinearGradient(
        colors: [Color(0xFF131D17), Color(0xFF090D0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Color(0xFFC5A059),
      textColor: Color(0xFFFAF7EE),
      accentColor: Color(0xFFE2C485),
      referenceColor: Color(0xFFD4AF37),
    ),
    CardThemePreset(
      type: CardThemeType.propheticEmerald,
      name: 'الزمرد النبوي',
      backgroundColor: Color(0xFF0A231C),
      backgroundGradient: LinearGradient(
        colors: [Color(0xFF0D3328), Color(0xFF051712)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Color(0xFFD4AF37),
      textColor: Color(0xFFF0FDF4),
      accentColor: Color(0xFF6EE7B7),
      referenceColor: Color(0xFFFBBF24),
    ),
    CardThemePreset(
      type: CardThemeType.midnightRoyal,
      name: 'الكحلي الملكي',
      backgroundColor: Color(0xFF0B132B),
      backgroundGradient: LinearGradient(
        colors: [Color(0xFF121E42), Color(0xFF080C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Color(0xFF8DA3CE),
      textColor: Color(0xFFF8FAFC),
      accentColor: Color(0xFF93C5FD),
      referenceColor: Color(0xFF60A5FA),
    ),
    CardThemePreset(
      type: CardThemeType.whiteMarble,
      name: 'الرخام المذهب',
      backgroundColor: Color(0xFFFAF9F6),
      backgroundGradient: LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF5F3EC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Color(0xFFC5A059),
      textColor: Color(0xFF1E2923),
      accentColor: Color(0xFF8A6D3B),
      referenceColor: Color(0xFF78350F),
    ),
  ];
}
