import 'package:bea_service_app/features/refacciones/data/models/refaccion_model.dart';
import 'package:bea_service_app/features/tickets/data/models/catalogos_models.dart';
import 'package:bea_service_app/features/tickets/data/models/reparacion_model.dart';

class TicketModel {
  final String idticket;
  final String? folio;
  final String? comentarios;
  final String? numeroeconomico; // Lo dejamos directo por si viene en la raíz
  final DateTime? fechacreacion;
  final String? nombreoperador;
  final String? tiporeparacion;
  final String? areatrabajo;
  final List<String>? imagenfalla1;
  final List<String>? video;

  // --- RELACIONES (CATÁLOGOS) ---
  final FallaModel? falla;
  final AutobusModel? autobus;
  final PrioridadModel? prioridad;
  final EstadoModel? estado;
  final TecnicoModel? tecnico;
  final DispositivoModel? dispositivo;
  final List<SolicitudRefaccionModel> refacciones;
  final List<ReparacionModel> reparaciones;

  TicketModel({
    required this.idticket,
    this.folio,
    this.comentarios,
    this.numeroeconomico,
    this.fechacreacion,
    this.nombreoperador,
    this.tiporeparacion,
    this.areatrabajo,
    this.imagenfalla1,
    this.video,
    this.falla,
    this.autobus,
    this.prioridad,
    this.estado,
    this.tecnico,
    this.dispositivo,
    this.refacciones = const [],
    this.reparaciones = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      idticket: json['idticket'] ?? '',
      folio: json['folio'],
      comentarios: json['comentarios'],
      numeroeconomico: json['numeroeconomico'],
      fechacreacion: json['fechacreacion'] != null
          ? DateTime.tryParse(json['fechacreacion'])
          : null,
      nombreoperador: json['nombreoperador'],
      tiporeparacion: json['tiporeparacion'],
      areatrabajo: json['areatrabajo'],
      
      // Listas de multimedia seguras
      imagenfalla1: json['imagenfalla1'] != null 
          ? List<String>.from(json['imagenfalla1']) 
          : null,
      video: json['video'] != null 
          ? List<String>.from(json['video']) 
          : null,

      // --- MAPEO DE CATÁLOGOS ---
      // Si el objeto JSON existe, llamamos al fromJson de su respectiva clase
      falla: json['cat_falla'] != null ? FallaModel.fromJson(json['cat_falla']) : null,
      autobus: json['cat_autobus'] != null ? AutobusModel.fromJson(json['cat_autobus']) : null,
      prioridad: json['cat_prioridad'] != null ? PrioridadModel.fromJson(json['cat_prioridad']) : null,
      estado: json['estado'] != null ? EstadoModel.fromJson(json['estado']) : null,
      tecnico: json['cat_tecnicos'] != null ? TecnicoModel.fromJson(json['cat_tecnicos']) : null,
      dispositivo: json['cat_dispositivo_t'] != null ? DispositivoModel.fromJson(json['cat_dispositivo_t']) : null,
      refacciones: json['solicitud_refaccion'] != null 
          ? List<SolicitudRefaccionModel>.from(
              (json['solicitud_refaccion'] as List).map((x) => SolicitudRefaccionModel.fromJson(x))
            ) 
          : [],
      reparaciones: json['bin_ticket_detail'] != null 
          ? List<ReparacionModel>.from(
              (json['bin_ticket_detail'] as List).map((x) => ReparacionModel.fromJson(x))
            ) 
          : [],
    );
  }
}