library material;

import 'foundation.dart';
import 'widgets.dart';
export 'foundation.dart';
export 'widgets.dart';

class Color {
  final int value;
  const Color(this.value);

  Color withOpacity(double opacity) => this;

  @override
  bool operator ==(Object other) => other is Color && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';
}

class Colors {
  static const Color transparent = Color(0x00000000);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const _GreyShade grey = _GreyShade(0xFF9E9E9E);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
}

class _GreyShade extends Color {
  const _GreyShade(super.value);
  Color get shade200 => const Color(0xFFEEEEEE);
}

class FontWeight {
  final int index;
  const FontWeight._(this.index);
  static const FontWeight normal = FontWeight._(3);
  static const FontWeight bold = FontWeight._(6);
  static const FontWeight w500 = FontWeight._(4);
  static const FontWeight w600 = FontWeight._(5);
  static const FontWeight w700 = FontWeight._(6);
  static const FontWeight w800 = FontWeight._(7);
}

class TextDecoration {
  const TextDecoration();
  static const TextDecoration none = TextDecoration();
  static const TextDecoration underline = TextDecoration();
  static const TextDecoration lineThrough = TextDecoration();
}

class TextStyle {
  const TextStyle({
    this.fontSize,
    this.fontWeight,
    this.color,
    this.decoration,
    this.letterSpacing,
    this.height,
  });
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final double? height;
}

class EdgeInsets {
  final double left, top, right, bottom;
  const EdgeInsets.all(double val)
      : left = val, top = val, right = val, bottom = val;
  const EdgeInsets.symmetric({double vertical = 0.0, double horizontal = 0.0})
      : left = horizontal, right = horizontal, top = vertical, bottom = vertical;
  const EdgeInsets.only({this.left = 0.0, this.top = 0.0, this.right = 0.0, this.bottom = 0.0});
  static const EdgeInsets zero = EdgeInsets.all(0);
}

class Radius {
  final double x, y;
  const Radius.circular(double r) : x = r, y = r;
}

class BorderRadius {
  const BorderRadius();
  static dynamic circular(double radius) => BorderRadius();
}

class BorderSide {
  final Color color;
  final double width;
  const BorderSide({this.color = const Color(0xFF000000), this.width = 1.0});
}

class Border {
  final BorderSide top, right, bottom, left;
  const Border.all({Color color = const Color(0xFF000000), double width = 1.0})
      : top = const BorderSide(),
        right = const BorderSide(),
        bottom = const BorderSide(),
        left = const BorderSide();
}

class BoxDecoration {
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  const BoxDecoration({this.color, this.borderRadius, this.border});
}

class RoundedRectangleBorder {
  final BorderRadius? borderRadius;
  final BorderSide side;
  const RoundedRectangleBorder({this.borderRadius, this.side = const BorderSide()});
}

class StadiumBorder {
  final BorderSide side;
  const StadiumBorder({this.side = const BorderSide()});
}

class OutlineInputBorder {
  final BorderRadius? borderRadius;
  final BorderSide borderSide;
  const OutlineInputBorder({this.borderRadius, this.borderSide = const BorderSide()});
}

class InputDecorationTheme {
  const InputDecorationTheme({
    dynamic filled,
    dynamic fillColor,
    dynamic contentPadding,
    dynamic border,
    dynamic enabledBorder,
    dynamic focusedBorder,
    dynamic hintStyle,
  });
}

class FilledButtonThemeData {
  final dynamic style;
  const FilledButtonThemeData({this.style});
}

class ChipThemeData {
  const ChipThemeData({
    dynamic backgroundColor,
    dynamic selectedColor,
    dynamic disabledColor,
    dynamic side,
    dynamic labelStyle,
    dynamic shape,
    dynamic padding,
  });
}

class DividerThemeData {
  const DividerThemeData({
    Color? color,
    double? thickness,
    double? space,
  });
}

class VisualDensity {
  const VisualDensity();
  static const VisualDensity adaptivePlatformDensity = VisualDensity();
}

class ElevatedButtonThemeData {
  final dynamic style;
  const ElevatedButtonThemeData({this.style});
}

class OutlinedButtonThemeData {
  final dynamic style;
  const OutlinedButtonThemeData({this.style});
}

class TextButtonThemeData {
  final dynamic style;
  const TextButtonThemeData({this.style});
}

class FloatingActionButtonThemeData {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final dynamic shape;
  const FloatingActionButtonThemeData({
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shape,
  });
}

class CardThemeData {
  final Color? color;
  final double? elevation;
  final dynamic shape;
  final dynamic margin;
  const CardThemeData({this.color, this.elevation, this.shape, this.margin});
}

class AppBarTheme {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final bool? centerTitle;
  final TextStyle? titleTextStyle;
  const AppBarTheme({
    this.backgroundColor,
    this.foregroundColor,
    this.surfaceTintColor,
    this.elevation,
    this.centerTitle,
    this.titleTextStyle,
  });
}

typedef AppBarThemeData = AppBarTheme;

class TextTheme {
  const TextTheme();
}

class ColorScheme {
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color error;
  const ColorScheme({
    this.primary = const Color(0xFF0C831F),
    this.secondary = const Color(0xFFFFC72C),
    this.surface = const Color(0xFFFFFFFF),
    this.error = const Color(0xFFF04438),
  });

  ColorScheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? outline,
    Color? outlineVariant,
  }) {
    return ColorScheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      error: error ?? this.error,
    );
  }

  factory ColorScheme.fromSeed({
    required Color seedColor,
    Brightness brightness = Brightness.light,
    Color? surface,
    Color? primary,
    Color? secondary,
    Color? error,
  }) {
    return ColorScheme(
      primary: primary ?? seedColor,
      surface: surface ?? const Color(0xFFFFFFFF),
      secondary: secondary ?? const Color(0xFFFFC72C),
      error: error ?? const Color(0xFFF04438),
    );
  }
}

enum Brightness { light, dark }

class ThemeData {
  final bool useMaterial3;
  final ColorScheme colorScheme;
  final Color primaryColor;
  final Color scaffoldBackgroundColor;
  final TextTheme textTheme;
  final dynamic appBarTheme;
  final dynamic cardTheme;
  final dynamic elevatedButtonTheme;
  final dynamic outlinedButtonTheme;
  final dynamic textButtonTheme;
  final dynamic filledButtonTheme;
  final dynamic floatingActionButtonTheme;
  final dynamic inputDecorationTheme;
  final dynamic chipTheme;
  final dynamic dividerTheme;
  final dynamic visualDensity;

  ThemeData({
    this.useMaterial3 = true,
    ColorScheme? colorScheme,
    Color? primaryColor,
    Color? scaffoldBackgroundColor,
    TextTheme? textTheme,
    this.appBarTheme,
    this.cardTheme,
    this.elevatedButtonTheme,
    this.outlinedButtonTheme,
    this.textButtonTheme,
    this.filledButtonTheme,
    this.floatingActionButtonTheme,
    this.inputDecorationTheme,
    this.chipTheme,
    this.dividerTheme,
    this.visualDensity,
  })  : colorScheme = colorScheme ?? const ColorScheme(),
        primaryColor = primaryColor ?? const Color(0xFF0C831F),
        scaffoldBackgroundColor = scaffoldBackgroundColor ?? const Color(0xFFF7F9FA),
        textTheme = textTheme ?? const TextTheme();

  static ThemeData light() => ThemeData();
}

class Theme extends Widget {
  const Theme({super.key, required this.data, required this.child});
  final ThemeData data;
  final Widget child;
  static ThemeData of(BuildContext context) => ThemeData();
}

class MaterialApp extends Widget {
  const MaterialApp({super.key, this.home, this.theme, this.routes, this.title});
  final Widget? home;
  final ThemeData? theme;
  final Map<String, dynamic>? routes;
  final String? title;
}

class Scaffold extends Widget {
  const Scaffold({super.key, this.appBar, this.body, this.bottomNavigationBar, this.floatingActionButton});
  final dynamic appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
}

class Icons {
  static const dynamic shopping_cart = 'shopping_cart';
  static const dynamic add = 'add';
  static const dynamic remove = 'remove';
  static const dynamic check_circle = 'check_circle';
  static const dynamic search = 'search';
  static const dynamic clear = 'clear';
  static const dynamic flash_on = 'flash_on';
  static const dynamic local_shipping = 'local_shipping';
  static const dynamic verified = 'verified';
}
