import 'package:flutter/material.dart';
import 'package:nexxus/Views/guardar_password_screen.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';

class VerificarScreen extends StatelessWidget {
  const VerificarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,// esto vita que los botones salten cuando aparece el teclado
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // parte superior con scroll para el contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Código de verificación",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Le hemos enviado un código a su correo electrónico.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "A continuación, ingrese el código de 5 dígitos:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Casillas para el código recibido
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return SizedBox(
                          width: 55,
                          child: TextField(
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 20),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 25),

                    // Texto como un boton para reenviar código
                    GestureDetector(
                      onTap: () => modalReenviar(context),
                      child: const Text(
                        "Reenviar código",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // botones estaticos al fondo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  botonesVerdes("Verificar", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuardarPasswordScreen(),
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

  void modalReenviar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reenviar código"),
        content: const Text(
            "Le recordamos que el sistema demora un momento en enviar el código. Le sugerimos esperar unos minutos y volver a intentarlo. Por favor, revise su carpeta de correo Spam o su bandeja de entrada. ¿Desea solicitar un nuevo código de recuperación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: const Text("Código reenviado."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Aceptar"),
                    ),
                  ],
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