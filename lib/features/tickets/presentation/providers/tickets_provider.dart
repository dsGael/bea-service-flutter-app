import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tickets_repository.dart';
import '../../data/models/ticket_model.dart';

// ===========================================================================
// ── 1. REPOSITORIO CENTRAL ──
// ===========================================================================
final ticketsRepositoryProvider = Provider((ref) {
  return TicketsRepository(ref.watch(apiClientProvider));
});

// ===========================================================================
// ── 2. PROVEEDORES DE LECTURA (GET - FutureProviders Optimizados) ──
// ===========================================================================

/// PROVEEDOR DINÁMICO ÚNICO: Reemplaza a todos los listados anteriores.
/// Recibe un Map con los filtros que necesites aplicar.

typedef TicketFilterArgs = ({bool? isMantenimiento, bool? isAbierto, String? idtecnico});
// 2. Actualizamos el provider
final ticketsFiltroProvider = FutureProvider.autoDispose.family<List<TicketModel>, TicketFilterArgs>((ref, args) async {
  
  // Convertimos el Record al mapa que necesita el backend
  final queryMap = <String, dynamic>{};
  
  if (args.isMantenimiento != null) queryMap['isMantenimiento'] = args.isMantenimiento;
  if (args.isAbierto != null) queryMap['isAbierto'] = args.isAbierto;
  if (args.idtecnico != null) queryMap['idtecnico'] = args.idtecnico;

  return ref.watch(ticketsRepositoryProvider).listarTickets(query: queryMap);
});


 
final ticketDetailProvider = FutureProvider.autoDispose.family<TicketModel, String>((ref, idticket) async {
  return ref.watch(ticketsRepositoryProvider).obtenerPorId(idticket);
});

// ===========================================================================
// ── 3. CONTROLADOR DE ACCIONES (POST, PATCH) ──
// ===========================================================================

final ticketsControllerProvider = Provider.autoDispose((ref) {
  return TicketsController(ref.watch(ticketsRepositoryProvider));
});

class TicketsController {
  final TicketsRepository _repository;
  
  TicketsController(this._repository);

  Future<void> crearTicket(Map<String, dynamic> ticketData, {List<String>? evidenciasFalla}) => 
      _repository.crearTicket(ticketData, evidenciasFalla: evidenciasFalla);
  
  Future<void> crearMantenimiento(Map<String, dynamic> ticketData, {List<String>? evidenciasFalla}) => 
      _repository.crearMantenimiento(ticketData, evidenciasFalla: evidenciasFalla);
      
  Future<void> editarTicket(String idticket, Map<String, dynamic> ticketData, {List<String>? evidenciasFalla}) => 
      _repository.editarTicket(idticket, ticketData, evidenciasFalla: evidenciasFalla);
  
  Future<void> asignarTecnico(String idticket, Map<String, dynamic> data) => 
      _repository.asignarTecnico(idticket, data);
  
  Future<void> registrarReparacion(String idticket, Map<String, dynamic> data, {List<String>? evidenciasReparacion}) => 
      _repository.registrarReparacion(idticket, data, evidenciasReparacion: evidenciasReparacion);
  
  Future<void> validarTicket(String idticket, Map<String, dynamic> data) => 
      _repository.validarTicket(idticket, data);
  
  Future<void> marcarPendiente(String idticket) => 
      _repository.marcarPendiente(idticket);
  
  Future<void> reanudarTicket(String idticket) => 
      _repository.reanudarTicket(idticket);
  
  Future<void> cancelarTicket(String idticket) => 
      _repository.cancelarTicket(idticket);
}