import 'package:flutter/material.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';
import 'package:nexxus/Services/carrera_service.dart';
import 'package:nexxus/Models/carrera_model.dart';

// Esta pantalla muestra la descripción detallada (Acerca de) de la carrera seleccionada.
class AcercaScreen extends StatefulWidget {
  final String carrera; // Siglas de la carrera
  const AcercaScreen({super.key, required this.carrera});

  @override
  State<AcercaScreen> createState() => _AcercaScreenState();
}

class _AcercaScreenState extends State<AcercaScreen> {
  final CarreraService _carreraService = CarreraService();
  CarreraModel? carreraInfo;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Recuperammos la informacion.
  Future<void> _cargarDatos() async {
    final info = await _carreraService.obtenerCarrera(widget.carrera);
    if (mounted) {
      setState(() {
        carreraInfo = info;
        cargando = false;
      });
    }
  }

  // Asignamos colores representativos a las modalidades de estudio, como en los mockups
  Widget _formatoModalidades(String modalidad) {
    String mod = modalidad.trim();
    Color bgColor = Colors.grey;

    if (mod.toLowerCase().contains("escolarizada")) {
      bgColor = Colors.green;
    } else if (mod.toLowerCase().contains("mixta")) {
      bgColor = Colors.blue;
    } else if (mod.toLowerCase().contains("peesad")) {
      bgColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Text(
        mod,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (carreraInfo == null) {
      return const Scaffold(body: Center(child: Text("Información no disponible.")));
    }

    // Convertimos la cadena de modalidades en una lista
    List<String> listaModalidad = carreraInfo!.modalidad.isNotEmpty ? carreraInfo!.modalidad.split(',') : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Center(
          child: Text(
            carreraInfo!.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seccion de Modalidades
              if (listaModalidad.isNotEmpty)
                formatoSecciones(
                  icon: Icons.class_outlined,
                  title: "Modalidades",
                  content: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: listaModalidad.map((m) => _formatoModalidades(m)).toList(),
                    ),
                  ),
                ),
              
              // Seccion Acerca de la carrera
              formatoSecciones(
                icon: Icons.info_outline,
                title: "Acerca de la carrera",
                content: Text(
                  carreraInfo!.acercaDe,
                  style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
              ),

              const SizedBox(height: 40),

              // Boton Regresar
              Center(
                child: SizedBox(
                  width: 160,
                  height: 45,
                  child: botonesVerdes("Regresar", () => Navigator.pop(context)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
