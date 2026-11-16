import 'package:flutter/material.dart';
import 'package:nexxus/Views/formulario_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:nexxus/Views/mapa_screen.dart';
import 'login_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  // Paleta basada en el diseño de Stitch (Material 3 teal)
  static const Color _teal700 = Color(0xFF0F766E);
  static const Color _teal800 = Color(0xFF115E59);
  static const Color _teal50 = Color(0xFFE0F2F1);
  static const Color _cyan700 = Color(0xFF0E7490);
  static const Color _cyan50 = Color(0xFFECFEFF);
  static const Color _fondo = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Logo institucional
              SvgPicture.asset(
                'Assets/Generales/logonexxusverde.svg',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              // Texto de bienvenida
              const Text(
                "¡Bienvenido!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              // Chip de estado / versión
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _teal50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFCCFBF1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Color(0xFF14B8A6)),
                      SizedBox(width: 6),
                      Text(
                        "CRM Nexxus versión móvil • UT Chetumal",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _teal800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sección Aspirantes
              _encabezadoSeccion("Aspirantes"),
              const SizedBox(height: 12),
              _TarjetaAccion(
                icono: Icons.assignment_outlined,
                colorIcono: _teal700,
                fondoIcono: _teal50,
                titulo: "Formulario",
                etiqueta: "Admisión",
                subtitulo: "Registro de nuevo ingreso y seguimiento",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FormularioScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _TarjetaAccion(
                icono: Icons.explore_outlined,
                colorIcono: _cyan700,
                fondoIcono: _cyan50,
                titulo: "Mapa Interactivo",
                subtitulo: "Conoce edificios, laboratorios y aulas",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapaScreen()),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Sección Asesores
              _encabezadoSeccion("Asesores"),
              const SizedBox(height: 12),
              _TarjetaLogin(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Enlaces términos y privacidad
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/Terminos'),
                    child: const Text(
                      "Términos y condiciones de uso",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Text("•", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/Terminos'),
                    child: const Text(
                      "Aviso de privacidad",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botón Salir (outlined)
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => modalSalir(context),
                  icon: const Icon(Icons.logout, size: 18, color: Color(0xFF64748B)),
                  label: const Text("Salir"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Encabezado de sección con línea divisoria lateral
  Widget _encabezadoSeccion(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
        ],
      ),
    );
  }

  void modalSalir(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar salida"),
        content: const Text("¿Desea salir de la aplicación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }
}

// Tarjeta de acción blanca (Formulario / Mapa)
class _TarjetaAccion extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;
  final String titulo;
  final String? etiqueta;
  final String subtitulo;
  final VoidCallback onTap;

  const _TarjetaAccion({
    required this.icono,
    required this.colorIcono,
    required this.fondoIcono,
    required this.titulo,
    this.etiqueta,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: fondoIcono,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: colorIcono, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (etiqueta != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              etiqueta!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta de inicio de sesión (gradiente teal)
class _TarjetaLogin extends StatelessWidget {
  final VoidCallback onTap;
  const _TarjetaLogin({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [InicioScreen._teal700, InicioScreen._teal800],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: InicioScreen._teal800.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFFCCFBF1), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF14B8A6)),
                          ),
                          child: const Text(
                            "Personal",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFCCFBF1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Gestión de prospectos e inscripciones",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Color(0xFFCCFBF1)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.login, size: 18, color: Color(0xFFCCFBF1)),
            ],
          ),
        ),
      ),
    );
  }
}
