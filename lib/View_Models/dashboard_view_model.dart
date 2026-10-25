import 'package:flutter/material.dart';
import 'package:nexxus/Services/formulario_service.dart';

// ViewModel para la gestión del Dashboard y sus estadísticas en tiempo real
class DashboardViewModel extends ChangeNotifier {
  int _indiceActual = 0;
  int get indiceActual => _indiceActual;

  // Variables para las estadísticas del Dashboard
  int _totalProspectos = 0;
  int _sinContacto = 0;
  bool _cargandoStats = false;

  // Getters para exponer las estadísticas a la vista de inicio
  int get totalProspectos => _totalProspectos;
  int get sinContacto => _sinContacto;
  bool get cargandoStats => _cargandoStats;

  DashboardViewModel() {
    // Cargar estadísticas al iniciar
    cargarEstadisticas();
  }

  // Cambia el índice de la "tab" seleccionada y notifica a la vista.
  void cambiarIndice(int nuevoIndice) {
    if (nuevoIndice != _indiceActual) {
      _indiceActual = nuevoIndice;
      // Si regresa a la pestaña de inicio (0), refrescamos las estadísticas
      if (nuevoIndice == 0) {
        cargarEstadisticas();
      }
      notifyListeners();
    }
  }

  // Método para consultar la base de datos local y actualizar métricas
  Future<void> cargarEstadisticas() async {
    _cargandoStats = true;
    notifyListeners();

    try {
      _totalProspectos = await FormularioService.instancia.contarProspectos();
      _sinContacto = await FormularioService.instancia.contarProspectosPorStatus('sin-contacto');
    } catch (e) {
      // Manejo silencioso en caso de error de BD
      _totalProspectos = 0;
      _sinContacto = 0;
    }

    _cargandoStats = false;
    notifyListeners();
  }
}