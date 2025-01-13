import 'package:flutter/material.dart';

class AppThemes {
  // Tema Claro com cores mais vibrantes
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF00796B), // Verde vibrante e contrastante
    hintColor: const Color(0xFF00E676), // Verde mais suave mas vibrante
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Fundo branco para clareza
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121), fontSize: 20), // Texto mais escuro para contraste
      bodyMedium: TextStyle(color: Color(0xFF212121), fontSize: 20), // Texto mais escuro para contraste
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00796B), // Verde vibrante para o AppBar
      titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 22), // Texto branco para clareza
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF00E676), // Verde mais claro e vibrante para os botões
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF212121), // Ícones em um tom escuro para contraste
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF00E676), // Cor vibrante para o slider
      inactiveTrackColor: Color(0xFFBDBDBD), // Cor mais suave para a parte inativa
      thumbColor: Color(0xFF00796B), // Cor vibrante para o thumb do slider
      overlayColor: Color(0x33004D40), // Sobreposição mais visível
    ),
  );

  // Tema Escuro com cores mais vibrantes
  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF004D40), // Verde escuro e vibrante
    hintColor: const Color(0xFF00E676), // Verde vibrante para o contraste
    scaffoldBackgroundColor: const Color(0xFF121212), // Preto suave para fundo
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20), // Branco para legibilidade
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20), // Branco para legibilidade
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF004D40), // Verde escuro e vibrante para o AppBar
      titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 22), // Título em branco
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF00E676), // Verde claro e vibrante para os botões
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFFFFFFF), // Ícones em branco para alto contraste
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF00E676), // Cor vibrante para o slider
      inactiveTrackColor: Color(0xFFBDBDBD), // Cor mais suave para a parte inativa
      thumbColor: Color(0xFF004D40), // Cor vibrante para o thumb do slider
      overlayColor: Color(0x3300796B), // Sobreposição visível
    ),
  );
}
