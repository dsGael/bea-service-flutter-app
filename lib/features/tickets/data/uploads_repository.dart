import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class UploadsRepository {
  final ApiClient _apiClient;
  UploadsRepository(this._apiClient);

  Future<String> subirImagen(File archivo) async {
    final ext = archivo.path.split('.').last.toLowerCase();
    final contentType = _contentTypeForExtension(ext);

    final response = await _apiClient.dio.post('/uploads/presigned-url', data: {
      'carpeta': 'tickets',
      'extension': ext,
      'contentType': contentType,
    });

    final body = _apiClient.unwrap(response) as Map<String, dynamic>;
    final uploadUrl = body['uploadUrl'] as String;
    final publicUrl = body['publicUrl'] as String;

    // 2. Sube el archivo DIRECTO a MinIO con Dio plano (sin el interceptor de JWT)
    //    porque la URL firmada ya tiene autenticación embebida
    final dioPlano = Dio();
    final bytes = await archivo.readAsBytes();

    await dioPlano.put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
      ),
    );

    return publicUrl; // esta URL es la que guardas en la base de datos
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case 'm4v':
        return 'video/x-m4v';
      default:
        return 'application/octet-stream';
    }
  }
}