import 'package:flutter/material.dart';
import 'package:nexxus/Views/recuperar_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexxus/Services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Paleta basada en el diseño de Stitch (Material 3 teal)
  static const Color _teal700 = Color(0xFF0F766E);
  static const Color _teal600 = Color(0xFF0D9488);
  static const Color _fondo = Color(0xFFF8FAFC);

  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _ocultarPass = true;
  bool _recordar = false;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoCtrl.text.trim();
    final pass = _passCtrl.text;

    if (correo.isEmpty || pass.isEmpty) {
      _mostrarMensaje("Ingrese su correo y contraseña.");
      return;
    }

    setState(() => _cargando = true);
    final error = await ApiService.instancia.login(correo, pass);
    if (!mounted) return;
    setState(() => _cargando = false);

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      _mostrarMensaje(error);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior: regresar + chip + ayuda
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BotonCircular(
                    icono: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFB2DFDB)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: _teal600),
                        SizedBox(width: 6),
                        Text(
                          "PORTAL ASESORES • CRM",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF115E59),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BotonCircular(
                    icono: Icons.help_outline,
                    fondo: Colors.transparent,
                    borde: false,
                    colorIcono: const Color(0xFF94A3B8),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Logo UT Nexxus (en lugar del texto)
                    SvgPicture.asset(
                      'Assets/Generales/logonexxusverde.svg',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "UNIVERSIDAD TECNOLÓGICA DE CHETUMAL",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Iniciar sesión",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Ingresa tus credenciales institucionales para gestionar aspirantes y matrículas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Campo: correo
                    _etiqueta("Correo electrónico institucional"),
                    const SizedBox(height: 6),
                    _campo(
                      controller: _correoCtrl,
                      icono: Icons.mail_outline,
                      hint: "usuario@utchetumal.edu.mx",
                      teclado: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Campo: contraseña
                    _etiqueta("Contraseña"),
                    const SizedBox(height: 6),
                    _campo(
                      controller: _passCtrl,
                      icono: Icons.lock_outline,
                      hint: "••••••••••••",
                      obscure: _ocultarPass,
                      sufijo: IconButton(
                        onPressed: () => setState(() => _ocultarPass = !_ocultarPass),
                        icon: Icon(
                          _ocultarPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Recordar sesión + recuperar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _recordar = !_recordar),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _recordar,
                                  onChanged: (v) => setState(() => _recordar = v ?? false),
                                  activeColor: _teal700,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Recordar sesión",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecuperarScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _teal700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Botón principal: Acceder al CRM (gradiente)
                    _BotonGradiente(
                      texto: "Acceder al CRM",
                      cargando: _cargando,
                      onTap: _cargando ? null : _iniciarSesion,
                    ),
                    const SizedBox(height: 12),

                    // Botón secundario: regresar
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.subdirectory_arrow_left,
                            size: 18, color: Color(0xFF64748B)),
                        label: const Text("Regresar a pantalla de bienvenida"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pie: autenticación segura + soporte
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 16, color: _teal700),
                        SizedBox(width: 6),
                        Text(
                          "Autenticación Institucional Segura",
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          "¿Problemas con tu cuenta? ",
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Soporte TI UT",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _teal700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required IconData icono,
    required String hint,
    TextInputType teclado = TextInputType.text,
    bool obscure = false,
    Widget? sufijo,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(icono, color: const Color(0xFF0F766E), size: 20),
        suffixIcon: sufijo,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _teal600, width: 2),
        ),
      ),
    );
  }
}

// Botón circular de la barra superior
class _BotonCircular extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  final Color fondo;
  final Color colorIcono;
  final bool borde;

  const _BotonCircular({
    required this.icono,
    required this.onTap,
    this.fondo = Colors.white,
    this.colorIcono = const Color(0xFF475569),
    this.borde = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fondo,
      shape: CircleBorder(
        side: borde
            ? const BorderSide(color: Color(0xFFE2E8F0))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icono, size: 18, color: colorIcono),
        ),
      ),
    );
  }
}

// Botón principal con gradiente teal
class _BotonGradiente extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  final bool cargando;
  const _BotonGradiente({required this.texto, required this.onTap, this.cargando = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: cargando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
