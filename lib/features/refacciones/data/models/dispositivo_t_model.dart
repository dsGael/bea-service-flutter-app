class CatDispositivoModel {
  final String idDispositivoT;
  final String nombre; // Cambia esto si en tu BD se llama 'descripcion' o de otra forma

  CatDispositivoModel({
    required this.idDispositivoT,
    required this.nombre,
  });

  factory CatDispositivoModel.fromJson(Map<String, dynamic> json) {
    return CatDispositivoModel(
      idDispositivoT: json['idDispositivoT'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? json['descripcion'] ?? 'Desconocido',
    );
  }
}