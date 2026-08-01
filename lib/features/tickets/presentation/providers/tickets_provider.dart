import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/tickets_repository.dart';
import '../../data/models/ticket_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final ticketsRepositoryProvider = Provider((ref) {
  return TicketsRepository(ref.watch(apiClientProvider));
});

final ticketsListTecnicoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];

  final idUsuarioApp = usuario['idUsuarioApp'] as String;
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.listarPorTecnico(idUsuarioApp);
});

final ticketsListMantenimientoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.listarMantenimiento();
});

final ticketDetailProvider = FutureProvider.autoDispose.family<TicketModel, String>((ref, idticket) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.obtenerPorId(idticket);
});

final ticketUpdateProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  final idticket = params['idticket'] as String;
  final updates = params['updates'] as Map<String, dynamic>;
  await repository.actualizarTicket(idticket, updates);
});

final ticketCreateProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>((ref, ticketData) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  await repository.crearTicket(ticketData);
});

final ticketsListAllProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.listarTodos();
});
