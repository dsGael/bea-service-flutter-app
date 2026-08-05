// lib/features/auth/presentation/login_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identificadorCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        data: (usuario) {
          if (usuario != null) context.go('/ticketsMantenimiento');
        },
       error: (err, st) {
          String mensajeError = 'Error desconocido al iniciar sesión';

          // Si usas Dio, puedes leer exactamente lo que mandó NestJS
          if (err is DioException && err.response != null) {
             // Extrae el "Contraseña incorrecta" del JSON de NestJS
             final data = err.response!.data;
             mensajeError = data['message'] ?? mensajeError;
          } else {
             // Fallback genérico
             mensajeError = err.toString().replaceAll('Exception: ', '');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensajeError),
              backgroundColor: const Color.fromARGB(255, 250, 81, 69),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _identificadorCtrl,
              decoration: const InputDecoration(labelText: 'Usuario o correo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).login(
                            _identificadorCtrl.text,
                            _passwordCtrl.text,
                          );
                    },
                    child: const Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}