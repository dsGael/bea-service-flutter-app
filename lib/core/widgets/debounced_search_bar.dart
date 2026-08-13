import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DebouncedSearchBar extends StatefulWidget {
  // Función que le avisará a tu pantalla cuando el usuario deje de escribir
  final Function(String) onSearchChanged;
  
  // Opciones visuales personalizables
  final String placeholder;
  final Duration debounceDuration;

  const DebouncedSearchBar({
    super.key,
    required this.onSearchChanged,
    this.placeholder = 'Buscar...',
    this.debounceDuration = const Duration(milliseconds: 500), // Medio segundo por defecto
  });

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  Timer? _debouncer;

  void _manejarCambioDeTexto(String query) {
    // Si el usuario sigue tecleando, cancelamos el temporizador anterior
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    
    // Iniciamos el nuevo temporizador
    _debouncer = Timer(widget.debounceDuration, () {
      // Cuando pasa el tiempo, disparamos la función hacia la pantalla padre
      widget.onSearchChanged(query);
    });
  }

  @override
  void dispose() {
    // Es vital que el widget se limpie a sí mismo cuando cambias de pantalla
    _debouncer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: widget.placeholder,
      backgroundColor: Colors.white,
      onChanged: _manejarCambioDeTexto,
    );
  }
}