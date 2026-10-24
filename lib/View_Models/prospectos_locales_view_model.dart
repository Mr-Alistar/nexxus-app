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

  List<List<dynamic>> obtenerDatosVistaPrevia([List<Prospecto>? listaFiltrada]) {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return [];
    return ExportarService.instancia.obtenerDatosVistaPrevia(lista);
  }

  Future<void> exportarCSV([List<Prospecto>? listaFiltrada]) async {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return;
    await ExportarService.instancia.exportarCSV(lista);
  }

  Future<void> exportarExcel([List<Prospecto>? listaFiltrada]) async {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return;
    await ExportarService.instancia.exportarExcel(lista);
  }

  Future<void> exportarPDF([List<Prospecto>? listaFiltrada]) async {
    final lista = listaFiltrada ?? _prospectos;
    if (lista.isEmpty) return;
    await ExportarService.instancia.exportarPDF(lista);
  }

  // [MODIFICADO]: Ahora distingue entre registros nuevos ('creado'),
  // omitidos por existir ya en el CRM ('duplicado') y errores de red ('error').
  Future<Map<String, int>> subirNexxus() async {
    if (_prospectos.isEmpty) {
      return {'exitos': 0, 'duplicados': 0, 'fallos': 0};
    }

    _cargando = true;
    notifyListeners();

    int exitos = 0;
    int duplicados = 0;
    int fallos = 0;

    try {
      final copiaProspectos = List<Prospecto>.from(_prospectos);

      for (final p in copiaProspectos) {
        final estado = await ApiService.instancia.enviarSolicitud(p);

        if (estado == 'creado' || estado == 'duplicado') {
          if (estado == 'creado') {
            exitos++;
          } else {
            duplicados++;
          }

          // [IMPORTANTE]: Tanto si se creó como si ya existía en el CRM (duplicado),
          // lo quitamos de la base de datos local SQLite porque ya está en el servidor.
          if (p.id != null) {
            await FormularioService.instancia.eliminarProspecto(p.id!);
            _prospectos.removeWhere((item) => item.id == p.id);
          }
        } else {
          // Si hubo un error de conexión, se conserva en SQLite para no perderlo
          fallos++;
        }
      }
      return {'exitos': exitos, 'duplicados': duplicados, 'fallos': fallos};
    } catch (e) {
      debugPrint("Error en subirNexxus: $e");
      return {
        'exitos': exitos,
        'duplicados': duplicados,
        'fallos': _prospectos.length,
      };
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}