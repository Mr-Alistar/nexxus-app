import 'package:flutter/material.dart';
import 'package:nexxus/Views/recuperar_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      resizeToAvoidBottomInset: false, //evita que los botones se muevan hacia arriba al abrir el teclado
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
                      const SizedBox(height: 20),
                      SvgPicture.asset(
                        'Assets/Generales/logonexxusverde.svg',
                        width: 300,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Ingrese sus datos para continuar:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40),

                      lineaDivisoria("Asesores"),
                      const SizedBox(height: 15),
                      const Text(
                        "Correo electrónico",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "usuario@utchetumal.edu.mx",
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Contraseña",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "********",
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              StatefulBuilder(
                                builder: (context, setState) {
                                  bool isChecked = false;
                                  return Checkbox(
                                    value: isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked = value ?? false;
                                      });
                                    },
                                  );
                                },
                              ),
                              const Text("Recuérdame"),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecuperarScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Recuperar contraseña",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),

                      //spacer para empujar los botones al fondo
                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          children: [
                            botonesVerdes("Acceder", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                              );
                            }),
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