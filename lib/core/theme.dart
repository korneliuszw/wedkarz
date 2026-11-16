import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFE9ECE6);
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF101412);
  static const muted = Color(0xFF3A4640);
  static const green = Color(0xFF22302A);
  static const soft = Color(0xFFDDE6DF);
  static const line = Color(0xFFC2CBC2);
  static const disabled = Color(0xFF8A938D);
  static const amber = ink;
  static const amberSurface = Color(0xFFFFD21F);
  static const orange = Color(0xFFFF5A1F);
  static const error = Color(0xFFC8202B);
  static const water = Color(0xFF1D5FA8);
}

const displayFont = 'SofiaSansCondensed';

class AnglerAssets extends InheritedWidget {
  const AnglerAssets({super.key, required this.package, required super.child});

  final String? package;

  static String? packageOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AnglerAssets>()?.package;

  static String fontOf(BuildContext context, String family) {
    final package = packageOf(context);
    return package == null ? family : 'packages/$package/$family';
  }

  @override
  bool updateShouldNotify(AnglerAssets oldWidget) =>
      package != oldWidget.package;
}

ThemeData createTheme({String? package}) {
  String font(String family) =>
      package == null ? family : 'packages/$package/$family';
  final bodyFont = font('SofiaSans');
  final headingFont = font(displayFont);
  final base = ThemeData(useMaterial3: true, fontFamily: bodyFont);
  const pill = StadiumBorder(side: BorderSide(color: AppColors.ink, width: 3));
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: AppColors.ink, width: 2.5),
  );
  return base.copyWith(
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green).copyWith(
      primary: AppColors.green,
      onPrimary: AppColors.paper,
      tertiary: AppColors.orange,
      onTertiary: AppColors.ink,
      surface: AppColors.background,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      error: AppColors.error,
      onError: AppColors.paper,
    ),
    textTheme: base.textTheme
        .copyWith(
          headlineLarge: TextStyle(
            fontFamily: headingFont,
            fontSize: 44,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            fontFamily: headingFont,
            fontSize: 40,
            height: 1.02,
            fontWeight: FontWeight.w800,
          ),
          headlineSmall: TextStyle(
            fontFamily: headingFont,
            fontSize: 36,
            height: 1.04,
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            fontFamily: headingFont,
            fontSize: 28,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            fontFamily: bodyFont,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          bodyLarge: TextStyle(
            fontFamily: bodyFont,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(
            fontFamily: bodyFont,
            fontSize: 18,
            height: 1.24,
            fontWeight: FontWeight.w700,
          ),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
        .copyWith(
          bodySmall: TextStyle(
            fontFamily: bodyFont,
            fontSize: 17,
            height: 1.24,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: AppColors.paper,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
      titleSpacing: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: headingFont,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.paper,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(66),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.ink,
        disabledBackgroundColor: const Color(0xFFD4DAD1),
        disabledForegroundColor: AppColors.muted,
        side: const BorderSide(color: AppColors.ink, width: 3),
        textStyle: TextStyle(
          fontFamily: headingFont,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
        shape: pill,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 2.5),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        shape: pill,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.green, width: 3.5),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 2.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      space: 20,
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.paper,
      indicatorColor: AppColors.green,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: bodyFont,
          fontSize: 17,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.disabled)
              ? AppColors.disabled
              : AppColors.ink,
        ),
      ),
    ),
  );
}
