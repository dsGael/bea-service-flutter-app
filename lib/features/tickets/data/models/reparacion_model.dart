import 'package:bea_service_app/features/tickets/data/models/catalogos_models.dart';

class ReparacionModel {
  final String idDetalle;
  final String? idTicket;
  final String? diagnostico;
  final String? reparacion;
  final String? comentarios;
  final String? refacciones; // Mantenido para tu futuro cambio de relación
  final DateTime? fechaResolucion;
  final DispositivoModel? dispositivo;
  
  // Guardará las URLs de las fotos/videos de la reparación
  final List<String> evidencias; 

  ReparacionModel({
    required this.idDetalle,
    this.idTicket,
    this.diagnostico,
    this.reparacion,
    this.comentarios,
    this.fechaResolucion,
    this.refacciones,
    this.evidencias = const [],
    this.dispositivo,
  });

  factory ReparacionModel.fromJson(Map<String, dynamic> json) {
    return ReparacionModel(
      idDetalle: json['idDetalle'] ?? json['id_detalle'] ?? json['id'] ?? '',
      idTicket: json['idTicket'] ?? json['idticket'],
      
      // ✅ CORRECCIÓN: Buscamos primero con Mayúscula (como viene en tu JSON) y luego minúscula por si acaso
      diagnostico: json['Diagnostico'] ?? json['diagnostico'],
      reparacion: json['Reparacion'] ?? json['reparacion'],
      
      refacciones: json['refacciones'],
      comentarios: json['comentarios'],
      
      fechaResolucion: (json['fechaResolucion'] ?? json['fecha_resolucion']) != null 
          ? DateTime.tryParse((json['fechaResolucion'] ?? json['fecha_resolucion']))
          : null,
          
      // ✅ CORRECCIÓN: Leemos el arreglo desde 'imagen1' que es como lo envía Prisma
      evidencias: json['imagen1'] != null 
          ? List<String>.from(json['imagen1']) 
          : (json['evidencias'] != null ? List<String>.from(json['evidencias']) : []),

      dispositivo: json['cat_dispositivo_t'] != null 
          ? DispositivoModel.fromJson(json['cat_dispositivo_t']) 
          : null,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetalle': idDetalle,
      'idTicket': idTicket,
      'diagnostico': diagnostico,
      'reparacion': reparacion,
      'comentarios': comentarios,
      'refacciones': refacciones,
      'fechaResolucion': fechaResolucion?.toUtc().toIso8601String(),
      'evidencias': evidencias,
    };
  }
}