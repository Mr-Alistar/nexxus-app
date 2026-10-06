//Modelo para la gestión de los campos del formulario que llenan los aspirantes
class Prospecto {
  int? id;
  String nombre;
  String apellido1;
  String? apellido2;
  String genero;
  String email;
  String telefono;
  String? telReferencia;
  String tipoZona;
  String carrera;
  String modalidad;
  String preparatoria;
  String medioEnterado;
  String? nota;
  //Campos que NO se exportan en los archivos:
  String status;
  int idAsesor;
  String? createdAt;
  String? updatedAt;

  Prospecto({
    this.id,
    required this.nombre, //le pongo "required" para campos obligatorios
    required this.apellido1,
    this.apellido2,
    required this.genero,
    required this.email,
    required this.telefono,
    this.telReferencia,
    required this.tipoZona,
    required this.carrera,
    required this.modalidad,
    required this.preparatoria,
    required this.medioEnterado,
    this.nota,
    this.status = 'sin-contacto',//de acuerdo a su base de datos web
    this.idAsesor = 1,
    this.createdAt,
    this.updatedAt,
  });

  // Metodo para convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    final map = {
      'nombre': nombre,
      'apellido1': apellido1,
      'apellido2': apellido2,
      'genero': genero,
      'email': email,
      'telefono': telefono,
      'tel_referencia': telReferencia,
      'tipo_zona': tipoZona,
      'carrera': carrera,
      'modalidad': modalidad,
      'preparatoria': preparatoria,
      'medio_enterado': medioEnterado,
      'status': status,
      'id_asesor': idAsesor,
      'nota': nota,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }
//Proceso inverso, como realizar un query a SQLite
  factory Prospecto.fromMap(Map<String, dynamic> map) {
    return Prospecto(
      id: map['id'],
      nombre: map['nombre'],
      apellido1: map['apellido1'],
      apellido2: map['apellido2'],
      genero: map['genero'],
      email: map['email'],
      telefono: map['telefono'],
      telReferencia: map['tel_referencia'],
      tipoZona: map['tipo_zona'],
      carrera: map['carrera'],
      modalidad: map['modalidad'],
      preparatoria: map['preparatoria'],
      medioEnterado: map['medio_enterado'],
      status: map['status'] ?? 'sin-contacto',
      idAsesor: map['id_asesor'] ?? 1,
      nota: map['nota'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}