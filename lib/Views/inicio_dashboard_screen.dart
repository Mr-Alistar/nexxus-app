import 'dart:math' as math;
import 'package:flutter/material.dart';

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

// Pantalla de Inicio (dashboard). SOLO VISTA: datos de ejemplo, sin lógica.
class InicioDashboardScreen extends StatelessWidget {
  const InicioDashboardScreen({super.key});

  // ---- Datos de ejemplo (estáticos, solo para mostrar el diseño) ----
  static const int _total = 142;
  static const int _pendientes = 6;
  static const int _seguimiento = 58;
  static const int _sinContacto = 24;

  static const List<_Carrera> _carreras = [
    _Carrera("TSU Gastronomía", 38, _C.teal700),
    _Carrera("Ing. Datos e Inteligencia Artificial", 32, _C.teal600),
    _Carrera("Ing. Mecatrónica", 26, _C.emerald500),
    _Carrera("Lic. en Gestión Financiera", 20, _C.emerald600),
    _Carrera("Ing. TI e Innovación Digital", 16, _C.teal800),
    _Carrera("Lic. Negocios y Mercadotecnia", 10, _C.amber500),
  ];

  static const List<_Segmento> _embudoDatos = [
    _Segmento("En seguimiento", 58, _C.teal700),
    _Segmento("En comunicación", 45, _C.emerald500),
    _Segmento("Sin contacto", 24, _C.slate400),
    _Segmento("Rechazado", 15, _C.rose500),
  ];

  static const List<_Reciente> _recientes = [
    _Reciente("Juan Pérez García", "Ing. en Datos e IA"),
    _Reciente("Mariana Soto Pech", "TSU Gastronomía"),
    _Reciente("Omar Castro Hernández", "Lic. en Gestión Financiera"),
    _Reciente("Sofía Méndez Canché", "Ing. Mecatrónica"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _bienvenida(),
            const SizedBox(height: 18),
            _bannerSync(),
            const SizedBox(height: 18),
            _kpis(),
            const SizedBox(height: 18),
            _demandaPorCarrera(),
            const SizedBox(height: 18),
            _embudo(),
            const SizedBox(height: 18),
            _ultimosCapturados(),
          ],
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
                      "¡Hola, Carlos Pech!",
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
              const Text(
                "Asesor de Admisiones • UT Chetumal",
                style: TextStyle(fontSize: 12, color: _C.slate600),
              ),
              const SizedBox(height: 2),
              const Text(
                "Jueves, 24 de octubre de 2024",
                style: TextStyle(
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
            "CP",
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
  Widget _bannerSync() {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_pendientes fichas pendientes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Capturadas sin conexión, listas para enviar a Nexxus.",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, size: 18, color: _C.teal700),
                SizedBox(width: 8),
                Text(
                  "Subir todo",
                  style: TextStyle(
                    color: _C.teal800,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 3. KPIs =====
  Widget _kpis() {
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
                valor: "$_total",
                etiqueta: "Total prospectos",
                colorIcono: _C.teal700,
                fondoIcono: _C.teal50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                icono: Icons.cloud_sync,
                valor: "$_pendientes",
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
                valor: "$_seguimiento",
                etiqueta: "En seguimiento",
                colorIcono: _C.teal600,
                fondoIcono: _C.teal50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                icono: Icons.phone_missed,
                valor: "$_sinContacto",
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
  Widget _demandaPorCarrera() {
    return _tarjeta(
      titulo: "Demanda por carrera",
      subtitulo: "Distribución de $_total aspirantes registrados",
      icono: Icons.bar_chart,
      hijo: Column(
        children: [
          for (int i = 0; i < _carreras.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == _carreras.length - 1 ? 0 : 12),
              child: _barraCarrera(_carreras[i]),
            ),
        ],
      ),
    );
  }

  Widget _barraCarrera(_Carrera c) {
    final pct = _total == 0 ? 0.0 : c.cantidad / _total;
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
  Widget _embudo() {
    const total = 142;
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
              painter: _DonutPainter(_embudoDatos, total),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$total",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.slate900,
                      ),
                    ),
                    Text(
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
                for (final s in _embudoDatos)
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
                        Text(
                          "${s.valor} (${(s.valor / total * 100).round()}%)",
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
  Widget _ultimosCapturados() {
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
        ..._recientes.map(_filaReciente),
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
