class FallaModel {
  final String idFalla;
  final String? nombre;
  final String? falla;

  FallaModel({required this.idFalla, this.nombre, this.falla});

  factory FallaModel.fromJson(Map<String, dynamic> json) {
    return FallaModel(
      idFalla: json['idFalla'] ?? '',
      nombre: json['nombre'],
      falla: json['falla'],
    );
  }
}

class AutobusModel {
  final String idAutobus;
  final String? numeroEconomico;
  final String? numeroSerie;
  final bool? hasNfc;

  AutobusModel({required this.idAutobus, this.numeroEconomico, this.numeroSerie, this.hasNfc});

  factory AutobusModel.fromJson(Map<String, dynamic> json) {
    return AutobusModel(
      idAutobus: json['idAutobus'] ?? '',
      numeroEconomico: json['numeroEconomico'],
      numeroSerie: json['numeroSerie'],
      hasNfc: json['has_nfc'],
    );
  }
}

class PrioridadModel {
  final String idPrioridad;
  final String? nombre;

  PrioridadModel({required this.idPrioridad, this.nombre});

  factory PrioridadModel.fromJson(Map<String, dynamic> json) {
    return PrioridadModel(
      idPrioridad: json['idPrioridad'] ?? '',
      nombre: json['nombre'],
    );
  }
}

class EstadoModel {
  final String idEstadoR;
  final String? nombre;

  EstadoModel({required this.idEstadoR, this.nombre});

  factory EstadoModel.fromJson(Map<String, dynamic> json) {
    return EstadoModel(
      idEstadoR: json['idEstadoR'] ?? '',
      nombre: json['nombre'],
    );
  }
}

class TecnicoModel {
  final String idUsuarioApp;
  final String? especialidad;
  final String? useremail;

  TecnicoModel({required this.idUsuarioApp, this.especialidad, this.useremail});

  factory TecnicoModel.fromJson(Map<String, dynamic> json) {
    return TecnicoModel(
      idUsuarioApp: json['idUsuarioApp'] ?? '',
      especialidad: json['especialidad'],
      useremail: json['useremail'],
    );
  }
}

class DispositivoModel {
  final String idDispositivoT;
  final String? nombre;
  final String? descripcion;

  DispositivoModel({required this.idDispositivoT, this.nombre, this.descripcion});

  factory DispositivoModel.fromJson(Map<String, dynamic> json) {
    return DispositivoModel(
      idDispositivoT: json['idDispositivoT'] ?? '',
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }
}