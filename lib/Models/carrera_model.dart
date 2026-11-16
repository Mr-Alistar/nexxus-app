// Modelo carrera
class CarreraModel {
  final String siglas;
  final String nombre;
  final String acercaDe;
  final String planEstudios;
  final String modalidad;
  final String urlImagenes;
  final String rutasLocales;

  CarreraModel({
    required this.siglas,
    required this.nombre,
    required this.acercaDe,
    required this.planEstudios,
    required this.modalidad,
    required this.urlImagenes,
    this.rutasLocales = '',
  });

  // Crea una instancia del modelo (JSON de API o registro de SQLite) - mapeo
  factory CarreraModel.fromMap(Map<String, dynamic> map) {
    return CarreraModel(
      siglas: map['siglas'] ?? '',
      nombre: map['nombre'] ?? '',
      acercaDe: map['acerca_de'] ?? map['acercaDe'] ?? '',
      planEstudios: map['plan_estudios'] ?? map['planEstudios'] ?? '',
      modalidad: map['modalidad'] ?? '',
      urlImagenes: map['url_imagenes'] ?? map['urlImagenes'] ?? '',
      rutasLocales: map['rutas_locales'] ?? '',
    );
  }

  // Convierte el objeto a un Mapa para su almacenamiento en SQLite.
  Map<String, dynamic> toMap() {
    return {
      'siglas': siglas,
      'nombre': nombre,
      'acerca_de': acercaDe,
      'plan_estudios': planEstudios,
      'modalidad': modalidad,
      'url_imagenes': urlImagenes,
      'rutas_locales': rutasLocales,
    };
  }

  // para procesar las rutas (locales o remotas) y devuelve una lista de imagenes.
  List<String> obtenerListaFotos() {
    List<String> fotos = [];

    // Prioridad: fotos descargadas en el dispositivo
    if (rutasLocales.isNotEmpty) {
      fotos = rutasLocales.split(',').where((s) => s.isNotEmpty).toList();
      if (fotos.isNotEmpty) return fotos;
    }

    // Si lo anterior falla, segunda opcion: procesar cadena de la API. Aquí toca compartirles mi db de pruebas para que se guíen.
    if (urlImagenes.isNotEmpty) {
      List<String> partes = urlImagenes.split(',');
      if (partes.length > 1) {
        String base = partes[0].trim();
        if (!base.startsWith('http')) base = 'https://$base';
        if (!base.endsWith('/')) base = '$base/';

        for (int i = 1; i < partes.length; i++) {
          String archivo = partes[i].trim();
          if (archivo.isNotEmpty) {
            if (archivo.startsWith('/')) archivo = archivo.substring(1);
            fotos.add(base + archivo);
          }
        }
      } else if (partes.length == 1 && urlImagenes.startsWith('http')) {
        fotos.add(urlImagenes);
      }
    }

    return fotos;
  }
}
