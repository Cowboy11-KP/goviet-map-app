import 'package:flutter/material.dart';

class AppTheme {

  //Heading
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 40 / 32,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  // Subtitle
  static const TextStyle sub1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
  );

  static const TextStyle sub2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  // Body
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 22 / 14,
  );

  // Button
  static const TextStyle button1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 16 / 14,
  );

  static const TextStyle button2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 16 / 14,
  );

  // Caption
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 14 / 10,
  );

  static ThemeData lightTheme = ThemeData(
    textTheme: const TextTheme(
      headlineLarge: h1,      
      headlineMedium: h2,    
      titleLarge: sub1,       
      titleMedium: sub2,      
      bodyLarge: body1,      
      bodyMedium: body2,     
      labelLarge: button1,   
      labelMedium: button2,   
      displayLarge: caption1, 
      displaySmall: caption2,
    )
  );
}