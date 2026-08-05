class ChecadorModel {
  final String idChecador;
  final String? tipo; // "entrada" | "salida" — lo decide el trigger de tu base
  final DateTime? horaEntrada;
  final DateTime? horaSalida;
  final double? minutosRetardo;

  ChecadorModel({
    required this.idChecador,
    this.tipo,
    this.horaEntrada,
    this.horaSalida,
    this.minutosRetardo,
  });

 factory ChecadorModel.fromJson(Map<String, dynamic> json) {
  return ChecadorModel(
    idChecador: json['idChecador'],
    tipo: (json['tipo'] as String?)?.toLowerCase(), // normalizado aquí, una sola vez
    horaEntrada: json['HoraEntrada'] != null ? DateTime.parse(json['HoraEntrada']) : null,
    horaSalida: json['HoraSalida'] != null ? DateTime.parse(json['HoraSalida']) : null,
    minutosRetardo: json['minutos_retardo'] != null
        ? double.tryParse(json['minutos_retardo'].toString())
        : null,
  );
}
}