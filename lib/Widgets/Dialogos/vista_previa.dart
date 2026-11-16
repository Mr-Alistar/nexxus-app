import 'package:flutter/material.dart';
//modal para mostrar la vista previa antes de compartir el archivo

void modalVistaPrevia({
  required BuildContext context,
  required String titulo,
  required List<List<dynamic>> datos,
  required VoidCallback onConfirmar,
}) {
  if (datos.isEmpty) return;

  //la primera fila es encabezado y el resto es el contenido
  final encabezados = datos.first;
  final cuerpo = datos.skip(1).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, //scroll vertical
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // scroll horizontal para tablas
            child: DataTable(
              columns: encabezados.map((e) => DataColumn(
                  label: Text(e.toString(), style: const TextStyle(fontWeight: FontWeight.bold))
              )).toList(),
              rows: cuerpo.map((fila) => DataRow(
                  cells: fila.map((celda) => DataCell(Text(celda.toString()))).toList()
              )).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); //cerrar la vista previa
            onConfirmar();          // Acciona exportación>compartido
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A38E)),
          child: const Text("Compartir", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}