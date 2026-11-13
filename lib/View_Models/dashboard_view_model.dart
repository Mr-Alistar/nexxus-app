import 'package:flutter/material.dart';
import 'package:nexxus/Models/dashboard_model.dart';
import 'package:nexxus/Services/api_service.dart';
import 'package:nexxus/Services/auth_session.dart';
import 'package:nexxus/Services/formulario_service.dart';

// ViewModel para la gestión del Dashboard y sus estadísticas.
// - Métricas del CRM (por rol): vienen del endpoint GET /api/dashboard.
// - Fichas locales por subir: vienen de SQLite (funciona sin internet).
class DashboardViewModel extends ChangeNotifier {
  int _indiceActual = 0;
  int get indiceActual => _indiceActual;

  // --- Datos locales (SQLite) ---
  int _totalLocal = 0;
  bool _cargandoStats = false;

  // --- Datos del CRM (endpoint) ---
  DashboardData? _datos;
  bool _cargandoCrm = false;
  bool _errorCrm = false;

  int get totalLocal => _totalLocal;
  bool get cargandoStats => _cargandoStats;

  DashboardData? get datos => _datos;
  bool get cargandoCrm => _cargandoCrm;
  bool get errorCrm => _errorCrm;

  // Total del CRM si hay datos; si no, cae al conteo local.
  int get totalProspectos => _datos?.totalProspectos ?? _totalLocal;

  // Fichas capturadas localmente.
  // Provisional: asume que lo que hay en SQLite está pendiente de subir.
  int get porSubir => _totalLocal;

  // Nombre para el saludo: endpoint > sesión de login > genérico.
  String get nombreUsuario {
    final delCrm = _datos?.nombreUsuario ?? '';
    if (delCrm.isNotEmpty) return delCrm;
    final delLogin = AuthSession.instancia.usuario?['nombre']?.toString() ?? '';
    return delLogin.isNotEmpty ? delLogin : 'Asesor';
  }

  DashboardViewModel() {
    cargarTodo();
  }

  // Cambia el índice de la "tab" seleccionada y notifica a la vista.
  void cambiarIndice(int nuevoIndice) {
    if (nuevoIndice != _indiceActual) {
      _indiceActual = nuevoIndice;
      // Si regresa a la pestaña de inicio (0), refrescamos todo.
      if (nuevoIndice == 0) {
        cargarTodo();
      }
      notifyListeners();
    }
  }

  // Carga en paralelo los datos locales y los del CRM.
  Future<void> cargarTodo() async {
    await Future.wait([cargarEstadisticas(), cargarDashboardCrm()]);
  }

  // Conteo local (SQLite).
  Future<void> cargarEstadisticas() async {
    _cargandoStats = true;
    notifyListeners();

    try {
      _totalLocal = await FormularioService.instancia.contarProspectos();
    } catch (e) {
      // Manejo silencioso en caso de error de BD
      _totalLocal = 0;
    }

    _cargandoStats = false;
    notifyListeners();
  }

  // Métricas del CRM. Si falla (sin internet / sin sesión), conserva los
  // últimos datos válidos y marca el error para que la vista lo indique.
  Future<void> cargarDashboardCrm() async {
    _cargandoCrm = true;
    _errorCrm = false;
    notifyListeners();

    final resultado = await ApiService.instancia.obtenerDashboard();
    if (resultado != null) {
      _datos = resultado;
    } else {
      _errorCrm = true;
    }

    _cargandoCrm = false;
    notifyListeners();
  }
}