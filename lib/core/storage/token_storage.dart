// lib/core/storage/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _key = 'jwt_token';

  Future<void> guardar(String token) => _storage.write(key: _key, value: token);
  Future<String?> obtener() => _storage.read(key: _key);
  Future<void> borrar() => _storage.delete(key: _key);
}