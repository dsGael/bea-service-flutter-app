class TicketModel {
  final String idticket;
  final String? folio;
  final String? comentarios;
  final String? nombreEstado; // viene del include: estado en tu API
  final String? nombreFalla;
  final String? numeroeconomico;
  final DateTime? fechacreacion;

  TicketModel({
    required this.idticket,
    this.folio,
    this.comentarios,
    this.nombreEstado,
    this.nombreFalla,
    this.numeroeconomico,
    this.fechacreacion,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      idticket: json['idticket'],
      folio: json['folio'],
      comentarios: json['comentarios'],
      nombreEstado: json['estado']?['nombre'],
      nombreFalla: json['cat_falla']?['nombre'],
      numeroeconomico: json['numeroeconomico'],
      fechacreacion: json['fechacreacion'] != null
          ? DateTime.parse(json['fechacreacion'])
          : null,
    );
  }
}