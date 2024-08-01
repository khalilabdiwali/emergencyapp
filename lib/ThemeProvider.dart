import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xff300030), // Customized primary color (Light Mode)
          secondary:
              Color(0xffe6e7e9), // Customized secondary color (Light Mode)
          background: Color(0xFFFFFFFF), // White for backgrounds
          surface: Colors.white, // Light gray for card surfaces and dialogs
          onPrimary:
              Color(0xFFFFFFFF), // White text/icons on top of primary color
          onSecondary:
              Color(0xFF000000), // Dark text/icons on top of secondary color
          onError: Color(0xFF000000), // Dark text/icons on top of error color
          onBackground: Color(0xFF212121), // Dark gray text/icons on background
          onSurface: Color(0xFF212121), // Dark gray text/icons on surfaces
          error: Color(0xFFD32F2F), // Bright red for errors
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xffe6e7e9), // Matches the surface color
          iconTheme: IconThemeData(
              color: Color(0xFF212121)), // Dark icons for light theme
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: Color.fromARGB(255, 4, 10, 15)), // Primary color
        ),
      );

  ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1565C0), // Customized primary color (Dark Mode)
          secondary:
              Color(0xff192028), // Customized secondary color (Dark Mode)
          background: Color(0xff131313), // Very dark gray for backgrounds
          surface: Color(0xFF1E1E1E), // Dark gray for card surfaces and dialogs
          onPrimary:
              Color(0xFF000000), // Dark text/icons on top of primary color
          onSecondary:
              Color(0xFF000000), // Dark text/icons on top of secondary color
          onError: Color(0xFFFFFFFF), // White text/icons on top of error color
          onBackground:
              Color(0xFFE0E0E0), // Light gray text/icons on background
          onSurface: Color(0xFFE0E0E0), // Light gray text/icons on surfaces
          error: Color(0xFFB71C1C), // Dark red for errors
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E), // Matches the surface color
          iconTheme: IconThemeData(
              color: Color(0xFFE0E0E0)), // Light icons for dark theme
          titleTextStyle: TextStyle(color: Color(0xFFE0E0E0), fontSize: 20.0),
        ),
        textButtonTheme: TextButtonThemeData(
          style:
              TextButton.styleFrom(primary: Color(0xFF1565C0)), // Primary color
        ),
      );

  // Getter for icon color based on the theme mode
  Color get iconColor =>
      _themeMode == ThemeMode.dark ? Colors.white : Color(0xFF212121);

  get isDarkMode => null;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners of theme change
  }

  static of(BuildContext context) {}
}
