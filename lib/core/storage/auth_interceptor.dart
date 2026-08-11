import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor que inyecta el Bearer Token en cada petición.
/// Funciona igual para JSON y multipart/form-data porque NO sobreescribe
/// el mapa completo de headers, solo agrega/actualiza la key 'Authorization'.
class AuthInterceptor extends InterceptorsWrapper {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Leemos el token guardado tras el login
    final token = await _secureStorage.read(key: 'access_token');

    if (token != null && token.isNotEmpty) {
      // CRÍTICO: usamos options.headers['Authorization'] = ...
      // NO options.headers = {...} porque esto último borraría el
      // Content-Type multipart/form-data que Dio ya configuró
      // automáticamente al detectar un FormData en el body.
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Debug temporal — quítalo en producción, pero déjalo mientras
    // debuggeas el 403 para confirmar que el header sí viaja.
    // print('➡️ ${options.method} ${options.path}');
    // print('➡️ Headers: ${options.headers}');

    return handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Si es 401, aquí podrías intentar refresh token.
    // Un 403 normalmente NO se soluciona con refresh — es un problema
    // de permisos, no de autenticación expirada. No lo trates igual que 401.
    if (err.response?.statusCode == 403) {
      // Log específico para que en Crashlytics/Sentry puedas diferenciar
      // "no autenticado" de "autenticado pero sin permiso".
      print('🚫 403 Forbidden en ${err.requestOptions.path}: '
          '${err.response?.data}');
    }

    return handler.next(err);
  }
}