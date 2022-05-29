import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './constants.dart';

//flutter provides default light and dark theme

ThemeData LightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarTheme,
    iconTheme: const IconThemeData(color: kContentColorLightTheme),
    textTheme: GoogleFonts.soraTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorLightTheme, fontSizeFactor: 0.5),
    /*GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorLightTheme), */
    colorScheme: const ColorScheme.light(
        primary: kPrimaryColor, secondary: kSecondaryColor, error: kErrorColor),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: kContentColorLightTheme.withOpacity(0.7),
      unselectedItemColor: kContentColorLightTheme.withOpacity(0.32),
      selectedIconTheme: const IconThemeData(color: kContentColorLightTheme),
    ),
  );
}

ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    //visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kContentColorLightTheme,
    appBarTheme: appBarTheme,
    iconTheme: const IconThemeData(
      color: kContentColorDarkTheme,
    ),
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
      bodyColor: kContentColorDarkTheme,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
        primary: kPrimaryColor, secondary: kSecondaryColor, error: kErrorColor),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kContentColorLightTheme,
      selectedItemColor: Colors.white70,
      unselectedItemColor: kContentColorDarkTheme.withOpacity(0.32),
      selectedIconTheme: const IconThemeData(
        color: kPrimaryColor,
      ),
    ),
  );
}

const appBarTheme = AppBarTheme(
    centerTitle: false, elevation: 0, backgroundColor: kPrimaryColor);
