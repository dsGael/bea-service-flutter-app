import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tickets_repository.dart';
import '../../data/models/ticket_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ===========================================================================
// ── 1. REPOSITORIO CENTRAL ──
// ===========================================================================
final ticketsRepositoryProvider = Provider((ref) {
  return TicketsRepository(ref.watch(apiClientProvider));
});


// ===========================================================================
// ── 2. PROVEEDORES DE LECTURA (GET - FutureProviders) ──
// ===========================================================================

final ticketsListAllProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.listarTodos();
});

final ticketsListTecnicoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];

  final idUsuarioApp = usuario['idUsuarioApp'] as String;
  return ref.watch(ticketsRepositoryProvider).listarPorTecnico(idUsuarioApp);
});

final ticketsListMantenimientoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  return ref.watch(ticketsRepositoryProvider).listarMantenimiento();
});

final ticketsListMantenimientoTecnicoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];
  
  return ref.watch(ticketsRepositoryProvider).listarMantenimientoPorTecnico(usuario['idUsuarioApp']);
});

final ticketsListMantenimientoAbiertosProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  return ref.watch(ticketsRepositoryProvider).listarMantenimientoAbiertos();
});

final ticketsListMantenimientoAbiertosTecnicoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];
  
  return ref.watch(ticketsRepositoryProvider).listarMantenimientoAbiertosPorTecnico(usuario['idUsuarioApp']);
});

final ticketDetailProvider = FutureProvider.autoDispose.family<TicketModel, String>((ref, idticket) async {
  return ref.watch(ticketsRepositoryProvider).obtenerPorId(idticket);
});

final ticketListCorrectivoProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
  return ref.watch(ticketsRepositoryProvider).listarCorrectivosAbiertos();
});


// ===========================================================================
// ── 3. CONTROLADOR DE ACCIONES (POST, PATCH) ──
// ===========================================================================

/// Proveedor para acceder al controlador de acciones desde la UI
final ticketsControllerProvider = Provider.autoDispose((ref) {
  return TicketsController(ref.watch(ticketsRepositoryProvider));
});

/// Clase para manejar las mutaciones de forma segura sin que Riverpod las dispare al azar
class TicketsController {
  final TicketsRepository _repository;
  
  TicketsController(this._repository);

  Future<void> crearTicket(Map<String, dynamic> ticketData) => _repository.crearTicket(ticketData);
  
  Future<void> crearMantenimiento(Map<String, dynamic> ticketData) => _repository.crearMantenimiento(ticketData);
  
  Future<void> asignarTecnico(String idticket, Map<String, dynamic> data) => _repository.asignarTecnico(idticket, data);
  
  Future<void> registrarReparacion(String idticket, Map<String, dynamic> data) => _repository.registrarReparacion(idticket, data);
  
  Future<void> validarTicket(String idticket, Map<String, dynamic> data) => _repository.validarTicket(idticket, data);
  
  Future<void> marcarPendiente(String idticket) => _repository.marcarPendiente(idticket);
  
  Future<void> reanudarTicket(String idticket) => _repository.reanudarTicket(idticket);
  
  Future<void> cancelarTicket(String idticket) => _repository.cancelarTicket(idticket);
}