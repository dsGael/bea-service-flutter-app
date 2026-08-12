import 'dart:io';
import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bea_service_app/features/refacciones/data/models/refaccion_model.dart';
import 'package:bea_service_app/features/refacciones/data/refacciones_repository.dart';
import 'package:bea_service_app/features/tickets/data/models/catalogos_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===========================================================================
// ── 1. PROVEEDOR DEL REPOSITORIO ──
// ===========================================================================
final refaccionesRepositoryProvider = Provider<RefaccionesRepository>((ref) {
  // Asegúrate de usar el provider de tu ApiClient
  return RefaccionesRepository(ref.watch(apiClientProvider)); 
});


// ===========================================================================
// ── 2. PROVEEDORES DE LECTURA (GET) ──
// ===========================================================================
// Ideal para mostrarle al técnico qué piezas ha pedido para su ticket actual
final refaccionesPorTicketProvider = FutureProvider.autoDispose.family<List<SolicitudRefaccionModel>, String>((ref, idTicket) async {
  return ref.watch(refaccionesRepositoryProvider).listarPorTicket(idTicket);
});

final dispositivosPorTipoProvider = FutureProvider.autoDispose.family<List<DispositivoModel>, String>((ref, tipo) async {
  return ref.watch(refaccionesRepositoryProvider).listarDispositivosPorTipo(tipo);
});

// ===========================================================================
// ── 3. CONTROLADOR DE ACCIONES (POST / PATCH) ──
// ===========================================================================
final refaccionesControllerProvider = Provider.autoDispose<RefaccionesController>((ref) {
  return RefaccionesController(ref.watch(refaccionesRepositoryProvider));
});

class RefaccionesController {
  final RefaccionesRepository _repository;

  RefaccionesController(this._repository);

  // El técnico pide la pieza
  Future<void> solicitarRefaccion({
    required String idTicket,
    required String idDispositivo,
    required double cantidad,
  }) async {
    await _repository.crearSolicitud(
      idTicket: idTicket,
      idDispositivo: idDispositivo,
      cantidad: cantidad,
    );
  }

  // El almacén entrega la pieza con foto
  Future<void> entregarRefaccion({
    required String idSolicitud,
    required String folioTicket,
    required String idAlmacen,
    required List<File> fotosEvidencia,
  }) async {
    // 1. Primero sube la foto (Evidencia)
    if (fotosEvidencia.isNotEmpty) {
      await _repository.subirEvidencias(
        idSolicitud: idSolicitud,
        folio: folioTicket,
        evidencias: fotosEvidencia,
      );
    }

    // 2. Si la foto sube bien, cambia el estado a "entregada" para rebajar inventario
    await _repository.actualizarEstado(
      idSolicitud: idSolicitud,
      estado: 'entregada',
      idAlmacen: idAlmacen,
    );
  }
  
  // Para rechazos u otros estados
  Future<void> cambiarEstadoRefaccion(String idSolicitud, String nuevoEstado) async {
    await _repository.actualizarEstado(
      idSolicitud: idSolicitud,
      estado: nuevoEstado,
    );
  }
}