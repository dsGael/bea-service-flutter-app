// Si tienes tus otros modelos, impórtalos aquí para usar las relaciones.
// import 'ticket_model.dart'; 
// import 'tecnico_model.dart';

class SolicitudRefaccionModel {
  final String idSolicitud;
  final String? idticket;
  final String? idDispositivo;
  final double? cantidad;
  final String? idTecnico;
  final String? estado;
  final DateTime? fecha;
  final List<String> imagen;

  // ── Relaciones (Incluidas por Prisma) ──
  // Nota: Usa 'dynamic' o el tipo de tu modelo real si ya lo tienes creado
  final dynamic dispositivoT; 
  final dynamic ticket;
  final dynamic tecnico;

  SolicitudRefaccionModel({
    required this.idSolicitud,
    this.idticket,
    this.idDispositivo,
    this.cantidad,
    this.idTecnico,
    this.estado,
    this.fecha,
    this.imagen = const [],
    this.dispositivoT,
    this.ticket,
    this.tecnico,
  });

  factory SolicitudRefaccionModel.fromJson(Map<String, dynamic> json) {
    return SolicitudRefaccionModel(
      idSolicitud: json['idSolicitud'] ?? '',
      idticket: json['idticket'],
      idDispositivo: json['idDispositivo'],
      
      // Manejo seguro para 'cantidad' (evita crasheos si llega como int, double o string)
      cantidad: json['cantidad'] != null 
          ? double.tryParse(json['cantidad'].toString()) 
          : 1.0,
          
      idTecnico: json['idTecnico'],
      estado: json['estado'],
      
      // Parseo seguro de fecha, convirtiéndola automáticamente a la hora del celular (Sonora)
      fecha: json['fecha'] != null 
          ? DateTime.tryParse(json['fecha'])?.toLocal() 
          : null,
          
      // Manejo seguro del arreglo de imágenes
      imagen: json['imagen'] != null 
          ? List<String>.from(json['imagen']) 
          : [],

      // Mapeo de relaciones (si vienen en el JSON gracias al 'include' de Prisma)
      dispositivoT: json['cat_dispositivo_t'],
      ticket: json['bin_ticket'], // Si tienes el modelo: json['bin_ticket'] != null ? TicketModel.fromJson(json['bin_ticket']) : null
      tecnico: json['cat_tecnicos'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSolicitud': idSolicitud,
      'idticket': idticket,
      'idDispositivo': idDispositivo,
      'cantidad': cantidad,
      'idTecnico': idTecnico,
      'estado': estado,
      // Solo enviamos la fecha si existe, volviéndola a formato ISO (UTC)
      'fecha': fecha?.toUtc().toIso8601String(),
      'imagen': imagen,
    };
  }
  
  // Método copyWith (Opcional, pero muy útil en Riverpod para actualizar estados locales)
  SolicitudRefaccionModel copyWith({
    String? idSolicitud,
    String? idticket,
    String? idDispositivo,
    double? cantidad,
    String? idTecnico,
    String? estado,
    DateTime? fecha,
    List<String>? imagen,
  }) {
    return SolicitudRefaccionModel(
      idSolicitud: idSolicitud ?? this.idSolicitud,
      idticket: idticket ?? this.idticket,
      idDispositivo: idDispositivo ?? this.idDispositivo,
      cantidad: cantidad ?? this.cantidad,
      idTecnico: idTecnico ?? this.idTecnico,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      imagen: imagen ?? this.imagen,
      dispositivoT: dispositivoT,
      ticket: ticket,
      tecnico: tecnico,
    );
  }
}