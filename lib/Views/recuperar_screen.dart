import 'package:flutter/material.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';
import 'package:nexxus/Views/verificar_screen.dart';

class RecuperarScreen extends StatelessWidget {
  const RecuperarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // este codigo evita que los widgets se muevan cuando el teclado aparece
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column( //Usamos column como base principal
          children: [
            //scroll para los campos de texto
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Recuperar contraseña",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Introduzca su electrónico:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "usuario@utchetumal.edu.mx",
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Confirme su correo electrónico",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "usuario@utchetumal.edu.mx",
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            //botones al fondo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  botonesVerdes("Enviar código", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificarScreen(),
                      ),
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
    );
  }
}
