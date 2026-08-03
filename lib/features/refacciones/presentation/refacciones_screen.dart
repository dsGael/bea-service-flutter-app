// lib/features/refacciones/presentation/refacciones_screen.dart
import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class RefaccionesScreen extends StatelessWidget {
  const RefaccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refacciones')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Pantalla de refacciones — pendiente')),
    );
  }
}