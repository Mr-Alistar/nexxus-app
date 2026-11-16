import 'package:flutter/material.dart';
import 'package:nexxus/Views/login_screen.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';

class GuardarPasswordScreen extends StatelessWidget {
  const GuardarPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //pvita que la interfaz se mueva cuando aparece el teclado
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // Scroll para el formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // alinear textos a la izquierda
                  children: [
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        "Nueva contraseña",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        "Establezca su nueva contraseña:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Contraseña:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const TextField(
                      obscureText: true, //Para ocultar contraseña
                      decoration: InputDecoration(
                        hintText: "********",
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Confirme su contraseña:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const TextField(
                      obscureText: true, //Para ocultar contraseña
                      decoration: InputDecoration(
                        hintText: "********",
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // bloque de botones fijos al fondo del screen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  botonesVerdes("Guardar contraseña", () {
                    modalGuardar(context);
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

  void modalGuardar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Guardar nueva contraseña"),
        content: const Text("¿Desea guardar los cambios?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // cerrar modal
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); //cierra el modal antes de navegar
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }
}
