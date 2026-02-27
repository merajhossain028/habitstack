import 'package:flutter/material.dart';

/// BuildContext extension for theme, navigation, and MediaQuery helpers
extension BuildContextExtension on BuildContext {
  // MediaQuery (NO width/height here - they're in SizeExtension)
  MediaQueryData get mq => MediaQuery.of(this);
  
  // Padding & Insets (ONLY HERE)
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  
  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  
  // Theme brightness
  bool get isLightTheme => theme.brightness == Brightness.light;
  bool get isDarkTheme => theme.brightness == Brightness.dark;
  
  // Primary colors shortcuts
  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;
  Color get backgroundColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;
  
  // Navigation helpers
  NavigatorState get navigator => Navigator.of(this);
  
  void pop<T>([T? result]) => navigator.pop(result);
  
  Future<T?> push<T>(Widget page) {
    return navigator.push(MaterialPageRoute(builder: (_) => page));
  }
  
  Future<T?> pushReplacement<T>(Widget page) {
    return navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));
  }
  
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }
  
  void popUntil(bool Function(Route<dynamic>) predicate) {
    navigator.popUntil(predicate);
  }
}