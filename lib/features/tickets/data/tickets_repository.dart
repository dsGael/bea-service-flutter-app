import '../../../core/api/api_client.dart';
import 'models/ticket_model.dart';

class TicketsRepository {
  final ApiClient _apiClient;
  TicketsRepository(this._apiClient);

  // ===========================================================================
  // ── 1. LISTADOS (GET) ──
  // ===========================================================================

  Future<List<TicketModel>> listarTodos({Map<String, dynamic>? query}) async {
    final response = await _apiClient.dio.get('/tickets', queryParameters: query);
    return _parseList(response);
  }

  Future<List<TicketModel>> listarPorTecnico(String idtecnico) async {
    final response = await _apiClient.dio.get('/tickets/tecnico/$idtecnico');
    return _parseList(response);
  }

  Future<List<TicketModel>> listarMantenimiento({Map<String, dynamic>? query}) async {
    final response = await _apiClient.dio.get('/tickets/mantenimiento', queryParameters: query);
    return _parseList(response);
  }

  Future<List<TicketModel>> listarMantenimientoPorTecnico(String idtecnico) async {
    final response = await _apiClient.dio.get('/tickets/mantenimiento/tecnico/$idtecnico');
    return _parseList(response);
  }

  Future<List<TicketModel>> listarMantenimientoAbiertos({Map<String, dynamic>? query}) async {
    final response = await _apiClient.dio.get('/tickets/mantenimiento/abierto', queryParameters: query);
    return _parseList(response);
  }

  Future<List<TicketModel>> listarMantenimientoAbiertosPorTecnico(String idtecnico) async {
    final response = await _apiClient.dio.get('/tickets/mantenimiento/abierto/tecnico/$idtecnico');
    return _parseList(response);
  }

  Future<List<TicketModel>> listarCorrectivosAbiertos({Map<String, dynamic>? query}) async {
    final response = await _apiClient.dio.get('/tickets/correctivos/abierto', queryParameters: query);
    return _parseList(response);
  }

  // ===========================================================================
  // ── 2. DETALLE (GET) ──
  // ===========================================================================

  Future<TicketModel> obtenerPorId(String idticket) async {
    final response = await _apiClient.dio.get('/tickets/$idticket');
    // Si tu backend devuelve { data: {...} } modifícalo aquí, si devuelve el objeto directo está bien así.
    final data = _apiClient.unwrap(response);
    return TicketModel.fromJson(data);
  }

  // ===========================================================================
  // ── 3. CREACIÓN (POST) ──
  // ===========================================================================

  Future<void> crearTicket(Map<String, dynamic> ticketData) async {
    await _apiClient.dio.post('/tickets', data: ticketData);
  }

  Future<void> crearMantenimiento(Map<String, dynamic> ticketData) async {
    await _apiClient.dio.post('/tickets/mantenimiento', data: ticketData);
  }

  // ===========================================================================
  // ── 4. TRANSICIONES DE ESTADO (PATCH) ──
  // ===========================================================================

  Future<void> asignarTecnico(String idticket, Map<String, dynamic> data) async {
    await _apiClient.dio.patch('/tickets/$idticket/asignar', data: data);
  }

  Future<void> registrarReparacion(String idticket, Map<String, dynamic> data) async {
    await _apiClient.dio.patch('/tickets/$idticket/reparacion', data: data);
  }

  Future<void> validarTicket(String idticket, Map<String, dynamic> data) async {
    await _apiClient.dio.patch('/tickets/$idticket/validar', data: data);
  }

  Future<void> marcarPendiente(String idticket) async {
    await _apiClient.dio.patch('/tickets/$idticket/pendiente');
  }

  Future<void> reanudarTicket(String idticket) async {
    await _apiClient.dio.patch('/tickets/$idticket/reanudar');
  }

  Future<void> cancelarTicket(String idticket) async {
    await _apiClient.dio.patch('/tickets/$idticket/cancelar');
  }

  // ===========================================================================
  // ── METODOS PRIVADOS DE APOYO ──
  // ===========================================================================

  /// Parsea la respuesta del servidor a una lista de TicketModel, 
  /// soportando paginación { data: [...], meta: {...} } o listas directas [...]
  List<TicketModel> _parseList(dynamic response) {
    final rawData = _apiClient.unwrap(response);
    
    List dataList;
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      // Si el backend devuelve paginación envuelta en 'data'
      dataList = rawData['data'] as List;
    } else {
      // Si el backend devuelve el arreglo directo
      dataList = rawData as List;
    }

    return dataList.map((json) => TicketModel.fromJson(json)).toList();
  }
}