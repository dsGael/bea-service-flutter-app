import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Habilita Material Design 3 (el estándar más moderno)
      useMaterial3: true,
      
      // Aquí defines tu paleta de colores global
      colorScheme: const ColorScheme.light(
        // El color principal de tu app (AppBar, botones principales, loaders)
        primary: Color(0xFF2396B9),
        // Color para el texto o íconos que van encima del color primario
        onPrimary: Colors.white,
        
        // Un color secundario para acentos (puedes cambiarlo)
        secondary: Color(0xFFF39C12),
        onSecondary: Colors.white,
        
        // El color de fondo general de tus pantallas (Scaffolds)
        surface: Color(0xFFF5F7FA), // Un gris muy claro
        // El color para elementos sobre el fondo, como tarjetas o diálogos
        onSurface: Colors.black87,
        
        // Color para errores o validaciones (ej. bordes rojos de formularios)
        error: Colors.redAccent,
      ),

      // También puedes configurar el comportamiento global de componentes específicos
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2396B9),
        foregroundColor: Colors.white, // Pinta de blanco los títulos y botones del AppBar
        centerTitle: false,
        elevation: 0,
      ),
      
      // Hace que todos los FloatingActionButtons usen tu color primario automáticamente
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2396B9),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2396B9),
        onPrimary: Colors.white,
        secondary: Color(0xFFF39C12),
        onSecondary: Colors.white,
        surface: Color(0xFF121212),
        onSurface: Colors.white70,
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2396B9),
        foregroundColor: Colors.white,
      ),
    );
  }
}