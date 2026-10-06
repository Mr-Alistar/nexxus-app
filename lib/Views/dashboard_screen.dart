import 'package:flutter/material.dart';
import 'package:nexxus/View_Models/dashboard_view_model.dart';
import 'package:nexxus/Views/prospectos_locales_screen.dart';
import 'package:nexxus/Views/inicio_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardViewModel _viewModel = DashboardViewModel();

  // Modal de confirmacion para cerrar sesion. No lo saca de la app, solo cerrara y regresara a la pantalla de inicio
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
              Navigator.pop(context); // Cierra el modal, porque eligió NO
              // Ir a la pantalla de inicio
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const InicioScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A38E)),
            child: const Text("Sí", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _viewModel.indiceActual,
            children: [
              // Tab Inicio
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard, size: 80, color: Color(0xFF14A38E)),
                    SizedBox(height: 10),
                    Text("Panel administrativo", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Estadísticas generales"),
                  ],
                ),
              ),
              // Tab Reportes - pendiente
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.developer_board, size: 80, color: Color(0xFF14A38E)),
                    SizedBox(height: 10),
                    Text("Reportes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Resultados obtenidos"),
                  ],
                ),
              ),
              // Tab Prospectos (SQL interno)
              const ProspectosLocalesScreen(),
              // Tab Salir/cerrar sesión
              const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _viewModel.indiceActual,
            onTap: (index) {
              if (index == 3) {
                _confirmarCerrarSesion(context);
              } else {
                _viewModel.cambiarIndice(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF14A38E),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
              BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Reportes"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Registrados"),
              BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: "Salir"),
            ],
          ),
        );
      },
    );
  }
}
