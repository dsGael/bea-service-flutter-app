// models/solicitud_refaccion_result.dart
class SolicitudRefaccionResult {
  final String idSolicitud;
  final String idTicket;

  SolicitudRefaccionResult({required this.idSolicitud, required this.idTicket});

  factory SolicitudRefaccionResult.fromJson(Map<String, dynamic> json) {
    return SolicitudRefaccionResult(
      idSolicitud: json['idSolicitud'] as String,
      idTicket: json['idTicket'] as String,
    );
  }
}