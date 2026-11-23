import 'package:flutter/material.dart';

class AppTheme {
  // A richer, more saturated emerald-teal than before, with a warm
  // complementary accent so light and dark mode both feel designed rather
  // than default Material.
  static const seed = Color(0xFF0E8E73);
  static const _accent = Color(0xFFFF8A3D);
  static const _lightBg = Color(0xFFF4F9F7);
  static const _darkBg = Color(0xFF0E1513);
  static const _darkSurface = Color(0xFF162420);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    scheme = scheme.copyWith(
        tertiary: _accent,
        tertiaryContainer: b == Brightness.light
            ? _accent.withValues(alpha: 0.18)
            : _accent.withValues(alpha: 0.28));
    final isLight = b == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? _lightBg : _darkBg,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: isLight ? _lightBg : _darkBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: isLight ? 1 : 0,
        color: isLight ? Colors.white : _darkSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        indicatorColor: scheme.primaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Color statusColor(String status, ColorScheme s) {
    switch (status) {
      case 'active':
      case 'paid':
      case 'rented':
        return Colors.green.shade600;
      case 'available':
        return Colors.blue.shade600;
      case 'partial':
      case 'maintenance':
      case 'suspended':
        return Colors.orange.shade700;
      case 'overdue':
      case 'cancelled':
      case 'terminated':
        return Colors.red.shade600;
      case 'draft':
      case 'inactive':
      case 'expired':
        return Colors.blueGrey;
      default:
        return s.primary;
    }
  }

  static CardThemeData({required int elevation, required Color color, required EdgeInsets margin, required RoundedRectangleBorder shape}) {}
}

extension on Color {
  withValues({required double alpha}) {}
}
