import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The field-journal palette: parchment pages, obsidian forest nights and
/// aged brass instruments.
abstract final class OdysseyColors {
  static const parchment = Color(0xFFF8F5EE);
  static const parchmentDeep = Color(0xFFEFE8D9);
  static const vellum = Color(0xFFE5DBC7);
  static const rule = Color(0xFFDCD2BF);

  static const forest = Color(0xFF141D15);
  static const obsidian = Color(0xFF181613);
  static const forestMist = Color(0xFF223024);

  static const brass = Color(0xFF9C7A4A);
  static const brassLight = Color(0xFFC9AA78);

  static const ink = Color(0xFF26221C);
  static const inkSoft = Color(0xFF6E6456);
  static const moss = Color(0xFF4A6248);
  static const ember = Color(0xFFA4553A);
}

/// Literary typography: Cormorant Garamond for display and prose, Italiana
/// for subtitles and IBM Plex Mono for telemetry.
abstract final class OdysseyType {
  static TextStyle display(
    double size, {
    Color color = OdysseyColors.ink,
    FontWeight weight = FontWeight.w500,
    bool italic = false,
    double? height,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        color: color,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle prose(
    double size, {
    Color color = OdysseyColors.ink,
    bool italic = false,
  }) =>
      display(size, color: color, italic: italic, height: 1.55);

  static TextStyle subtitle(
    double size, {
    Color color = OdysseyColors.inkSoft,
    double letterSpacing = 1.2,
  }) =>
      GoogleFonts.italiana(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono(
    double size, {
    Color color = OdysseyColors.inkSoft,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 1.1,
    double? height,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Starts every face downloading so the splash wordmark is ready in time.
  static Future<void> warmUp() {
    display(10);
    display(10, italic: true);
    display(10, weight: FontWeight.w600);
    subtitle(10);
    mono(10);
    mono(10, weight: FontWeight.w500);
    return GoogleFonts.pendingFonts();
  }
}

ThemeData buildOdysseyTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: OdysseyColors.brass,
    brightness: Brightness.light,
  ).copyWith(
    primary: OdysseyColors.brass,
    onPrimary: OdysseyColors.parchment,
    secondary: OdysseyColors.moss,
    onSecondary: OdysseyColors.parchment,
    surface: OdysseyColors.parchment,
    onSurface: OdysseyColors.ink,
    outline: OdysseyColors.rule,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: OdysseyColors.parchment,
    splashFactory: InkRipple.splashFactory,
    textTheme: TextTheme(
      displayLarge: OdysseyType.display(44),
      headlineMedium: OdysseyType.display(30),
      titleLarge: OdysseyType.display(22, weight: FontWeight.w600),
      titleMedium: OdysseyType.display(18, weight: FontWeight.w600),
      bodyLarge: OdysseyType.prose(18),
      bodyMedium: OdysseyType.prose(16),
      labelLarge: OdysseyType.mono(12, color: OdysseyColors.ink),
      labelSmall: OdysseyType.mono(10),
    ),
    dividerTheme: const DividerThemeData(
      color: OdysseyColors.rule,
      thickness: 0.8,
      space: 0.8,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: OdysseyColors.forest,
      contentTextStyle: OdysseyType.mono(12, color: OdysseyColors.parchment),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: OdysseyColors.parchment,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: OdysseyColors.rule,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: OdysseyColors.brass,
      selectionHandleColor: OdysseyColors.brass,
    ),
  );
}
