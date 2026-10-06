import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nexxus/Models/carrera_model.dart';
import 'package:nexxus/Services/formulario_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Este servicio se encarga de la sincronización de datos de carreras e imagenes entre el servidor y la base de datos local.
class CarreraService {
  final Dio _dio = Dio();
  final String _urlApi = 'https://nexxusapi.datacode.space/apis/api_carreras.php';

  // Lista de carreras conocidas para sincronizar (agregar o quitar dependiendo de las carreras activas en la UT)
  //utilice las siglas para no escribir nombres largo, ejemplo G de Gastronomía.
  final List<String> _carrerasSincronizar = ['G', 'DIA', 'IM', 'IF', 'TIID', 'NM'];

  // datos de respaldo (Fallback, último recurso) en caso de que no haya internet ni datos en BD local (instalación nueva).
  final Map<String, CarreraModel> datosFallback = {
    //Esta información es inventada, solo aparecerá en caso de tener la app recién instalada y nunca haberla ejecutado con conexión a internet.
    'G': CarreraModel(
      siglas: 'G',
      nombre: 'Gastronomía',
      acercaDe: 'La carrera de Gastronomía forma profesionales capaces de rescatar la cultura culinaria e innovar en la preparación de alimentos.',
      planEstudios: 'Enfoque en técnicas culinarias, gestión de alimentos y bebidas, y cultura gastronómica.',
      modalidad: 'Escolarizada',
      urlImagenes: '',
    ),
    'DIA': CarreraModel(
      siglas: 'DIA',
      nombre: 'Datos e Inteligencia Artificial',
      acercaDe: 'Formación en algoritmos, machine learning y procesamiento de grandes volúmenes de datos.',
      planEstudios: 'Estudio de redes neuronales, bases de datos avanzadas y analítica predictiva.',
      modalidad: 'Escolarizada',
      urlImagenes: '',
    ),
    'IM': CarreraModel(
      siglas: 'IM',
      nombre: 'Ingeniería en Mecatrónica',
      acercaDe: 'Preparación en la automatización de sistemas industriales mediante la integración de mecánica y electrónica.',
      planEstudios: 'Combina mecánica, electrónica y sistemas computacionales para el diseño de productos.',
      modalidad: 'Escolarizada',
      urlImagenes: '',
    ),
    'IF': CarreraModel(
      siglas: 'IF',
      nombre: 'Ingeniería Financiera',
      acercaDe: 'Análisis de mercados, gestión de riesgos y optimización de recursos financieros.',
      planEstudios: 'Econometría, finanzas corporativas y modelos matemáticos de inversión.',
      modalidad: 'Escolarizada',
      urlImagenes: '',
    ),
    'TIID': CarreraModel(
      siglas: 'TIID',
      nombre: 'Tecnologías de la Información e Innovación Digital',
      acercaDe: 'Desarrollo de soluciones tecnológicas innovadoras para la era digital.',
      planEstudios: 'Programación web, ciberseguridad y transformación digital.',
      modalidad: 'Escolarizada',
      urlImagenes: '',
    ),
    'NM': CarreraModel(
      siglas: 'NM',
      nombre: 'Negocios y Mercadotecnia',
      acercaDe: 'Estrategias de mercado, comportamiento del consumidor y gestión comercial.',
      planEstudios: 'Marketing digital, investigación de mercados y administración de ventas.',
      modalidad: 'Escolarizada',
      urlImagenes: '',
    ),
  };

  // Metodo principal que coordina la descarga de información y de imágenes para cada carrera.
  // Retorna true si se sincronizaron todas las carreras exitosamente.
  Future<bool> sincronizarCarreras() async {
    // sincronizacion en paralelo
    List<Future<bool>> tareas = _carrerasSincronizar.map((siglas) async {
      try {
        final response = await _dio.get(
          _urlApi,
          queryParameters: {'carrera': siglas},
        ).timeout(const Duration(seconds: 10));//10 segundos es el tiempo maximo de espera, le pueden aumentar ustedes

        if (response.statusCode == 200 && response.data != null) {
          Map<String, dynamic> data = response.data;
          
          // descargar imagenes y guardar en BD local
          String rutasLocales = await _descargarImagenesCarrera(siglas, data['url_imagenes'] ?? '');
          final carrera = CarreraModel.fromMap(data);
          await _guardarCarreraLocal(carrera, rutasLocales);
          return true;
        }
        return false;
      } catch (e) {
        debugPrint("Error al sincronizar carrera $siglas: $e");
        return false;
      }
    }).toList();

    final resultados = await Future.wait(tareas);
    // Si alguna carrera falló em descargarse, es false
    return !resultados.contains(false);
  }

  // Descarga los archivos de imagen y los guarda en el almacenamiento interno del dispositivo.
  Future<String> _descargarImagenesCarrera(String siglas, String urlImagenes) async {
    if (urlImagenes.isEmpty) return '';
    
    List<String> listaUrls = [];
    List<String> rutasGuardadas = [];
    
    // Usamos la lógica de procesamiento para identificar qué descargar. esto se basa en la tabla que hice para las carreras
    final carreraTemporal = CarreraModel(
      siglas: siglas, 
      nombre: '', acercaDe: '', planEstudios: '', modalidad: '', 
      urlImagenes: urlImagenes
    );
    listaUrls = carreraTemporal.obtenerListaFotos();

    if (listaUrls.isEmpty) return '';

    try {
      final directorioApp = await getApplicationDocumentsDirectory();
      final carpetaCarrera = Directory(p.join(directorioApp.path, 'Carreras', siglas));
      
      if (!await carpetaCarrera.exists()) {
        await carpetaCarrera.create(recursive: true);
      }

      for (int i = 0; i < listaUrls.length; i++) {
        String url = listaUrls[i];
        String extension = p.extension(url).split('?').first;
        if (extension.isEmpty) extension = '.jpg';
        
        String nombreArchivo = '${siglas}_$i$extension';
        String rutaArchivoLocal = p.join(carpetaCarrera.path, nombreArchivo);
        
        await _dio.download(url, rutaArchivoLocal);
        rutasGuardadas.add(rutaArchivoLocal);
      }
      
      return rutasGuardadas.join(',');
    } catch (e) {
      debugPrint("Error al descargar imágenes de $siglas: $e");
      return '';
    }
  }

  // para actualizar el registro de la carrera en SQLite, o insertar tmb
  Future<void> _guardarCarreraLocal(CarreraModel carrera, String rutasLocales) async {
    final db = await FormularioService.instancia.database;
    final map = carrera.toMap();
    map['rutas_locales'] = rutasLocales; // Aseguramos que se guardan las rutas locales en la BD.

    await db.insert(
      'carreras',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtiene los datos de una carrera, tiene prioridad la base de datos o de lo contrario se usa el fallback (ultima opcion)
  Future<CarreraModel> obtenerCarrera(String siglas) async {
    final db = await FormularioService.instancia.database;
    final maps = await db.query(
      'carreras',
      where: 'siglas = ?',
      whereArgs: [siglas],
    );

    if (maps.isNotEmpty) {
      return CarreraModel.fromMap(maps.first);
    }
    
    // Si no se encuentra en BD, se ysa el fallback hardcodeado.
    return datosFallback[siglas] ?? CarreraModel(
      siglas: siglas, 
      nombre: siglas, 
      acercaDe: 'Información no disponible.', 
      planEstudios: 'Información no disponible.', 
      modalidad: '', 
      urlImagenes: ''
    );
  }
}
