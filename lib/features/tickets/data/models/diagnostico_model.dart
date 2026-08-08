class DiagnosticoModel {
  final String idDiagnostico;
  final String diagnostico;
  final String? reparacion;
  final String? fallaNombre;

  DiagnosticoModel({
    required this.idDiagnostico,
    required this.diagnostico,
    this.reparacion,
    this.fallaNombre,
  });

  factory DiagnosticoModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoModel(
      idDiagnostico: json['idDiagnostico'],
      diagnostico: json['diagnostico'] ?? '',
      reparacion: json['reparacion'],
      fallaNombre: json['fallaNombre'],
    );
  }
}