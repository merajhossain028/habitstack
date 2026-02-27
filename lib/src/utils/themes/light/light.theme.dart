import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    error: kErrorColor,
    surface: kBackgroundLight,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kTextPrimary,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: kBackgroundLight,
  cardColor: kCardLight,
  textTheme: GoogleFonts.interTextTheme().apply(
    bodyColor: kTextPrimary,
    displayColor: kTextPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: kTextPrimary,
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  // cardTheme: CardTheme(
  //   color: kCardLight,
  //   elevation: 2,
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.circular(12),
  //   ),
  // ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kPrimaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);

const SystemUiOverlayStyle lightUiConfig = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
);
