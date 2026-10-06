import 'package:flutter/material.dart';
import 'package:nexxus/Views/carrera_screen.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Mapa interactivo",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      //Imagen MAPA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Image.asset(
                          'Assets/Carreras/mapa.png',
                          fit: BoxFit.contain, //para mantener la proporción
                          width: double.infinity, //para aprovechar el ancho disponible que el padding permite
                        ),
                      ),
                      const SizedBox(height: 20),
                      //botones de las carreras
                      //Gastronomía*********************************************
                      GestureDetector(
                        onTap: () {
                          // Acción al tocar el botón
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarreraScreen(carrera: 'G',),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Image.asset(
                            'Assets/Carreras/botonG.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Datos e inteligencia artificial*************************
                      GestureDetector(
                        onTap: () {
                          // Acción al tocar el botón
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarreraScreen(carrera: 'DIA',),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Image.asset(
                            'Assets/Carreras/botonDIA.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Mecatrónica*********************************************
                      GestureDetector(
                        onTap: () {
                          // Acción al tocar el botón
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarreraScreen(carrera: 'IM',),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Image.asset(
                            'Assets/Carreras/botonIM.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Ingenieria Financiera***********************************
                      GestureDetector(
                        onTap: () {
                          // Acción al tocar el botón
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarreraScreen(carrera: 'IF',),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Image.asset(
                            'Assets/Carreras/botonIF.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Tecnologías de la Información e Innovación Digital******
                      GestureDetector(
                        onTap: () {
                          // Acción al tocar el botón
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarreraScreen(carrera: 'TIID',),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Image.asset(
                            'Assets/Carreras/botonTIID.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Negocios y Mercadotecnia********************************
                      GestureDetector(
                        onTap: () {
                          // Acción al tocar el botón
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarreraScreen(carrera: 'NM',),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Image.asset(
                            'Assets/Carreras/botonNM.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Spacer(),

                      //botones al final de la pantalla
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30), child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 150,
                              child: botonesVerdes("Regresar", () {
                                Navigator.pop(context);
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}