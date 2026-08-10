// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();

  // Ajusta a tu dominio real cuando tengas Nginx+SSL corriendo
  static const String baseUrl = 'http://192.168.100.4:3000';

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.obtenerToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 401 -> el token expiró o es inválido, hay que forzar re-login
        if (error.response?.statusCode == 401) {
          await _tokenStorage.borrarTodo();
          // aquí disparas navegación a login — se conecta con el router más adelante
        }
        return handler.next(error);
      },
    ));
  }


  dynamic unwrap(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body; 
  }

}