import 'package:flutter/material.dart';
import 'package:nexxus/View_Models/dashboard_view_model.dart';
import 'package:nexxus/Views/prospectos_locales_screen.dart';
import 'package:nexxus/Views/inicio_dashboard_screen.dart';
import 'package:nexxus/Views/inicio_screen.dart';
import 'package:nexxus/Services/auth_session.dart';
import 'package:nexxus/Services/formulario_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Paleta del rediseño
  static const _teal700 = Color(0xFF0F766E);

  final DashboardViewModel _viewModel = DashboardViewModel();

  // Número de prospectos locales (para el badge del tab "Registrados").
  int _conteoLocal = 0;

  @override
  void initState() {
    super.initState();
    _actualizarConteo();
  }

  Future<void> _actualizarConteo() async {
    try {
      final lista = await FormularioService.instancia.obtenerProspectos();
      if (mounted) setState(() => _conteoLocal = lista.length);
    } catch (_) {
      // Si la BD aún no está lista, el badge simplemente queda en 0.
    }
  }

  // Modal de confirmacion para cerrar sesion.
  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Desea cerrar la sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el modal
              AuthSession.instancia.cerrarSesion(); // Limpia el token del asesor
              // Ir a la pantalla de inicio
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const InicioScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _teal700),
            child: const Text("Sí", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _alCambiarTab(int index) {
    // Índices: 0 = Inicio, 1 = Registrados, 2 = Salir
    if (index == 2) {
      _confirmarCerrarSesion(context);
    } else {
      _viewModel.cambiarIndice(index);
      // Al volver a "Registrados" refrescamos el conteo del badge.
      if (index == 1) _actualizarConteo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F5F5),
          body: IndexedStack(
            index: _viewModel.indiceActual,
            children: [
              // Tab Inicio (dashboard de estadísticas — solo vista)
              InicioDashboardScreen(viewModel: _viewModel),
              // Tab Registrados (SQL interno)
              ProspectosLocalesScreen(
                onIrInicio: () => _viewModel.cambiarIndice(0),
              ),
              // Tab Salir/cerrar sesión
              const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: _BarraNavegacion(
            indiceActual: _viewModel.indiceActual,
            badgeRegistrados: _conteoLocal,
            onTap: _alCambiarTab,
          ),
        );
      },
    );
  }
}

// ====== Barra de navegación inferior (Material You) ======
class _BarraNavegacion extends StatelessWidget {
  final int indiceActual;
  final int badgeRegistrados;
  final ValueChanged<int> onTap;

  const _BarraNavegacion({
    required this.indiceActual,
    required this.badgeRegistrados,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ItemNav(
                icono: Icons.home_outlined,
                iconoActivo: Icons.home,
                etiqueta: "Inicio",
                activo: indiceActual == 0,
                onTap: () => onTap(0),
              ),
              _ItemNav(
                icono: Icons.how_to_reg_outlined,
                iconoActivo: Icons.how_to_reg,
                etiqueta: "Registrados",
                activo: indiceActual == 1,
                badge: badgeRegistrados,
                onTap: () => onTap(1),
              ),
              _ItemNav(
                icono: Icons.logout,
                iconoActivo: Icons.logout,
                etiqueta: "Salir",
                activo: false,
                colorInactivo: const Color(0xFF64748B),
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
  final bool activo;
  final int badge;
  final Color colorInactivo;
  final VoidCallback onTap;

  const _ItemNav({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
    required this.activo,
    this.badge = 0,
    this.colorInactivo = const Color(0xFF64748B),
    required this.onTap,
  });

  static const _teal700 = Color(0xFF0F766E);
  static const _teal900 = Color(0xFF134E4A);
  static const _amber500 = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final color = activo ? _teal900 : colorInactivo;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: activo ? 56 : 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: activo ? _teal700 : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    activo ? iconoActivo : icono,
                    size: 21,
                    color: activo ? Colors.white : color,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _amber500,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge > 99 ? "99+" : "$badge",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 11,
                fontWeight: activo ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

