import 'package:flutter/material.dart';

class BadgeEstado extends StatelessWidget {
  final String estado;
  final double fontSize;

  const BadgeEstado({super.key, required this.estado, this.fontSize = 10});

  Color _getColor() {
    final edo = estado.toLowerCase();
    if (edo.contains('abierto') || edo.contains('pendiente')) return Colors.orange.shade700;
    if (edo.contains('progreso')) return Colors.blue.shade700;
    if (edo.contains('cerrado') || edo.contains('resuelto')) return Colors.green.shade700;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}