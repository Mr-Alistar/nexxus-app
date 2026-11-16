import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'inicio_screen.dart';

//Splash Screen con animaciones de arranque
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0; // Controlamos la opacidad directamente aquí
  final String versionApp = "1.0.0"; // esto se va moviendo de acuerdo a como van metiendole cambios

  @override
  void initState() {
    super.initState();
    _iniciarApp();
  }

  // Animación de arranque y navegación al inicio.
  Future<void> _iniciarApp() async {
    //esto sirve para esperar a que el motor de flutter se inicialice para evitar errores de viewport
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => opacity = 1.0);

    // Tiempo que el logo permanece visible (ajustable).
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => opacity = 0.0);

    // tiempo de espera antes de ir al inicio
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _navegarAInicio();
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
        ],
      ),
    );
  }
}
