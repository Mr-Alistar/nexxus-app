class ConteoItem {
  final int? id;
  final String nombre;
  final int total;

  const ConteoItem({this.id, required this.nombre, required this.total});

  factory ConteoItem.fromJson(Map<String, dynamic> json) => ConteoItem(
        id: (json['id'] as num?)?.toInt(),
        nombre: (json['nombre'] ?? 'Sin especificar').toString(),
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}

class DashboardData {
  final String nombreUsuario;
  final String rol;
  final int totalProspectos;
  final int solicitudesSemana;
  final List<ConteoItem> porCarrera;
  final List<ConteoItem> porPreparatoria;
  final List<ConteoItem> porModalidad;

  const DashboardData({
    required this.nombreUsuario,
    required this.rol,
    required this.totalProspectos,
    required this.solicitudesSemana,
    required this.porCarrera,
    required this.porPreparatoria,
    required this.porModalidad,
  });

  static List<ConteoItem> _lista(dynamic raw) => raw is List
      ? raw
          .whereType<Map>()
          .map((e) => ConteoItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
      : <ConteoItem>[];

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] is Map
        ? Map<String, dynamic>.from(json['usuario'])
        : <String, dynamic>{};
    return DashboardData(
      nombreUsuario: (usuario['nombre'] ?? '').toString(),
      rol: (usuario['rol'] ?? '').toString(),
      totalProspectos: (json['total_prospectos'] as num?)?.toInt() ?? 0,
      solicitudesSemana: (json['solicitudes_semana'] as num?)?.toInt() ?? 0,
      porCarrera: _lista(json['por_carrera']),
      porPreparatoria: _lista(json['por_preparatoria']),
      porModalidad: _lista(json['por_modalidad']),
    );
  }
}