// import 'package:flutter/material.dart';
//
// ThemeData appTheme = ThemeData(
//   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//   useMaterial3: true,
// ).copyWith(
//
// );


import 'package:flutter/material.dart';

// Define your primary and accent colors for both light and dark themes
const Color primaryColor = Colors.deepPurple;
const Color accentColor = Colors.deepOrange;

// Define your dark theme colors
const ColorScheme darkColorScheme = ColorScheme.dark(
  primary: primaryColor,
  secondary: accentColor,
);

ThemeData appTheme = ThemeData(
  colorScheme: darkColorScheme,
  // You can also customize other aspects of the theme here
  // For example, the typography, icon themes, etc.
  // For this example, let's use the default typography
  typography: Typography.material2018(),
  // Set this to true to enable Material 3.0 design system
  useMaterial3: true,
  // Define the brightness explicitly as dark
  brightness: Brightness.dark,
  // Set the background color for the app
  scaffoldBackgroundColor: Colors.grey[900], // You can use any color you prefer
).copyWith(
  // Add any additional theme customizations here, if needed
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[800], // Set the background color for the app bar in dark mode
    // You can also customize other app bar properties here, such as iconTheme, textTheme, etc.
  ),
);

