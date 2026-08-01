import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/tickets/presentation/tickets_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final estaLogueado = authState.valueOrNull != null;
      final vaALogin = state.matchedLocation == '/login';

      if (!estaLogueado && !vaALogin) return '/login';
      if (estaLogueado && vaALogin) return '/tickets';
      return null; // sin redirección
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/tickets', builder: (context, state) => const TicketsListScreen()),
    ],
  );
});