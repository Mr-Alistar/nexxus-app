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

  // Inicializa la conexión con la base de datos.
  Future<Database> _inicializarBD(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _crearDB);
  }

  // Crea las tablas necesarias para el funcionamiento de la aplicación.
  Future _crearDB(Database db, int version) async {
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

  // ====== MÉTODOS PARA PROSPECTOS ======

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

  // [NUEVO]: Actualiza el status del prospecto a 'sincronizado' cuando se sube al CRM
  // para que pase automáticamente de la sección "Local (pendientes)" a "En la nube".
  Future<int> marcarComoSincronizado(int id) async {
    final db = await instancia.database;
    return await db.update(
      'prospectos',
      {
        'status': 'sincronizado',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
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
}