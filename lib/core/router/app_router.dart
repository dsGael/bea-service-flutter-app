import 'package:bea_service_app/features/tickets/data/models/ticket_model.dart';
import 'package:bea_service_app/features/tickets/presentation/screens/historial_mantenimientos_screen.dart';
import 'package:bea_service_app/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:bea_service_app/features/tickets/presentation/screens/ticketsCorrectivos_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/tickets/presentation/screens/ticketsMantenimiento_list_screen.dart';
import '../../features/checador/presentation/checador_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final estaLogueado = authState.valueOrNull != null;
      final vaALogin = state.matchedLocation == '/login';

      if (!estaLogueado && !vaALogin) return '/login';
      if (estaLogueado && vaALogin) return '/ticketsMantenimiento';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/detalle-ticket', builder: (context, state) {
          final ticketSeleccionado = state.extra as TicketModel;
          return TicketDetalleScreen(ticket: ticketSeleccionado);
        },
      ),
      GoRoute(
      path: '/tickets/historial/mantenimientos',
      builder: (context, state) => const HistorialMantenimientosScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/ticketsMantenimiento', builder: (context, state) => const TicketsMantenimientoListScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/ticketsCorrectivos', builder: (context, state) => const TicketsCorrectivosListScreen()),
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