import 'package:flutter/material.dart';
import 'package:nexxus/View_Models/prospectos_locales_view_model.dart';
import 'package:nexxus/Views/formulario_screen.dart';
import 'package:nexxus/Widgets/Dialogos/vista_previa.dart';
import 'package:nexxus/Services/exportar_service.dart';

class ProspectosLocalesScreen extends StatefulWidget {
  const ProspectosLocalesScreen({super.key});

  @override
  State<ProspectosLocalesScreen> createState() =>
      _ProspectosLocalesScreenState();
}

class _ProspectosLocalesScreenState extends State<ProspectosLocalesScreen> {
  final ProspectosLocalesViewModel _viewModel = ProspectosLocalesViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.cargarProspectos();
  }

  void _confirmarEliminacion(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Confirmar eliminación",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Está seguro de que desea eliminar este prospecto localmente?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final exito = await _viewModel.eliminarProspecto(id);
              if (context.mounted) {
                Navigator.pop(context);
                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Prospecto eliminado")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start, //cp
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20.0,
                  ),
                  child: SizedBox(
                    width: double.infinity, //se toma el ancho total
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, //centramos respecto al ancho total
                      children: [
                        Text(
                          "Registros locales",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Exporte, edite o elimine los prospectos registrados localmente.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _cargarProspectos()),

                // botones de Exportación (CSV y Excel) fijos en la parte inferior
                if (_viewModel.prospectos.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, -15),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _botonExportar(
                          icon: Icons.cloud_upload,
                          label: "Subir a\nNexxus",
                          color: Colors.blue,
                          onPressed: () => _confirmarSubida(//confirmarSubida se acciona aqui
                            context,
                          ),
                        ),
                        _botonExportar(
                          icon: Icons.ios_share,
                          label: "Compartir\nCSV",
                          color: Colors.black,
                          onPressed: () {
                            // tabla de datos en el estado actual
                            final datos = ExportarService.instancia
                                .obtenerDatosVistaPrevia(_viewModel.prospectos);
                            // esto genera la vista previa
                            modalVistaPrevia(
                              context: context,
                              titulo: "Vista previa (aspirantes locales)",
                              datos: datos,
                              onConfirmar: () => _viewModel.exportarCSV(),
                            );
                          },
                        ),
                        _botonExportar(
                          icon: Icons.ios_share,
                          label: "Compartir\nExcel",
                          color: Colors.green,
                          onPressed: () {
                            // lo mismo que el anterior, tabla de datos
                            final datos = ExportarService.instancia
                                .obtenerDatosVistaPrevia(_viewModel.prospectos);
                            // vista previa
                            modalVistaPrevia(
                              context: context,
                              titulo: "Vista previa (aspirantes locales)",
                              datos: datos,
                              onConfirmar: () => _viewModel.exportarExcel(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _botonExportar({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
//PRIVADOS para esta vista
  Widget _cargarProspectos() {
    if (_viewModel.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.prospectos.isEmpty) {
      return const Center(child: Text("No hay prospectos registrados."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _viewModel.prospectos.length,
      itemBuilder: (context, index) {
        final p = _viewModel.prospectos[index];
        //cargo los prospectos como tarjetas independientes
        return Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ), //separacion entre tarjetas
          elevation: 5, //efecto sobra de la tarjeta
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ), //bordes redondeados
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${p.nombre} ${p.apellido1} ${p.apellido2 ?? ''}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FormularioScreen(prospecto: p),
                          ),
                        );
                        if (resultado == true) {
                          _viewModel.cargarProspectos();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Editar",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _confirmarEliminacion(context, p.id!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarSubida(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Confirmar subida",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Desea enviar todos los registros locales al servidor Nexxus?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Se ejecuta la subida a través de viewModel
              final resultados = await _viewModel.subirNexxus();
              //pendiente: eliminar la base de datos local si se suben los registros exitosamente.
              if (context.mounted) {
                Navigator.pop(context); // Cerramos el diálogo si pone No
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Prospectos enviados: ${resultados['exitos']}, Fallidos: ${resultados['fallos']}",
                    ),
                    backgroundColor: resultados['fallos'] == 0
                        ? Color(0xFF14A38E)
                        : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF14A38E)),
            child: const Text("Subir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
