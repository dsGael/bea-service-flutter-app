import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authStateProvider).valueOrNull;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Encabezado con datos del usuario logueado
            UserAccountsDrawerHeader(
              accountName: Text(usuario?['nombre'] ?? 'Usuario'),
              accountEmail: Text(usuario?['useremail'] ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (usuario?['nombre'] as String? ?? '?').characters.first.toUpperCase(),
                ),
              ),
            ),

            // Secundarios — poca frecuencia de uso
            ListTile(
              leading: const Icon(Icons.build_circle_outlined),
              title: const Text('Crear mantenimiento'),
              onTap: () {
                Navigator.pop(context); // cierra el drawer primero
                context.push('/mantenimiento/nuevo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de folios de mantenimiento'),
              onTap: () {
                Navigator.pop(context);
                context.push('/tickets/historial/mantenimientos');
              },
            ),

            const Spacer(), // empuja lo siguiente hasta abajo

            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                context.push('/configuracion');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).logout();
                // no hace falta navegar manualmente — el redirect del router
                // ya detecta que no hay sesión y manda a /login solo
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}