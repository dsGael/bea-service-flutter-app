// lib/features/checador/presentation/checador_screen.dart
import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class ChecadorScreen extends StatelessWidget {
  const ChecadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checador')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Pantalla de checador — pendiente')),
    );
  }
}