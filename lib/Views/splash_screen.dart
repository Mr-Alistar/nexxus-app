import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'inicio_screen.dart';
import 'package:nexxus/Services/carrera_service.dart';

//Splash Screen con animaciones y sincronizacion inicial
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0; // Controlamos la opacidad directamente aquí
  String statusSync = ""; // Mensaje de estado de la sincronización
  bool? exitoSync; // null: pendiente, true: éxito, false: fallo
  final String versionApp = "1.0.0"; // esto se va moviendo de acuerdo a como van metiendole cambios

  @override
  void initState() {
    super.initState();
    _iniciarApp();
  }

  // animación y la sincronización inicial
  Future<void> _iniciarApp() async {
    //esto sirve para esperar a que el motor de flutter se inicialice para evitar errores de viewport
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => opacity = 1.0);

    // Se ejecuta la sincronización y se espera el resultado
    // await para que  statusSync tenga valor antes de continuar
    await _sincronizarDatos();

    // Mantener el mensaje de sincronización visible por 5 segundos, ustedes le pueden cambiar el tiempo
    // se cuentan los segundos después de que el mensaje de sincronización con el CRM Nexxus (verde o rojo) aparece
    await Future.delayed(const Duration(seconds: 5));
    
    if (!mounted) return;
    setState(() => opacity = 0.0);

    // tiempo de espera antes de ir al inicio
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _navegarAInicio();
  }

  // Metodo para sincronizar datos de la API y actualizar el estado visual
  Future<void> _sincronizarDatos() async {
    try {
      final carreraService = CarreraService();
      final resultado = await carreraService.sincronizarCarreras();
      
      if (mounted) {
        setState(() {
          exitoSync = resultado;
          statusSync = resultado 
              ? "Sincronización exitosa con CRM Nexxus" 
              : "Error al sincronizar datos (Verifique su conexión)";
        });
      }
    } catch (e) {
      debugPrint("Sincronización inicial fallida: $e");
      if (mounted) {
        setState(() {
          exitoSync = false;
          statusSync = "Sin conexión: Se utilizarán datos locales";
        });
      }
    }
  }

  void _navegarAInicio() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secondAnim) => const InicioScreen(),
        transitionsBuilder: (context, anim, secondAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Animación del Logonexxus
                AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  child: SvgPicture.asset(
                    'Assets/Generales/logonexxusverde.svg',
                    width: 300,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                //Animación del Texto
                AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Text(
                        'Versión $versionApp',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // barra de estado de sincronización (snackbar)
          if (statusSync.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: exitoSync == true ? const Color(0xFF14A38E) : Colors.red,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        exitoSync == true ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          statusSync,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
