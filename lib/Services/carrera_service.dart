import 'package:nexxus/Models/carrera_model.dart';
import 'package:nexxus/Services/formulario_service.dart';

// Servicio de carreras. La sincronización remota con el servidor se retiró:
// la app usa la información local empaquetada (datosFallback) y las imágenes
// incluidas en Assets. Si en el futuro el CRM expone un endpoint de carreras,
// aquí se podría volver a agregar la descarga.
class CarreraService {
  // Lista de carreras conocidas (siglas usadas por el mapa y las pantallas).
  final List<String> carrerasConocidas = ['G', 'DIA', 'IM', 'IF', 'TIID', 'NM'];

  // Información local de cada carrera (siglas -> datos).
  final Map<String, CarreraModel> datosFallback = {
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

  // Obtiene los datos de una carrera. Si existe un registro local en SQLite lo
  // usa; de lo contrario recurre a la información empaquetada (datosFallback).
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

    return datosFallback[siglas] ??
        CarreraModel(
          siglas: siglas,
          nombre: siglas,
          acercaDe: 'Información no disponible.',
          planEstudios: 'Información no disponible.',
          modalidad: '',
          urlImagenes: '',
        );
  }
}
