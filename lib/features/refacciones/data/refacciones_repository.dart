import 'dart:io';
import 'package:bea_service_app/features/refacciones/data/models/refaccion_model.dart';
import 'package:bea_service_app/features/tickets/data/models/catalogos_models.dart';
import 'package:dio/dio.dart';
// Asegúrate de importar tu ApiClient y el modelo que creamos
// import '../../core/api_client.dart';
// import '../models/solicitud_refaccion_model.dart';

class RefaccionesRepository {
  final dynamic _apiClient; // Reemplaza 'dynamic' por tu clase ApiClient real

  RefaccionesRepository(this._apiClient);

  // 1. Crear Solicitud (Lo usa el Técnico)
  Future<void> crearSolicitud({
    String? idTicket,
    required String idDispositivo,
    required double cantidad,
  }) async {
    final data = {
      if (idTicket != null) 'idticket': idTicket,
      'idDispositivo': idDispositivo,
      'cantidad': cantidad,
    };
    
    await _apiClient.dio.post('/refacciones', data: data);
  }

  // 2. Listar Refacciones de un Ticket específico
  Future<List<SolicitudRefaccionModel>> listarPorTicket(String idTicket) async {
    final response = await _apiClient.dio.get('/refacciones/ticket/$idTicket');
    final rawData = response.data;
    
    List<dynamic> lista = [];
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      lista = rawData['data'];
    } else if (rawData is List) {
      lista = rawData;
    }

    return lista.map((json) => SolicitudRefaccionModel.fromJson(json)).toList();
  }

  Future<List<DispositivoModel>> listarDispositivosPorTipo(String tipo) async {
    final response = await _apiClient.dio.get('/catalogos/dispositivo/tipo/$tipo');
    final rawData = response.data;

    List<dynamic> lista = [];
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      lista = rawData['data'];
    } else if (rawData is List) {
      lista = rawData;
    }

    return lista.map((json) => DispositivoModel.fromJson(json)).toList();
  }


  // 3. Subir Evidencias de Entrega (Lo usa Almacén)
  Future<void> subirEvidencias({
    required String idSolicitud,
    required String folio, // Para crear la carpeta correcta en MinIO
    required List<File> evidencias,
  }) async {
    final formData = FormData();

    for (var file in evidencias) {
      formData.files.add(MapEntry(
        'evidencias', // 👈 Debe coincidir exacto con FilesInterceptor('evidencias') en NestJS
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        )
      ));
    }

    await _apiClient.dio.patch('/refacciones/$idSolicitud/evidencias/$folio', data: formData);
  }

  // 4. Cambiar Estado (Lo usa Almacén para entregar/rechazar)
  Future<void> actualizarEstado({
    required String idSolicitud,
    required String estado,
    String? idAlmacen,
  }) async {
    final data = {
      'estado': estado,
      if (idAlmacen != null) 'idAlmacen': idAlmacen,
    };

    await _apiClient.dio.patch('/refacciones/$idSolicitud/estado', data: data);
  }
}