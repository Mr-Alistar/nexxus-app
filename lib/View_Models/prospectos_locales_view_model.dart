import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/Services/formulario_service.dart';
import 'package:nexxus/Services/exportar_service.dart';
import 'package:nexxus/Services/api_service.dart';

class ProspectosLocalesViewModel extends ChangeNotifier {
  // [NUEVO]: Clave donde se guarda el registro de qué prospectos ya fueron
  // sincronizados con el CRM y en qué fecha (id del prospecto -> milisegundos).
  static const String _claveSincronizados = 'prospectos_sincronizados';

  // [NUEVO]: Tiempo que un prospecto ya sincronizado se conserva en el móvil
  // antes de eliminarse automáticamente.
  static const Duration _tiempoRetencion = Duration(days: 7);

  List<Prospecto> _prospectos = [];
  bool _cargando = false;

  // [NUEVO]: id del prospecto -> fecha de sincronización (ms desde epoch)
  Map<int, int> _sincronizados = {};

  List<Prospecto> get prospectos => _prospectos;
  bool get cargando => _cargando;
  // [NUEVO]: Prospectos que todavía NO se han subido al CRM.
  List<Prospecto> get pendientes =>
      _prospectos.where((p) => !esSincronizado(p.id)).toList();

  // [NUEVO]: Indica si un prospecto ya fue sincronizado con el CRM.
  bool esSincronizado(int? id) => id != null && _sincronizados.containsKey(id);

  // [NUEVO]: Fecha en la que el prospecto se sincronizó (null si está pendiente).
  DateTime? fechaSincronizacion(int? id) {
    if (id == null) return null;
    final ms = _sincronizados[id];
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  // [NUEVO]: Fecha en la que el prospecto sincronizado se eliminará del móvil.
  DateTime? fechaEliminacion(int? id) {
    final fecha = fechaSincronizacion(id);
    if (fecha == null) return null;
    return fecha.add(_tiempoRetencion);
  }

  // ---------------------------------------------------------------------------
  // [NUEVO]: Persistencia del registro de sincronizados
  // ---------------------------------------------------------------------------

  Future<void> _leerSincronizados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_claveSincronizados);

      if (raw == null || raw.isEmpty) {
        _sincronizados = {};
        return;
      }

      final decodificado = jsonDecode(raw) as Map<String, dynamic>;
      _sincronizados = decodificado.map(
            (clave, valor) => MapEntry(int.parse(clave), (valor as num).toInt()),
      );
    } catch (e) {
      debugPrint("Error al leer prospectos sincronizados: $e");
      _sincronizados = {};
    }
  }

  Future<void> _guardarSincronizados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapa = _sincronizados.map(
            (clave, valor) => MapEntry(clave.toString(), valor),
      );
      await prefs.setString(_claveSincronizados, jsonEncode(mapa));
    } catch (e) {
      debugPrint("Error al guardar prospectos sincronizados: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // [NUEVO]: Limpieza automática de prospectos sincronizados hace 7 días o más
  // ---------------------------------------------------------------------------

  Future<void> _eliminarSincronizadosVencidos() async {
    if (_sincronizados.isEmpty) return;

    final limite =
        DateTime.now().subtract(_tiempoRetencion).millisecondsSinceEpoch;

    final vencidos = _sincronizados.entries
        .where((entrada) => entrada.value <= limite)
        .map((entrada) => entrada.key)
        .toList();

    if (vencidos.isEmpty) return;

    for (final id in vencidos) {
      try {
        await FormularioService.instancia.eliminarProspecto(id);
        _sincronizados.remove(id);
      } catch (e) {
        // Si falla, se conserva en el registro y se reintenta en la siguiente carga.
        debugPrint("Error al eliminar prospecto vencido $id: $e");
      }
    }

    await _guardarSincronizados();
  }

  // [NUEVO]: Quita del registro los ids que ya no existen en SQLite
  // (por ejemplo, si se eliminaron por otra vía) para evitar datos huérfanos.
  Future<void> _depurarSincronizadosHuerfanos() async {
    if (_sincronizados.isEmpty) return;

    final idsExistentes =
    _prospectos.where((p) => p.id != null).map((p) => p.id!).toSet();

    final cantidadAntes = _sincronizados.length;
    _sincronizados.removeWhere((id, _) => !idsExistentes.contains(id));

    if (_sincronizados.length != cantidadAntes) {
      await _guardarSincronizados();
    }
  }

  // [MODIFICADO]: Antes de cargar la lista, lee el registro de sincronizados y
  // elimina los que ya cumplieron 1 semana desde que se subieron al CRM.
  Future<void> cargarProspectos() async {
    _cargando = true;
    notifyListeners();
    try {
      await _leerSincronizados();
      await _eliminarSincronizadosVencidos();
      _prospectos = await FormularioService.instancia.obtenerProspectos();
      await _depurarSincronizadosHuerfanos();
    } catch (e) {
      debugPrint("Error al cargar prospectos: $e");
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // [MODIFICADO]: Si el prospecto se elimina manualmente, también se quita
  // del registro de sincronizados.
  Future<bool> eliminarProspecto(int id) async {
    try {
      final resultado = await FormularioService.instancia.eliminarProspecto(id);
      if (resultado > 0) {
        _prospectos.removeWhere((p) => p.id == id);
        if (_sincronizados.remove(id) != null) {
          await _guardarSincronizados();
        }
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

  // [MODIFICADO]: Distingue entre registros nuevos ('creado'), omitidos por
  // existir ya en el CRM ('duplicado') y errores de red ('error').
  // Ahora los prospectos sincronizados YA NO se borran de SQLite: se marcan
  // con la fecha de sincronización y se eliminan automáticamente a los 7 días.
  // Además, solo se suben los pendientes, para no reenviar los ya sincronizados.
  Future<Map<String, int>> subirNexxus() async {
    final porSubir = pendientes;

    if (porSubir.isEmpty) {
      return {'exitos': 0, 'duplicados': 0, 'fallos': 0};
    }

    _cargando = true;
    notifyListeners();

    int exitos = 0;
    int duplicados = 0;
    int fallos = 0;

    try {
      for (final p in porSubir) {
        final estado = await ApiService.instancia.enviarSolicitud(p);

        if (estado == 'creado' || estado == 'duplicado') {
          if (estado == 'creado') {
            exitos++;
          } else {
            duplicados++;
          }

          // [IMPORTANTE]: Tanto si se creó como si ya existía en el CRM (duplicado),
          // se conserva en SQLite y solo se marca como sincronizado con la fecha
          // actual. Se guarda en cada registro para no perder el avance si la
          // app se cierra a mitad de la subida.
          if (p.id != null) {
            _sincronizados[p.id!] = DateTime.now().millisecondsSinceEpoch;
            await _guardarSincronizados();
          }
        } else {
          // Si hubo un error de conexión, se conserva como pendiente para
          // reintentarlo en la siguiente subida.
          fallos++;
        }
      }
      return {'exitos': exitos, 'duplicados': duplicados, 'fallos': fallos};
    } catch (e) {
      debugPrint("Error en subirNexxus: $e");
      return {
        'exitos': exitos,
        'duplicados': duplicados,
        'fallos': pendientes.length,
      };
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}