import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import 'models/ticket_model.dart';

class TicketsRepository {
  final ApiClient _apiClient;
  TicketsRepository(this._apiClient);

  // ===========================================================================
  // ── 1. LISTADO ÚNICO DINÁMICO (GET) ──
  // ===========================================================================
  Future<List<TicketModel>> listarTickets({Map<String, dynamic>? query}) async {
    final response = await _apiClient.dio.get('/tickets', queryParameters: query);
    return _parseList(response);
  }

  // ===========================================================================
  // ── 2. DETALLE (GET) ──
  // ===========================================================================
  Future<TicketModel> obtenerPorId(String idticket) async {
    final response = await _apiClient.dio.get('/tickets/$idticket');
    final data = _apiClient.unwrap(response);
    return TicketModel.fromJson(data);
  }

  // ===========================================================================
  // ── 3. CREACIÓN Y EDICIÓN (POST / PATCH MULTIPART) ──
  // ===========================================================================
  
  Future<void> crearTicket(Map<String, dynamic> ticketData, {List<String>? evidenciasFalla}) async {
    final formData = FormData.fromMap(ticketData);
    
    if (evidenciasFalla != null) {
      for (String ruta in evidenciasFalla) {
        formData.files.add(MapEntry(
          'evidenciasFalla', 
          await MultipartFile.fromFile(ruta)
        ));
      }
    }
    await _apiClient.dio.post('/tickets', data: formData);
  }

  Future<void> crearMantenimiento(Map<String, dynamic> ticketData, {List<String>? evidenciasFalla}) async {
    final formData = FormData.fromMap(ticketData);
    
    if (evidenciasFalla != null) {
      for (String ruta in evidenciasFalla) {
        formData.files.add(MapEntry(
          'evidenciasFalla', 
          await MultipartFile.fromFile(ruta)
        ));
      }
    }
    await _apiClient.dio.post('/tickets/mantenimiento', data: formData);
  }

  Future<void> editarTicket(String idticket, Map<String, dynamic> ticketData, {List<String>? evidenciasFalla}) async {
    final formData = FormData.fromMap(ticketData);
    
    if (evidenciasFalla != null) {
      for (String ruta in evidenciasFalla) {
        formData.files.add(MapEntry(
          'evidenciasFalla', 
          await MultipartFile.fromFile(ruta)
        ));
      }
    }
    await _apiClient.dio.patch('/tickets/$idticket', data: formData);
  }

  // ===========================================================================
  // ── 4. TRANSICIONES DE ESTADO (PATCH) ──
  // ===========================================================================
  
  Future<void> asignarTecnico(String idticket, Map<String, dynamic> data) async {
    await _apiClient.dio.patch('/tickets/$idticket/asignar', data: data);
  }

  Future<void> registrarReparacion(String idticket, Map<String, dynamic> data, {List<String>? evidenciasReparacion}) async {
    final formData = FormData.fromMap(data);
    
    if (evidenciasReparacion != null) {
      for (String ruta in evidenciasReparacion) {
        formData.files.add(MapEntry(
          'evidenciasReparacion', // Ojo: Este endpoint en NestJS se llama distinto
          await MultipartFile.fromFile(ruta)
        ));
      }
    }
    await _apiClient.dio.patch('/tickets/$idticket/reparacion', data: formData);
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
List<TicketModel> _parseList(dynamic response) {
    final rawData = _apiClient.unwrap(response);
    
    List dataList;
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      dataList = rawData['data'] as List;
    } else {
      dataList = rawData as List;
    }

    List<TicketModel> ticketsParsed = [];
    
    for (var i = 0; i < dataList.length; i++) {
      try {
        final jsonItem = dataList[i];
        ticketsParsed.add(TicketModel.fromJson(jsonItem));
      } catch (e) {
        // ¡ESTO IMPRIMIRÁ EL ERROR EXACTO EN TU TERMINAL!
        print('🚨 ERROR CRÍTICO PARSEANDO EL TICKET EN EL ÍNDICE $i 🚨');
        print('ID del ticket problemático: ${dataList[i]['idticket']}');
        print('El error de Dart es: $e');
        // rethrow; // Comenta o descomenta esto si quieres que falle por completo
      }
    }
    
    return ticketsParsed;
  }
}