import 'package:flutter/material.dart';
import 'package:nexxus/View_Models/prospectos_locales_view_model.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/Views/formulario_screen.dart';
// [NUEVO]: Importamos el diálogo de vista previa para mostrar la tabla antes de exportar
import 'package:nexxus/Widgets/Dialogos/vista_previa.dart';

// Paleta del rediseño (basada en el diseño de Stitch / Tailwind teal-emerald)
class _C {
  static const bg = Color(0xFFF0F5F5);
  static const teal900 = Color(0xFF134E4A);
  static const teal800 = Color(0xFF115E59);
  static const teal700 = Color(0xFF0F766E);
  static const teal600 = Color(0xFF0D9488);
  static const teal100 = Color(0xFFCCFBF1);
  static const teal50 = Color(0xFFF0FDFA);
  static const emerald800 = Color(0xFF065F46);
  static const emerald600 = Color(0xFF059669);
  static const emerald500 = Color(0xFF10B981);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald50 = Color(0xFFECFDF5);
  static const slate900 = Color(0xFF0F172A);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate400 = Color(0xFF94A3B8);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const rose600 = Color(0xFFE11D48);
  static const rose50 = Color(0xFFFFF1F2);
}

class ProspectosLocalesScreen extends StatefulWidget {
  // Permite que el botón "Regresar al menú principal" vuelva al tab de inicio.
  final VoidCallback? onIrInicio;
  const ProspectosLocalesScreen({super.key, this.onIrInicio});

  @override
  State<ProspectosLocalesScreen> createState() =>
      _ProspectosLocalesScreenState();
}

class _ProspectosLocalesScreenState extends State<ProspectosLocalesScreen> {
  final ProspectosLocalesViewModel _viewModel = ProspectosLocalesViewModel();

  bool _buscando = false;
  String _consulta = '';

  @override
  void initState() {
    super.initState();
    _viewModel.cargarProspectos();
  }

  // Filtra la lista por nombre completo o carrera.
  List<Prospecto> get _listaFiltrada {
    if (_consulta.trim().isEmpty) return _viewModel.prospectos;
    final q = _consulta.toLowerCase();
    return _viewModel.prospectos.where((p) {
      final nombre =
      "${p.nombre} ${p.apellido1} ${p.apellido2 ?? ''}".toLowerCase();
      return nombre.contains(q) || p.carrera.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final total = _viewModel.prospectos.length;
            final lista = _listaFiltrada;

            if (_viewModel.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _encabezado(total)),
                SliverToBoxAdapter(child: _heroSync(total)),
                SliverToBoxAdapter(child: _barraLista(total)),
                if (lista.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _estadoVacio(total),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverList.separated(
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _tarjetaProspecto(lista[index]),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ====== Encabezado (chip de estado + menú de exportación) ======
  Widget _encabezado(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _botonCircular(
                icono: Icons.arrow_back,
                onTap: widget.onIrInicio ?? () {},
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _C.teal800,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: _C.emerald200),
                    SizedBox(width: 6),
                    Text(
                      "PORTAL MÓVIL • OFFLINE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              _botonExportar(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  "Registrados localmente",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _C.slate900,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _C.emerald100,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _C.emerald200),
                ),
                child: Text(
                  "$total en cola",
                  style: const TextStyle(
                    color: _C.emerald800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Aspirantes capturados sin conexión. Revisa, edita o súbelos a la nube de CRM Nexxus.",
            style: TextStyle(fontSize: 13, color: _C.slate600, height: 1.35),
          ),
        ],
      ),
    );
  }

  // ====== Hero: banner de sincronización con "Subir todo" ======
  Widget _heroSync(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [_C.emerald800, _C.teal700, _C.teal600],
          ),
          boxShadow: [
            BoxShadow(
              color: _C.teal900.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.cloud_sync, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pendientes de subir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$total fichas listas para sincronizar",
                    style: const TextStyle(
                      color: _C.emerald100,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: total == 0 ? null : () => _confirmarSubida(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.upload, size: 17, color: _C.teal700),
                      SizedBox(width: 6),
                      Text(
                        "Subir todo",
                        style: TextStyle(
                          color: _C.teal800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Barra "Lista de aspirantes" + total + búsqueda ======
  Widget _barraLista(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Lista de aspirantes",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _C.slate900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.teal100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "Total: $total",
                  style: const TextStyle(
                    color: _C.teal900,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              _botonChico(
                icono: _buscando ? Icons.close : Icons.search,
                onTap: () => setState(() {
                  _buscando = !_buscando;
                  if (!_buscando) _consulta = '';
                }),
              ),
            ],
          ),
          if (_buscando) ...[
            const SizedBox(height: 10),
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _consulta = v),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Buscar por nombre o carrera...",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.teal600, width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ====== Tarjeta de un prospecto ======
  Widget _tarjetaProspecto(Prospecto p) {
    final sinContacto = p.status == 'sin-contacto';
    final colorEstado = sinContacto ? _C.teal600 : _C.emerald500;
    final nombreCompleto =
    "${p.nombre} ${p.apellido1} ${p.apellido2 ?? ''}".trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.slate100),
        boxShadow: [
          BoxShadow(
            color: _C.teal900.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Franja de color de estado a la izquierda
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: colorEstado,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _avatar(nombreCompleto),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      nombreCompleto,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _C.slate900,
                                      ),
                                    ),
                                  ),
                                  if (p.id != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _C.teal50,
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                            color: _C.teal100),
                                      ),
                                      child: Text(
                                        "#${p.id.toString().padLeft(3, '0')}",
                                        style: const TextStyle(
                                          color: _C.teal800,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              _chip(
                                texto: p.carrera,
                                fondo: _C.emerald50,
                                borde: _C.emerald200,
                                textoColor: _C.emerald800,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _C.slate100,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: colorEstado,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Local • ${_etiquetaFecha(p.createdAt)}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _C.slate700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _C.slate100),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _accion(
                  icono: Icons.edit,
                  texto: "Editar",
                  fondo: _C.teal50,
                  color: _C.teal700,
                  onTap: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormularioScreen(prospecto: p),
                      ),
                    );
                    if (resultado == true) {
                      _viewModel.cargarProspectos();
                    }
                  },
                ),
                const SizedBox(width: 8),
                _accion(
                  icono: Icons.delete_outline,
                  texto: "Eliminar",
                  fondo: _C.rose50,
                  color: _C.rose600,
                  onTap: () => _confirmarEliminacion(context, p.id!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio(int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: _C.teal600),
            const SizedBox(height: 12),
            Text(
              total == 0
                  ? "No hay prospectos registrados."
                  : "Sin resultados para tu búsqueda.",
              style: const TextStyle(color: _C.slate600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Widgets reutilizables ======
  Widget _avatar(String nombreCompleto) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.teal600, _C.emerald600],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _iniciales(nombreCompleto),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _chip({
    required String texto,
    required Color fondo,
    required Color borde,
    required Color textoColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: borde),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textoColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _accion({
    required IconData icono,
    required String texto,
    required Color fondo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: 5),
              Text(
                texto,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonCircular({required IconData icono, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: _C.teal100)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icono, size: 20, color: _C.teal900),
        ),
      ),
    );
  }

  Widget _botonChico({required IconData icono, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.teal100),
          ),
          child: Icon(icono, size: 18, color: _C.teal800),
        ),
      ),
    );
  }

  // [MODIFICADO]: Botón "Exportar" con opciones Excel / CSV / PDF ya conectadas
  Widget _botonExportar() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: _mostrarOpcionesExportar,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _C.teal100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, size: 18, color: _C.teal800),
              SizedBox(width: 6),
              Text(
                "Exportar",
                style: TextStyle(
                  color: _C.teal800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [NUEVO]: Abre el modalVistaPrevia antes de ejecutar la exportación elegida
  void _abrirVistaPreviaYExportar({
    required String formato,
    required Future<void> Function(List<Prospecto> lista) accionExportar,
  }) {
    final listaActual = List<Prospecto>.from(_listaFiltrada);
    final datosTabla = _viewModel.obtenerDatosVistaPrevia(listaActual);

    modalVistaPrevia(
      context: context,
      titulo: "Vista previa ($formato)",
      datos: datosTabla,
      onConfirmar: () async {
        try {
          await accionExportar(listaActual);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error al exportar en $formato: $e"),
                backgroundColor: _C.rose600,
              ),
            );
          }
        }
      },
    );
  }

  // [MODIFICADO]: Hoja inferior con los 3 formatos conectados a sus métodos reales
  void _mostrarOpcionesExportar() {
    // [NUEVO]: Validamos que existan prospectos antes de abrir el menú de exportación
    if (_listaFiltrada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No hay registros disponibles para exportar."),
          backgroundColor: _C.teal800,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _C.slate200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Exportar registros",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _C.slate900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Elige el formato de salida.",
                style: TextStyle(fontSize: 13, color: _C.slate600),
              ),
              const SizedBox(height: 14),
              // [MODIFICADO]: Conectado a exportarExcel() con vista previa
              _opcionExportar(
                icono: Icons.table_chart_outlined,
                titulo: "Excel",
                subtitulo: "Hoja de cálculo (.xlsx)",
                color: _C.emerald600,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _abrirVistaPreviaYExportar(
                    formato: "Excel",
                    accionExportar: (lista) => _viewModel.exportarExcel(lista),
                  );
                },
              ),
              // [MODIFICADO]: Conectado a exportarCSV() con vista previa
              _opcionExportar(
                icono: Icons.description_outlined,
                titulo: "CSV",
                subtitulo: "Valores separados por comas (.csv)",
                color: _C.teal700,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _abrirVistaPreviaYExportar(
                    formato: "CSV",
                    accionExportar: (lista) => _viewModel.exportarCSV(lista),
                  );
                },
              ),
              // [MODIFICADO]: Conectado a exportarPDF() con vista previa
              _opcionExportar(
                icono: Icons.picture_as_pdf_outlined,
                titulo: "PDF",
                subtitulo: "Documento para imprimir (.pdf)",
                color: _C.rose600,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _abrirVistaPreviaYExportar(
                    formato: "PDF",
                    accionExportar: (lista) => _viewModel.exportarPDF(lista),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [MODIFICADO]: Ahora recibe el parámetro 'onTap' para ejecutar la acción seleccionada
  Widget _opcionExportar({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // [MODIFICADO]: Antes solo hacía Navigator.pop(context)
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _C.slate900,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(fontSize: 12, color: _C.slate600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _C.slate400),
            ],
          ),
        ),
      ),
    );
  }

  // ====== Utilidades ======
  String _iniciales(String nombre) {
    final partes =
    nombre.split(' ').where((s) => s.trim().isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }

  // Devuelve una fecha corta (dd/MM HH:mm) a partir del ISO guardado.
  String _etiquetaFecha(String? iso) {
    if (iso == null || iso.isEmpty) return 'reciente';
    final fecha = DateTime.tryParse(iso);
    if (fecha == null) return 'reciente';
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return "$dd/$mm $hh:$min";
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
            style: ElevatedButton.styleFrom(backgroundColor: _C.rose600),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
              // [RESUELTO]: _viewModel.subirNexxus() ya envía a la tabla 'solicitudes'
              // y elimina automáticamente de SQLite los registros enviados con éxito.
              final resultados = await _viewModel.subirNexxus();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    // [MODIFICADO]: Muestra cuántos fueron nuevos, cuántos duplicados se omitieron y cuántos fallaron
                    content: Text(
                      "Nuevos: ${resultados['exitos']} | Omitidos (duplicados): ${resultados['duplicados'] ?? 0} | Fallidos: ${resultados['fallos']}",
                    ),
                    backgroundColor: resultados['fallos'] == 0
                        ? _C.teal600
                        : _C.rose600, // (o _C.rose500 en inicio_dashboard_screen.dart)
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _C.teal600),
            child: const Text("Subir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}