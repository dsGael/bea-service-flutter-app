import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String identificador, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'usuario': identificador,
      'password': password,
    });

    final token = response.data['access_token'] as String;
    final usuario = response.data['usuario'] as Map<String, dynamic>;
    await _tokenStorage.guardarToken(token);
    await _tokenStorage.guardarUsuario(usuario);

    return usuario;
  }

  Future<void> logout() => _tokenStorage.borrarTodo();

  Future<Map<String, dynamic>?> restaurarSesion() async {
  final token = await _tokenStorage.obtenerToken();
  if (token == null) return null;

    try {
      final response = await _apiClient.dio.get('/auth/me');
      return _apiClient.unwrap(response) as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.borrarTodo(); // token inválido/expirado — limpia y manda a login
        return null;
      }
      rethrow; // otros errores (sin conexión, etc.) sí los quieres saber, no los escondas
    }
  }

}