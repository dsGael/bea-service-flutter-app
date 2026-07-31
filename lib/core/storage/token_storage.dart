// lib/core/storage/token_storage.dart
import 'dart:convert'; // Importante para jsonEncode y jsonDecode
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'usuario_data';

  // 1. Guardar el Token
  Future<void> guardarToken(String token) =>  _storage.write(key: _tokenKey, value: token);

  // 2. Guardar el Usuario (Transformado a JSON válido)
  Future<void> guardarUsuario(Map<String, dynamic> usuario) =>  _storage.write(key: _userKey, value: jsonEncode(usuario));

  // 3. Obtener el Token
  Future<String?> obtenerToken() => _storage.read(key: _tokenKey);

  // 4. Obtener el Usuario (Transformado de vuelta a Map)
  Future<Map<String, dynamic>?> obtenerUsuario() async {
    final userString = await _storage.read(key: _userKey);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  // 5. Borrar  (Ideal para el logout)
  Future<void> borrarTodo() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}