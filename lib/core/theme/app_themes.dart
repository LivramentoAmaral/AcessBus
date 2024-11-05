import 'package:flutter/material.dart';

class AppThemes {
  // Tema Claro
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF097341), // Verde escuro
    hintColor: const Color(0xFF36BF7F), // Verde claro
    scaffoldBackgroundColor: const Color(0xFFF2F2F2), // Cinza claro
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0D0D0D)), // Preto
      bodyMedium: TextStyle(color: Color(0xFF0D0D0D)), // Preto
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF097341), // Verde escuro
      titleTextStyle: TextStyle(color: Color(0xFFF2F2F2)), // Cinza claro
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF36BF7F), // Verde claro
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // Tema Escuro
  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF042616), // Verde muito escuro
    hintColor: const Color(0xFF097341), // Verde escuro
    scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Preto
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF2F2F2)), // Cinza claro
      bodyMedium: TextStyle(color: Color(0xFFF2F2F2)), // Cinza claro
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF042616), // Verde muito escuro
      titleTextStyle: TextStyle(color: Color(0xFFF2F2F2)), // Cinza claro
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF097341), // Verde escuro
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
