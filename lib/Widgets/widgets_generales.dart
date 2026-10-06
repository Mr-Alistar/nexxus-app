import 'package:flutter/material.dart';
//esto sirve para reutilizar el formato sin agregar repetidas ocaciones lo mismo en otras vistas
Widget tituloSeccion(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

Widget contenidoSeccion(String content) {
  return SelectableText(
    content,
    style: const TextStyle(
      fontSize: 14,
      color: Colors.black,
      height: 1.5,
    ),
  );
}

Widget contenidoPuntos(String boldText, String normalText) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 14, color: Colors.black)),//color de los puntos
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, //color de las letras por cada punto
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: "$boldText: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: normalText),
                //TextSpan(text: normalText),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget botonesVerdes(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF14A38E),//color del boton
        foregroundColor: Colors.white,//color de letra
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
    ),
  );
}

Widget lineaDivisoria(String label) {
  return Row(
    children: [
      const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
      const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
    ],
  );
}

//bordes redondeados color blanco sin laterales
const InputDecoration decoracionCampos = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
);

// widget para las secciones (formato)
Widget formatoSecciones({required String title, required Widget content, required IconData icon}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2D5A27)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: 25),
        content,
      ],
    ),
  );
}