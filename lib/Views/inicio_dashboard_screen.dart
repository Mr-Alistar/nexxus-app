import 'dart:math' as math;
import 'package:flutter/material.dart';
// [NUEVO]: Importamos el modelo Prospecto y el ViewModel para leer y subir datos reales de SQLite
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/View_Models/prospectos_locales_view_model.dart';

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

// [MODIFICADO]: Se cambia de StatelessWidget a StatefulWidget para cargar y escuchar SQLite en tiempo real
class InicioDashboardScreen extends StatefulWidget {
  const InicioDashboardScreen({super.key});

  @override
  State<InicioDashboardScreen> createState() => _InicioDashboardScreenState();
}

class _InicioDashboardScreenState extends State<InicioDashboardScreen> {
  // [NUEVO]: Instancia del ViewModel que consulta SQLite y sube registros al CRM
  final ProspectosLocalesViewModel _viewModel = ProspectosLocalesViewModel();

  @override
  void initState() {
    super.initState();
    // [NUEVO]: Cargamos los prospectos reales desde SQLite al abrir el Dashboard
    _viewModel.cargarProspectos();
  }

  // [NUEVO]: Genera la fecha actual formateada en español para el encabezado
  String _obtenerFechaActual() {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final ahora = DateTime.now();
    final diaSemana = dias[ahora.weekday - 1];
    final mes = meses[ahora.month - 1];
    return "$diaSemana, ${ahora.day} de $mes de ${ahora.year}";
  }

  // [NUEVO]: Calcula dinámicamente cuántos aspirantes hay por cada carrera en SQLite
  List<_Carrera> _calcularDemandaCarreras(List<Prospecto> prospectos) {
    final colores = [
      _C.teal700,
      _C.teal600,
      _C.emerald500,
      _C.emerald600,
      _C.teal800,
      _C.amber500,
    ];

    // Catálogo base con las 6 carreras oficiales del CRM
    final Map<String, int> conteo = {
      'Ingeniería en Datos e Inteligencia Artificial': 0,
      'Ingeniería Financiera': 0,
      'Ingeniería en Tecnologías de la Información e Innovación Digital': 0,
      'Ingeniería en Mecatrónica': 0,
      'Licenciatura en Innovación de Negocios y Mercadotecnia': 0,
      'Licenciatura en Gastronomía': 0,
    };

    for (final p in prospectos) {
      final carrera = p.carrera.trim();
      if (carrera.isNotEmpty) {
        conteo[carrera] = (conteo[carrera] ?? 0) + 1;
      }
    }

    // Ordenamos de mayor a menor demanda
    final entradas = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entradas.length, (i) {
      return _Carrera(
        entradas[i].key,
        entradas[i].value,
        colores[i % colores.length],
      );
    });
  }

  // [NUEVO]: Calcula dinámicamente los segmentos del embudo según el status en SQLite
  List<_Segmento> _calcularEmbudo(List<Prospecto> prospectos) {
    int enSeguimiento = 0;
    int enComunicacion = 0;
    int sinContacto = 0;
    int rechazado = 0;

    for (final p in prospectos) {
      switch (p.status.toLowerCase()) {
        case 'en-seguimiento':
          enSeguimiento++;
          break;
        case 'en-comunicacion':
          enComunicacion++;
          break;
        case 'rechazado':
          rechazado++;
          break;
        case 'sin-contacto':
        default:
          sinContacto++;
          break;
      }
    }

    return [
      _Segmento("En seguimiento", enSeguimiento, _C.teal700),
      _Segmento("En comunicación", enComunicacion, _C.emerald500),
      _Segmento("Sin contacto", sinContacto, _C.slate400),
      _Segmento("Rechazado", rechazado, _C.rose500),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        // [MODIFICADO]: Escuchamos los cambios de _viewModel para redibujar el dashboard automáticamente
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            final prospectos = _viewModel.prospectos;
            final total = prospectos.length;
            final pendientes = total; // Todos los registros en SQLite están pendientes de subir al CRM
            final seguimiento = prospectos
                .where((p) =>
            p.status == 'en-seguimiento' ||
                p.status == 'en-comunicacion')
                .length;
            final sinContacto = prospectos
                .where((p) => p.status == 'sin-contacto' || p.status.isEmpty)
                .length;

            final carreras = _calcularDemandaCarreras(prospectos);
            final embudoDatos = _calcularEmbudo(prospectos);

            // [NUEVO]: Obtenemos los últimos 4 prospectos capturados (del más reciente al más antiguo)
            final recientes = prospectos.reversed
                .take(4)
                .map((p) => _Reciente(
              "${p.nombre} ${p.apellido1} ${p.apellido2 ?? ''}".trim(),
              p.carrera,
            ))
                .toList();

            // [NUEVO]: RefreshIndicator permite deslizar hacia abajo para actualizar las métricas
            return RefreshIndicator(
              color: _C.teal700,
              onRefresh: _viewModel.cargarProspectos,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _bienvenida(),
                  const SizedBox(height: 18),
                  _bannerSync(pendientes),
                  const SizedBox(height: 18),
                  _kpis(
                    total: total,
                    pendientes: pendientes,
                    seguimiento: seguimiento,
                    sinContacto: sinContacto,
                  ),
                  const SizedBox(height: 18),
                  _demandaPorCarrera(carreras, total),
                  const SizedBox(height: 18),
                  _embudo(embudoDatos, total),
                  const SizedBox(height: 18),
                  _ultimosCapturados(recientes),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===== 1. Bienvenida =====
  Widget _bienvenida() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      "¡Hola, Asesor!",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
                          "Activo",
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
              const Text(
                "Asesor de Admisiones • UT Chetumal",
                style: TextStyle(fontSize: 12, color: _C.slate600),
              ),
              const SizedBox(height: 2),
              // [MODIFICADO]: Muestra la fecha real del dispositivo
              Text(
                _obtenerFechaActual(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _C.teal700,
                ),
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
          child: const Text(
            "UT",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ===== 2. Banner de sincronización =====
  // [MODIFICADO]: Recibe el conteo real de pendientes y activa el botón "Subir todo"
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      "$pendientes fichas pendientes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Capturadas sin conexión, listas para enviar a Nexxus.",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // [MODIFICADO]: Se envuelve en Material + InkWell para que el botón "Subir todo" funcione
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: pendientes == 0 ? null : () => _confirmarSubida(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 18,
                      color: pendientes == 0 ? _C.slate400 : _C.teal700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      pendientes == 0
                          ? "Todo sincronizado"
                          : "Subir todo ($pendientes)",
                      style: TextStyle(
                        color: pendientes == 0 ? _C.slate400 : _C.teal800,
                        fontSize: 14,
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
    );
  }

  // ===== 3. KPIs =====
  // [MODIFICADO]: Recibe los contadores reales desde SQLite
  Widget _kpis({
    required int total,
    required int pendientes,
    required int seguimiento,
    required int sinContacto,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Métricas locales en dispositivo",
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
                valor: "$total",
                etiqueta: "Total prospectos",
                colorIcono: _C.teal700,
                fondoIcono: _C.teal50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                icono: Icons.cloud_sync,
                valor: "$pendientes",
                etiqueta: "Por subir a CRM",
                colorIcono: _C.emerald800,
                fondoIcono: _C.emerald50,
                destacado: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                icono: Icons.contact_phone,
                valor: "$seguimiento",
                etiqueta: "En seguimiento",
                colorIcono: _C.teal600,
                fondoIcono: _C.teal50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                icono: Icons.phone_missed,
                valor: "$sinContacto",
                etiqueta: "Sin contacto",
                colorIcono: _C.slate600,
                fondoIcono: _C.slate100,
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

  // ===== 4. Demanda por carrera =====
  // [MODIFICADO]: Recibe la lista dinámica de carreras y el total real
  Widget _demandaPorCarrera(List<_Carrera> carreras, int total) {
    return _tarjeta(
      titulo: "Demanda por carrera",
      subtitulo: "Distribución de $total aspirantes registrados",
      icono: Icons.bar_chart,
      hijo: Column(
        children: [
          for (int i = 0; i < carreras.length; i++)
            Padding(
              padding:
              EdgeInsets.only(bottom: i == carreras.length - 1 ? 0 : 12),
              child: _barraCarrera(carreras[i], total),
            ),
        ],
      ),
    );
  }

  Widget _barraCarrera(_Carrera c, int total) {
    final pct = total == 0 ? 0.0 : c.cantidad / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                c.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _C.slate900),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${c.cantidad} (${(pct * 100).round()}%)",
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
            valueColor: AlwaysStoppedAnimation<Color>(c.color),
          ),
        ),
      ],
    );
  }

  // ===== 5. Embudo por estado (donut) =====
  // [MODIFICADO]: Usa los datos reales y protege contra división entre 0 cuando no hay registros
  Widget _embudo(List<_Segmento> embudoDatos, int total) {
    return _tarjeta(
      titulo: "Embudo de prospección",
      subtitulo: "Estado de conversión y atención",
      icono: Icons.filter_alt,
      hijo: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: _DonutPainter(embudoDatos, total),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$total",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.slate900,
                      ),
                    ),
                    const Text(
                      "Aspirantes",
                      style: TextStyle(fontSize: 10, color: _C.slate600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                for (final s in embudoDatos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: s.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.etiqueta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: _C.slate900),
                          ),
                        ),
                        // [MODIFICADO]: Si total es 0, muestra 0% en lugar de fallar con NaN
                        Text(
                          "${s.valor} (${total == 0 ? 0 : (s.valor / total * 100).round()}%)",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _C.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 6. Últimos capturados =====
  // [MODIFICADO]: Muestra los últimos registros reales o un mensaje cuando no hay ninguno
  Widget _ultimosCapturados(List<_Reciente> recientes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Últimos capturados",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _C.slate900,
          ),
        ),
        const SizedBox(height: 10),
        if (recientes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.slate100),
            ),
            child: const Center(
              child: Text(
                "Aún no hay aspirantes capturados localmente.",
                style: TextStyle(fontSize: 13, color: _C.slate600),
              ),
            ),
          )
        else
          ...recientes.map(_filaReciente),
      ],
    );
  }

  Widget _filaReciente(_Reciente r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _C.emerald50,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _iniciales(r.nombre),
              style: const TextStyle(
                color: _C.emerald800,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _C.slate900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  r.carrera,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: _C.slate600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _C.emerald100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 12, color: _C.emerald800),
                SizedBox(width: 4),
                Text(
                  "Local",
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
    );
  }

  // [NUEVO]: Modal de confirmación para subir los registros al CRM desde el Dashboard
  void _confirmarSubida(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Confirmar subida",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Desea enviar todas las fichas pendientes al módulo de Solicitudes del CRM Nexxus?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final resultados = await _viewModel.subirNexxus();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    // [MODIFICADO]: Muestra cuántos fueron nuevos, cuántos duplicados se omitieron y cuántos fallaron
                    content: Text(
                      "Nuevos: ${resultados['exitos']} | Omitidos (duplicados): ${resultados['duplicados'] ?? 0} | Fallidos: ${resultados['fallos']}",
                    ),
                    backgroundColor: resultados['fallos'] == 0
                        ? _C.teal600
                        : _C.rose500, // (o _C.rose500 en inicio_dashboard_screen.dart)
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

  String _iniciales(String nombre) {
    final partes =
    nombre.split(' ').where((s) => s.trim().isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }
}

class _Carrera {
  final String nombre;
  final int cantidad;
  final Color color;
  const _Carrera(this.nombre, this.cantidad, this.color);
}

class _Segmento {
  final String etiqueta;
  final int valor;
  final Color color;
  const _Segmento(this.etiqueta, this.valor, this.color);
}

class _Reciente {
  final String nombre;
  final String carrera;
  const _Reciente(this.nombre, this.carrera);
}

// Pintor del donut del embudo de estados.
class _DonutPainter extends CustomPainter {
  final List<_Segmento> segmentos;
  final int total;
  _DonutPainter(this.segmentos, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = math.min(size.width, size.height) / 2;
    final grosor = radio * 0.30;
    final rect = Rect.fromCircle(center: centro, radius: radio - grosor / 2);

    final fondo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..color = const Color(0xFFEDF2F1);
    canvas.drawCircle(centro, radio - grosor / 2, fondo);

    if (total == 0) return;

    double inicio = -math.pi / 2;
    const espacio = 0.03;
    for (final s in segmentos) {
      if (s.valor == 0) continue;
      final barrido = (s.valor / total) * 2 * math.pi;
      final pintura = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round
        ..color = s.color;
      canvas.drawArc(
        rect,
        inicio + espacio / 2,
        math.max(0, barrido - espacio),
        false,
        pintura,
      );
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segmentos != segmentos || old.total != total;
}