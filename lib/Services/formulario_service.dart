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

  // Siembra 10 prospectos de demostración solo si la tabla está vacía.
  // Útil para probar el dashboard y la lista de registrados sin capturar a mano.
  Future<void> sembrarDatosDemoSiVacio() async {
    final db = await instancia.database;

    // Autorreparación: una versión anterior del seed guardaba valores que no
    // existen en los Dropdown del formulario ('Preparatoria Demo', 'Rural',
    // 'TSU en Gastronomía') y rompían la pantalla de edición. Se eliminan esos
    // registros demo defectuosos para que vuelvan a sembrarse corregidos.
    await db.delete(
      'prospectos',
      where: "nota = ? AND preparatoria = ?",
      whereArgs: ['Registro de demostración', 'Preparatoria Demo'],
    );

    final total = await contarProspectos();
    if (total > 0) return; // ya hay datos válidos, no duplicamos

    // IMPORTANTE: todos los valores de género, zona, carrera, modalidad,
    // preparatoria y medio deben coincidir EXACTAMENTE con las listas de
    // formulario_opciones.dart; de lo contrario el DropdownButton del
    // formulario de edición lanza una excepción al abrir el registro.
    // Columnas: nombre, apellido1, apellido2, genero, tipoZona, carrera,
    //           modalidad, preparatoria, medio, status
    final demos = [
      ['Juan', 'Pérez', 'López', 'Hombre', 'Urbana (ciudad)', 'Ingeniería en Datos e Inteligencia Artificial', 'Escolarizada', 'Cbtis 253', 'Facebook', 'sin-contacto'],
      ['María', 'García', 'Hernández', 'Mujer', 'Rural (poblado)', 'Ingeniería en Mecatrónica', 'Mixta', 'Cecyte', 'Instagram', 'sin-contacto'],
      ['Carlos', 'Ramírez', 'Santos', 'Hombre', 'Urbana (ciudad)', 'Licenciatura en Gastronomía', 'Escolarizada', 'Conalep', 'Recomendación', 'en-comunicacion'],
      ['Ana', 'Martínez', 'Cruz', 'Mujer', 'Urbana (ciudad)', 'Ingeniería Financiera', 'Escolarizada', 'Cbta 11', 'Facebook', 'sin-contacto'],
      ['Luis', 'Sánchez', 'Gómez', 'Hombre', 'Rural (poblado)', 'Ingeniería en Mecatrónica', 'PEESAD', 'Cetmar', 'Radio', 'en-comunicacion'],
      ['Sofía', 'Torres', 'Díaz', 'Mujer', 'Extranjero', 'Licenciatura en Gastronomía', 'Mixta', 'Instituto Modelo', 'Feria universitaria', 'sin-contacto'],
      ['Diego', 'Flores', 'Reyes', 'Hombre', 'Urbana (ciudad)', 'Ingeniería en Tecnologías de la Información e Innovación Digital', 'Escolarizada', 'Cbtis 214', 'Instagram', 'sin-contacto'],
      ['Valeria', 'Castillo', 'Morales', 'Mujer', 'Rural (poblado)', 'Licenciatura en Innovación de Negocios y Mercadotecnia', 'Escolarizada', 'Conalep', 'Facebook', 'en-comunicacion'],
      ['Jorge', 'Ortiz', 'Vargas', 'Hombre', 'Urbana (ciudad)', 'Ingeniería en Datos e Inteligencia Artificial', 'Mixta', 'Cecyte', 'Recomendación', 'sin-contacto'],
      ['Camila', 'Jiménez', 'Rojas', 'Mujer', 'Rural (poblado)', 'Ingeniería Financiera', 'PEESAD', 'Otro', 'Instagram', 'sin-contacto'],
    ];

    final ahora = DateTime.now();
    final batch = db.batch();

    for (var i = 0; i < demos.length; i++) {
      final d = demos[i];
      final prospecto = Prospecto(
        nombre: d[0],
        apellido1: d[1],
        apellido2: d[2],
        genero: d[3],
        email: '${d[0].toLowerCase()}.${d[1].toLowerCase()}@ejemplo.com',
        telefono: '98312${(10000 + i).toString()}',
        telReferencia: null,
        tipoZona: d[4],
        carrera: d[5],
        modalidad: d[6],
        preparatoria: d[7],
        medioEnterado: d[8],
        status: d[9],
        nota: 'Registro de demostración',
        // Fechas escalonadas para variar la antigüedad en el dashboard.
        createdAt: ahora.subtract(Duration(days: i)).toIso8601String(),
        updatedAt: ahora.subtract(Duration(days: i)).toIso8601String(),
      );
      batch.insert('prospectos', prospecto.toMap());
    }

    await batch.commit(noResult: true);
  }
}
