import 'dart:io';

import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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

// ===========================================================================
// ── 2. PROVEEDORES DE LECTURA (Paginados y Filtrados) ──
// ===========================================================================

typedef TicketFilterArgs = ({bool? isMantenimiento, bool? isAbierto, String? idtecnico, String? buscar});

// 1. Definimos el Estado que guardará las páginas
class TicketsState {
  final List<TicketModel> tickets;
  final bool cargandoInicial;
  final bool cargandoMas;
  final bool alcanzoElFinal;
  final int paginaActual;

  TicketsState({
    this.tickets = const [],
    this.cargandoInicial = true,
    this.cargandoMas = false,
    this.alcanzoElFinal = false,
    this.paginaActual = 1,
  });

  TicketsState copyWith({
    List<TicketModel>? tickets,
    bool? cargandoInicial,
    bool? cargandoMas,
    bool? alcanzoElFinal,
    int? paginaActual,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      cargandoInicial: cargandoInicial ?? this.cargandoInicial,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      alcanzoElFinal: alcanzoElFinal ?? this.alcanzoElFinal,
      paginaActual: paginaActual ?? this.paginaActual,
    );
  }
}

// 2. Creamos el Notifier que maneja la lógica
class TicketsPaginadosNotifier extends StateNotifier<TicketsState> {
  final TicketsRepository _repository;
  final TicketFilterArgs _args; // Guardamos los filtros
  final int _limite = 15; // Cuántos tickets traer por página

  TicketsPaginadosNotifier(this._repository, this._args) : super(TicketsState()) {
    cargarPrimeraPagina();
  }

  // Helper para armar el query combinando los filtros y la página
  Map<String, dynamic> _armarQuery(int page) {
    final queryMap = <String, dynamic>{
      'page': page,
      'limit': _limite,
    };
    
    if (_args.isMantenimiento != null) queryMap['isMantenimiento'] = _args.isMantenimiento;
    if (_args.isAbierto != null) queryMap['isAbierto'] = _args.isAbierto;
    if (_args.idtecnico != null) queryMap['idtecnico'] = _args.idtecnico;
    if (_args.buscar != null && _args.buscar!.isNotEmpty) queryMap['buscar'] = _args.buscar;
    return queryMap;
  }

  Future<void> cargarPrimeraPagina() async {
    state = state.copyWith(cargandoInicial: true, paginaActual: 1, alcanzoElFinal: false);
    
    try {
      final query = _armarQuery(1);
      final nuevosTickets = await _repository.listarTickets(query: query);
      
      state = state.copyWith(
        tickets: nuevosTickets,
        cargandoInicial: false,
        alcanzoElFinal: nuevosTickets.isEmpty || nuevosTickets.length < _limite,
      );
    } catch (e) {
      state = state.copyWith(cargandoInicial: false);
      print('Error al cargar tickets (Pág 1): $e');
    }
  }

  Future<void> cargarMas() async {
    if (state.cargandoMas || state.alcanzoElFinal) return;

    state = state.copyWith(cargandoMas: true);

    try {
      final siguientePagina = state.paginaActual + 1;
      final query = _armarQuery(siguientePagina);
      
      final nuevosTickets = await _repository.listarTickets(query: query);

      state = state.copyWith(
        tickets: [...state.tickets, ...nuevosTickets], // Juntamos los viejos con los nuevos
        paginaActual: siguientePagina,
        cargandoMas: false,
        alcanzoElFinal: nuevosTickets.isEmpty || nuevosTickets.length < _limite,
      );
    } catch (e) {
      state = state.copyWith(cargandoMas: false);
      print('Error al cargar más tickets: $e');
    }
  }
}

// 3. El Provider (Usa .family para seguir aceptando tus filtros como antes)
final ticketsPaginadosProvider = StateNotifierProvider.autoDispose.family<TicketsPaginadosNotifier, TicketsState, TicketFilterArgs>((ref, args) {
  return TicketsPaginadosNotifier(ref.watch(ticketsRepositoryProvider), args);
});

// El provider de detalle se queda exactamente igual
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
  
Future<void> registrarReparacion({
    required String idTicket,
    required String diagnostico,
    required String reparacion,
    required String fechaHora,
    String? comentarios,
    List<File>? evidencias,
  }) async {
    
    // 1. Genera la lógica de negocio (el ID único)
    final String idDetalleGenerado = const Uuid().v4();

    // 2. Le manda los datos crudos al repositorio
    await _repository.registrarReparacion(
      idTicket: idTicket,
      idDetalle: idDetalleGenerado,
      diagnostico: diagnostico,
      reparacion: reparacion,
      comentarios: comentarios ?? '', 
      fechaHora: fechaHora,
      evidencias: evidencias,
    );
  }

  




  Future<void> validarTicket(String idticket, Map<String, dynamic> data) => 
      _repository.validarTicket(idticket, data);
  
  Future<void> marcarPendiente(String idticket) => 
      _repository.marcarPendiente(idticket);
  
  Future<void> reanudarTicket(String idticket) => 
      _repository.reanudarTicket(idticket);
  
  Future<void> cancelarTicket(String idticket) => 
      _repository.cancelarTicket(idticket);
}