import 'package:flutter/material.dart';
import 'package:nexxus/Views/formulario_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';
import 'package:nexxus/Views/mapa_screen.dart';
import 'login_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Logo
                    SvgPicture.asset(
                      'Assets/Generales/logonexxusverde.svg',
                      width: 300,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    // Texto Bienvenido
                    const Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "CRM Nexxus versión móvil - UT Chetumal",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Seccion AspiranteS
                    lineaDivisoria("Aspirantes"),
                    const SizedBox(height: 15),
                    botonesVerdes("Formulario", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FormularioScreen()),
                      );
                    }),
                    const SizedBox(height: 15),
                    botonesVerdes("Mapa Interactivo", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapaScreen()),
                      );
                    }),
                    const SizedBox(height: 30),

                    // Seccion AsesoreS
                    lineaDivisoria("Asesores"),
                    const SizedBox(height: 15),
                    botonesVerdes("Iniciar sesión", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }),
                    const SizedBox(height: 40),

                    // Enlace a los terminos y condiciones
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/Terminos'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Términos y condiciones de uso",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Boton Salir
                    SizedBox(
                      width: 150,
                      child: botonesVerdes("Salir", () {
                        modalSalir(context);
                      }),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void modalSalir(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar salida"),
        content: const Text("¿Desea salir de la aplicación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }
}