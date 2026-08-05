import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdStorage {
  final _storage = const FlutterSecureStorage();
  static const _key = 'device_uuid';
  final _uuid = const Uuid();

  Future<String> obtener() async {
    String? id = await _storage.read(key: _key);

    if (id == null) {
      // primera vez que corre la app en este celular — se genera una sola vez
      id = _uuid.v4();
      await _storage.write(key: _key, value: id);
    }

    return id;
  }
}