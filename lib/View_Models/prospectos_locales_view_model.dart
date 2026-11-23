import 'package:flutter/material.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/Services/formulario_service.dart';
import 'package:nexxus/Services/exportar_service.dart';
import 'package:nexxus/Services/api_service.dart';

class ProspectosLocalesViewModel extends ChangeNotifier {
  List<Prospecto> _prospectos = [];
  bool _cargando = false;

  List<Prospecto> get prospectos => _prospectos;
  bool get cargando => _cargando;

  // [NUEVO]: Lista de aspirantes que siguen en "Local (pendientes)"
  List<Prospecto> get prospectosLocales =>
      _prospectos.where((p) => p.status != 'sincronizado').toList();

  // [NUEVO]: Lista de aspirantes que ya están "En la nube" (sincronizados)
  List<Prospecto> get prospectosEnLaNube =>
      _prospectos.where((p) => p.status == 'sincronizado').toList();

  Future<void> cargarProspectos() async {
    _cargando = true;
    notifyListeners();
    try {
      _prospectos = await FormularioService.instancia.obtenerProspectos();
    } catch (e) {
      debugPrint("Error al cargar prospectos: $e");
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarProspecto(int id) async {
    try {
      final resultado = await FormularioService.instancia.eliminarProspecto(id);
      if (resultado > 0) {
        _prospectos.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error al eliminar prospecto: $e");
    }
    return false;
  }

  // Obtiene los datos formateados para la tabla del modal de Vista Previa
  List<List<dynamic>> obtenerDatosVistaPrevia([List<Prospecto>? listaFiltrada]) {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return [];
    return ExportarService.instancia.obtenerDatosVistaPrevia(lista);
  }

  // Exporta a CSV
  Future<void> exportarCSV([List<Prospecto>? listaFiltrada]) async {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return;
    await ExportarService.instancia.exportarCSV(lista);
  }

  // Exporta a Excel (.xlsx)
  Future<void> exportarExcel([List<Prospecto>? listaFiltrada]) async {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return;
    await ExportarService.instancia.exportarExcel(lista);
  }

  // Exporta a PDF (.pdf)
  Future<void> exportarPDF([List<Prospecto>? listaFiltrada]) async {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return;
    await ExportarService.instancia.exportarPDF(lista);
  }

  // [MODIFICADO]: Sincroniza los prospectos pendientes con el CRM.
  // Cuando se suben (o se omiten por estar ya en el CRM), pasan automáticamente
  // del grupo "Local (pendientes)" al grupo "En la nube".
  Future subirNexxus() async {
    final pendientesParaSubir = List<Prospecto>.from(prospectosLocales);
    if (pendientesParaSubir.isEmpty) {
      return {'exitos': 0, 'duplicados': 0, 'fallos': 0};
    }

    _cargando = true;
    notifyListeners();

    int exitos = 0;
    int duplicados = 0;
    int fallos = 0;

    try {
      for (final p in pendientesParaSubir) {
        final estado = await ApiService.instancia.enviarSolicitud(p);

        if (estado == 'creado' || estado == 'duplicado') {
          if (estado == 'creado') {
            exitos++;
          } else {
            duplicados++;
          }

          // Actualizamos en SQLite y en memoria para que se mueva al grupo "En la nube"
          if (p.id != null) {
            await FormularioService.instancia.marcarComoSincronizado(p.id!);
          }
          p.status = 'sincronizado';
          p.updatedAt = DateTime.now().toIso8601String();
        } else {
          fallos++;
        }
      }
      return {'exitos': exitos, 'duplicados': duplicados, 'fallos': fallos};
    } catch (e) {
      debugPrint("Error en subirNexxus: $e");
      return {
        'exitos': exitos,
        'duplicados': duplicados,
        'fallos': pendientesParaSubir.length,
      };
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}