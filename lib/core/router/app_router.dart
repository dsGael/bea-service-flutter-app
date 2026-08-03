import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/tickets/presentation/tickets_list_screen.dart';
import '../../features/checador/presentation/checador_screen.dart';
import '../../features/refacciones/presentation/refacciones_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final estaLogueado = authState.valueOrNull != null;
      final vaALogin = state.matchedLocation == '/login';

      if (!estaLogueado && !vaALogin) return '/login';
      if (estaLogueado && vaALogin) return '/tickets';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/tickets', builder: (context, state) => const TicketsListScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/refacciones', builder: (context, state) => const RefaccionesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/checador', builder: (context, state) => const ChecadorScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});