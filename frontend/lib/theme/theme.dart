import 'package:flutter/material.dart';

// Define your custom colors, fonts, and styles here
class AppTheme {
  // Define custom colors
  static const Color primaryColor = Color(0xFF003366); // Dark blue
  static const Color secondaryColor = Color(0xFF0066CC); // Bright blue
  static const Color accentColor = Color(0xFFFFA500); // Orange
  static const Color backgroundColor = Colors.white; // Background color for scaffold
  static const Color textColor = Colors.black; // Default text color
  static const Color greyTextColor = Colors.grey; // Grey text color

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor, // Primary color for the app
    scaffoldBackgroundColor: backgroundColor, // Background color for scaffold
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor, // AppBar background color
      titleTextStyle: const TextStyle(
        color: Colors.white, // AppBar title color
        fontSize: 20, // AppBar title font size
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white), // AppBar icon color
      elevation: 4, // AppBar shadow
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: textColor), // Default body text
      bodyMedium: TextStyle(fontSize: 14.0, color: textColor), // Secondary body text
      titleLarge: TextStyle(fontSize: 20.0, color: primaryColor, fontWeight: FontWeight.bold), // Title styles
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFFFFA500), // Orange background for buttons
      textTheme: ButtonTextTheme.primary, // Button text color
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor, // Elevated button background color
        foregroundColor: Colors.white, // Elevated button text color
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Button text style
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(), // Style for text fields
      labelStyle: TextStyle(color: Colors.grey), // Label text color
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor, // FAB background color
      foregroundColor: Colors.white, // FAB icon color
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
      titleLarge: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.grey,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.black,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.black,
    ),
  );
}
