import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:nexxus/Models/formulario_model.dart';
// Este archivo de servicio gestiona la base de datos local SQLite de la app.

class FormularioService {
  static final FormularioService instancia = FormularioService._init();
  static Database? _baseDatos;

  FormularioService._init();

  Future<Database> get database async {
    if (_baseDatos != null) return _baseDatos!;
    _baseDatos = await _inicializarBD('nexxus_movil.db');
    return _baseDatos!;
  }

  // Inicializa la conexion con la base de datos.
  Future<Database> _inicializarBD(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Como la aplicación está en desarrollo, usamos la versión 1
    return await openDatabase(path, version: 1, onCreate: _crearDB);
  }

  // Crea las tablas necesarias para el funcionamiento de la aplicación.
  Future _crearDB(Database db, int version) async {
    // Tabla para prospectos locales
    await db.execute('''
      CREATE TABLE prospectos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido1 TEXT NOT NULL,
        apellido2 TEXT,
        genero TEXT NOT NULL,
        email TEXT,
        telefono TEXT,
        tel_referencia TEXT,
        tipo_zona TEXT NOT NULL,
        carrera TEXT NOT NULL,
        modalidad TEXT NOT NULL,
        preparatoria TEXT NOT NULL,
        medio_enterado TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'sin-contacto',
        id_asesor INTEGER NOT NULL,
        nota TEXT,
        created_at DATETIME DEFAULT NULL,
        updated_at DATETIME DEFAULT NULL
      )
    ''');

    // Tabla para almacenar la información de las carreras y sus imageenes
    await db.execute('''
      CREATE TABLE carreras (
        siglas TEXT PRIMARY KEY,
        nombre TEXT,
        acerca_de TEXT,
        plan_estudios TEXT,
        modalidad TEXT,
        url_imagenes TEXT,
        rutas_locales TEXT
      )
    ''');
  }

  // METODOS PARA PROSPECTOS*******

  // Registra un nuevo prospecto en la base de datos local
  Future<int> insertarProspecto(Prospecto prospecto) async {
    final db = await instancia.database;
    return await db.insert('prospectos', prospecto.toMap());
  }

  // Obtiene la lista completa de prospectos ordenados por recientes
  Future<List<Prospecto>> obtenerProspectos() async {
    final db = await instancia.database;
    final result = await db.query('prospectos', orderBy: 'id DESC');

    return result.map((json) => Prospecto.fromMap(json)).toList();
  }

  // Actualiza la info de un prospecto existente
  Future<int> actualizarProspecto(Prospecto prospecto) async {
    final db = await instancia.database;
    return await db.update(
      'prospectos',
      prospecto.toMap(),
      where: 'id = ?',
      whereArgs: [prospecto.id],
    );
  }

  // Elimina un prospecto de la base de datos local
  Future<int> eliminarProspecto(int id) async {
    final db = await instancia.database;
    return await db.delete(
      'prospectos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtiene el número total de prospectos guardados localmente
  Future<int> contarProspectos() async {
    final db = await instancia.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM prospectos');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Obtiene el conteo de prospectos filtrados por estatus (ej. 'sin-contacto')
  Future<int> contarProspectosPorStatus(String status) async {
    final db = await instancia.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM prospectos WHERE status = ?',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
