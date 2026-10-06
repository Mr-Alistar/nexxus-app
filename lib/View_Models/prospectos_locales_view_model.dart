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

  Future<void> exportarCSV() async {
    if (_prospectos.isEmpty) return;
    await ExportarService.instancia.exportarCSV(_prospectos);
  }

  Future<void> exportarExcel() async {
    if (_prospectos.isEmpty) return;
    await ExportarService.instancia.exportarExcel(_prospectos);
  }

  Future<Map<String, int>> subirNexxus() async {
    if (_prospectos.isEmpty) return {'exitos': 0, 'fallos': 0};

    _cargando = true;
    notifyListeners();

    try {
      final resultados = await ApiService.instancia.subirVariosProspectos(_prospectos);
      return resultados;
    } catch (e) {
      debugPrint("Error en subirNexxus: $e");
      return {'exitos': 0, 'fallos': _prospectos.length};
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
