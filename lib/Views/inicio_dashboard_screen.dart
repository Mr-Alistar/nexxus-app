import 'package:flutter/material.dart';
import 'package:nexxus/Models/dashboard_model.dart';
import 'package:nexxus/View_Models/dashboard_view_model.dart';

// Paleta del rediseño (teal / esmeralda), consistente con la sección Registrados.
class _C {
  static const bg = Color(0xFFF0F5F5);
  static const teal900 = Color(0xFF134E4A);
  static const teal800 = Color(0xFF115E59);
  static const teal700 = Color(0xFF0F766E);
  static const teal600 = Color(0xFF0D9488);
  static const teal50 = Color(0xFFF0FDFA);
  static const emerald800 = Color(0xFF065F46);
  static const emerald600 = Color(0xFF059669);
  static const emerald500 = Color(0xFF10B981);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald50 = Color(0xFFECFDF5);
  static const slate900 = Color(0xFF0F172A);
  static const slate600 = Color(0xFF475569);
  static const slate400 = Color(0xFF94A3B8);
  static const slate100 = Color(0xFFF1F5F9);
  static const rose500 = Color(0xFFF43F5E);
  static const amber500 = Color(0xFFF59E0B);
}

class InicioDashboardScreen extends StatelessWidget {
  final DashboardViewModel viewModel;

  const InicioDashboardScreen({
    super.key,
    required this.viewModel,
  });

  // Colores que se reutilizan en orden para las barras de cada gráfica.
  static const List<Color> _colores = [
    _C.teal600,
    _C.emerald500,
    _C.teal700,
    _C.emerald600,
    _C.slate400,
    _C.amber500,
    _C.teal800,
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final datos = viewModel.datos;
        final total = datos?.totalProspectos ?? 0;

        return Scaffold(
          backgroundColor: _C.bg,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: viewModel.cargarTodo,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _bienvenida(viewModel.nombreUsuario, datos?.rol == 'admin'),
                  const SizedBox(height: 18),
                  if (viewModel.errorCrm) ...[
                    _avisoSinConexion(datos != null),
                    const SizedBox(height: 18),
                  ],
                  _bannerSync(viewModel.porSubir),
                  const SizedBox(height: 18),
                  _kpis(datos),
                  const SizedBox(height: 18),
                  _graficaConteos(
                    titulo: "Demanda por carrera",
                    icono: Icons.bar_chart,
                    items: datos?.porCarrera ?? const [],
                    total: total,
                  ),
                  const SizedBox(height: 18),
                  _graficaConteos(
                    titulo: "Preparatoria de procedencia",
                    icono: Icons.school,
                    items: datos?.porPreparatoria ?? const [],
                    total: total,
                  ),
                  const SizedBox(height: 18),
                  _graficaConteos(
                    titulo: "Modalidad",
                    icono: Icons.event_note,
                    items: datos?.porModalidad ?? const [],
                    total: total,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== 1. Bienvenida =====
  Widget _bienvenida(String nombre, bool esAdmin) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : "A";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      "¡Hola, $nombre!",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.slate900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.emerald100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: _C.emerald600),
                        SizedBox(width: 5),
                        Text(
                          "En línea",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _C.emerald800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                esAdmin
                    ? "Administrador • UT Chetumal"
                    : "Asesor de Admisiones • UT Chetumal",
                style: const TextStyle(fontSize: 12, color: _C.slate600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.teal600, _C.emerald600],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            inicial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Aviso cuando no se pudieron traer las métricas del CRM (p. ej. sin internet).
  Widget _avisoSinConexion(bool hayDatosPrevios) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.amber500.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 18, color: _C.amber500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hayDatosPrevios
                  ? "Sin conexión. Mostrando la última información cargada."
                  : "No se pudieron cargar las métricas del CRM. Desliza hacia abajo para reintentar.",
              style: const TextStyle(fontSize: 12, color: _C.slate900),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 2. Banner de sincronización (fichas locales por subir) =====
  Widget _bannerSync(int pendientes) {
    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_sync, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pendientes == 1 ? "1 ficha pendiente" : "$pendientes fichas pendientes",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Capturadas localmente, listas para enviar a Nexxus.",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 3. KPIs (datos del CRM según el rol) =====
  Widget _kpis(DashboardData? datos) {
    final total = datos == null ? "–" : "${datos.totalProspectos}";
    final semana = datos == null ? "–" : "${datos.solicitudesSemana}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Métricas del período",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _C.slate900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                icono: Icons.groups,
                valor: total,
                etiqueta: "Total prospectos",
                colorIcono: _C.teal700,
                fondoIcono: _C.teal50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                icono: Icons.event_available,
                valor: semana,
                etiqueta: "Solicitudes de la semana",
                colorIcono: _C.emerald800,
                fondoIcono: _C.emerald50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required IconData icono,
    required String valor,
    required String etiqueta,
    required Color colorIcono,
    required Color fondoIcono,
    bool destacado = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: destacado ? _C.emerald50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: destacado ? _C.emerald200 : _C.slate100),
        boxShadow: [
          BoxShadow(
            color: _C.teal900.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: fondoIcono,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 19, color: colorIcono),
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _C.slate900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 12, color: _C.slate600),
          ),
        ],
      ),
    );
  }

  // ===== 4. Gráfica de barras genérica (carrera / preparatoria / modalidad) =====
  Widget _graficaConteos({
    required String titulo,
    required IconData icono,
    required List<ConteoItem> items,
    required int total,
  }) {
    final visibles = _topConOtras(items);

    return _tarjeta(
      titulo: titulo,
      subtitulo: "Distribución de $total aspirantes registrados",
      icono: icono,
      hijo: visibles.isEmpty
          ? const Text(
              "Sin datos para mostrar.",
              style: TextStyle(fontSize: 12, color: _C.slate600),
            )
          : Column(
              children: [
                for (int i = 0; i < visibles.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: i == visibles.length - 1 ? 0 : 12),
                    child: _barra(
                      visibles[i],
                      total,
                      _colores[i % _colores.length],
                    ),
                  ),
              ],
            ),
    );
  }

  // Muestra las 6 primeras y agrupa el resto en "Otras".
  List<ConteoItem> _topConOtras(List<ConteoItem> items, {int max = 6}) {
    if (items.length <= max) return items;
    final top = items.take(max).toList();
    final resto = items.skip(max).fold<int>(0, (suma, e) => suma + e.total);
    return [...top, ConteoItem(nombre: 'Otras', total: resto)];
  }

  Widget _barra(ConteoItem item, int total, Color color) {
    final pct = total == 0 ? 0.0 : item.total / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _C.slate900),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${item.total} (${(pct * 100).round()}%)",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _C.slate600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 9,
            backgroundColor: _C.slate100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ===== Helpers de UI =====
  Widget _tarjeta({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Widget hijo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.slate100),
        boxShadow: [
          BoxShadow(
            color: _C.teal900.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _C.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(fontSize: 12, color: _C.slate600),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _C.teal50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 18, color: _C.teal700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          hijo,
        ],
      ),
    );
  }
}