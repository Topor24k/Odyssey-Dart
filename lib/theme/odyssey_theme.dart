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

/// The in-app palette: a parchment canvas, warm white cards, obsidian
/// forest for emphasis, aged brass for accents and a soft sage highlight.
abstract final class AppColors {
  static const canvas = Color(0xFFF5F1E8);
  static const card = Color(0xFFFFFDF8);
  static const tile = Color(0xFFEFE9DD);
  static const line = Color(0xFFE4DBCB);
  static const ink = Color(0xFF141D15);
  static const body = Color(0xFF3A3D35);
  static const muted = Color(0xFF8A8374);
  static const sage = Color(0xFFDFE6D8);
  static const sageInk = Color(0xFF52705A);
  static const brass = Color(0xFF9C7A4A);
  static const brassLight = Color(0xFFC9AA78);
  static const alert = Color(0xFFB5683F);
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
  }) => GoogleFonts.cormorantGaramond(
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
  }) => display(size, color: color, italic: italic, height: 1.55);

  static TextStyle subtitle(
    double size, {
    Color color = OdysseyColors.inkSoft,
    double letterSpacing = 1.2,
  }) => GoogleFonts.italiana(
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
  }) => GoogleFonts.ibmPlexMono(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// Clean sans-serif for the minimalist sign-in and sign-up screens.
  static TextStyle sans(
    double size, {
    Color color = OdysseyColors.ink,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
    double? height,
  }) => GoogleFonts.inter(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// Starts every face downloading so text is ready when it first shows.
  static Future<void> warmUp() {
    display(10);
    display(10, italic: true);
    display(10, weight: FontWeight.w600);
    subtitle(10);
    mono(10);
    mono(10, weight: FontWeight.w500);
    sans(10);
    sans(10, weight: FontWeight.w500);
    sans(10, weight: FontWeight.w600);
    sans(10, weight: FontWeight.w700);
    return GoogleFonts.pendingFonts();
  }
}

ThemeData buildOdysseyTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.ink,
        onPrimary: Colors.white,
        secondary: AppColors.sageInk,
        onSecondary: Colors.white,
        surface: AppColors.canvas,
        onSurface: AppColors.ink,
        outline: AppColors.line,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    splashFactory: InkRipple.splashFactory,
    textTheme: TextTheme(
      headlineMedium: OdysseyType.sans(26, color: AppColors.ink),
      titleLarge: OdysseyType.sans(20, color: AppColors.ink),
      titleMedium: OdysseyType.sans(16, color: AppColors.ink),
      bodyLarge: OdysseyType.sans(16, color: AppColors.body),
      bodyMedium: OdysseyType.sans(14, color: AppColors.body),
      labelLarge: OdysseyType.sans(14, color: AppColors.ink),
      labelSmall: OdysseyType.sans(11, color: AppColors.muted),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: OdysseyType.sans(14, color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.canvas,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.line,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.ink,
      selectionHandleColor: AppColors.ink,
    ),
  );
}
