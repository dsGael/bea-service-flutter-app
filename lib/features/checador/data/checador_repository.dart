import 'package:uuid/uuid.dart';
import '../../../core/api/api_client.dart';
import './checador_models.dart';
import '../../../core/storage/device_id_storage.dart';


class ChecadorRepository {
  final ApiClient _apiClient;
  final _uuid = const Uuid();
  final _deviceIdStorage = DeviceIdStorage();

  ChecadorRepository(this._apiClient);

  Future<ChecadorModel> registrarChecada({
    required String idUsuarioApp,
    required String nombre,
    required double lat,
    required double lng,
  }) async {
    final ahora = DateTime.now();
    final ahoraUtc = ahora.toUtc();
    final hora = '${ahoraUtc.hour.toString().padLeft(2, '0')}:${ahoraUtc.minute.toString().padLeft(2, '0')}:${ahoraUtc.second.toString().padLeft(2, '0')}';
    final idChecador = _uuid.v4();
    final deviceUUID = await _deviceIdStorage.obtener(); // <- agregado

    final response = await _apiClient.dio.post('/checador', data: {
      'idChecador': idChecador,
      'idUsuario': idUsuarioApp,
      'nombre': nombre,
      'hora': hora,
      'fecha_hora': ahoraUtc.toIso8601String(),
      'gps': {'lat': lat, 'lng': lng},
      'deviceUUID': deviceUUID,
    });

    final data = _apiClient.unwrap(response) as Map<String, dynamic>;
    return ChecadorModel.fromJson(data);
  }
}