import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';
import 'package:nexxus/Views/acerca_screen.dart';
import 'package:nexxus/Views/plan_screen.dart';
import 'package:nexxus/Services/carrera_service.dart';
import 'package:nexxus/Models/carrera_model.dart';

// Esta pantalla muestra la galería de imagenes e infomracion de una carrera.
class CarreraScreen extends StatefulWidget {
  final String carrera; // Recibe las siglas de la carrera (ej: 'G', 'IM')
  const CarreraScreen({super.key, required this.carrera});

  @override
  State<CarreraScreen> createState() => _CarreraScreenState();
}

class _CarreraScreenState extends State<CarreraScreen> {
  final CarreraService _carreraService = CarreraService();
  CarreraModel? carreraInfo;
  bool cargando = true;
  bool tieneError = false;

  // Mapa de respaldo para imagenes de fabrica en Assets (ultimo recurso)
  final Map<String, List<String>> imagenesAssets = {
    'G': ['Assets/Images/G/g100.jpeg', 'Assets/Images/G/g101.jpeg', 'Assets/Images/G/g102.jpeg'],
    'DIA': ['Assets/Images/DIA/dia100.jpeg', 'Assets/Images/DIA/dia101.jpeg', 'Assets/Images/DIA/dia102.jpeg'],
    'IM': ['Assets/Images/IM/im100.jpeg', 'Assets/Images/IM/im101.jpeg', 'Assets/Images/IM/im102.jpeg'],
    'IF': ['Assets/Images/IF/if100.jpeg', 'Assets/Images/IF/if101.jpeg', 'Assets/Images/IF/if102.jpeg'],
    'TIID': ['Assets/Images/TIID/tiid100.jpeg', 'Assets/Images/TIID/tiid101.jpeg', 'Assets/Images/TIID/tiid102.jpeg'],
    'NM': ['Assets/Images/NM/nm100.jpeg', 'Assets/Images/NM/nm101.jpeg', 'Assets/Images/NM/nm102.jpeg'],
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Cargamos la informacion de la carrera desde el servicio (SQLite o ultimo recurso fallback).
  Future<void> _cargarDatos() async {
    setState(() => cargando = true);
    try {
      final info = await _carreraService.obtenerCarrera(widget.carrera);
      if (mounted) {
        setState(() {
          carreraInfo = info;
          cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error al cargar datos de carrera: $e");
      if (mounted) {
        setState(() {
          tieneError = true;
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (carreraInfo == null || tieneError) {
      return const Scaffold(body: Center(child: Text("No se pudo cargar la información.")));
    }

    // Obtenemos la lista de fotos procesadas por el modelo
    List<String> listaFotos = carreraInfo!.obtenerListaFotos();
    
    // Si no hay fotos de red ni descargadas, usamos los Assets de fabrica
    if (listaFotos.isEmpty) {
      listaFotos = imagenesAssets[widget.carrera] ?? [];
    }

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
              // grupo de imagenes
              if (listaFotos.isNotEmpty)
                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listaFotos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: () => _mostrarImagenZoom(context, listaFotos[index]),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _construirImagen(listaFotos[index]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),
              
              // Botones de navegacion
              Column(
                children: [
                  botonesVerdes("Acerca de la carrera", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AcercaScreen(carrera: widget.carrera)));
                  }),
                  const SizedBox(height: 30),
                  botonesVerdes("Plan de estudios", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlanScreen(carrera: widget.carrera)));
                  }),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 150,
                    child: botonesVerdes("Regresar", () => Navigator.pop(context)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Decidimos que imagenes mostrar: si cargar desde Internet, desde el almacenamiento interno o desde Assets locales (primera vez).
  Widget _construirImagen(String ruta, {BoxFit fit = BoxFit.cover}) {
    if (ruta.startsWith('http')) {
      return Image.network(
        ruta,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else if (ruta.startsWith('/') || ruta.contains(':\\') || ruta.contains('Documents')) {
      return Image.file(
        File(ruta),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      return Image.asset(
        ruta,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
  }

  //para mostrar la imagen a pantalla completa con capacidad de zoom
  void _mostrarImagenZoom(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _construirImagen(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
