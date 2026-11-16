import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nexxus/Views/carrera_screen.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Paleta institucional UTChetumal
  static const Color _utVerdeOscuro = Color(0xFF006837);
  static const Color _utVerdeMedio = Color(0xFF008547);
  static const Color _utDorado = Color(0xFFC59B27);
  static const Color _utFondo = Color(0xFFF5F8F6);

  late final WebViewController _webViewController;
  bool _mapaCargado = false;
  bool _pantallaCompleta = false;

  @override
  void initState() {
    super.initState();
    _inicializarMapa3D();
  }

  void _inicializarMapa3D() {
    _webViewController = WebViewController();

    if (!kIsWeb) {
      // Configuración nativa para Android e iOS
      _webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFD9E8DC))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) {
                setState(() => _mapaCargado = true);
              }
            },
          ),
        )
        ..loadFlutterAsset('Assets/mapa_3d/campus_utchetumal_3d.html');
    } else {
      // En navegador (Web): carga el asset directamente mediante su URI pública
      _mapaCargado = true;
      final Uri assetUri = Uri.base.resolve(
        'assets/Assets/mapa_3d/campus_utchetumal_3d.html',
      );
      _webViewController.loadRequest(assetUri);
    }
  }

  void _alternarPantallaCompleta() {
    setState(() {
      _pantallaCompleta = !_pantallaCompleta;
    });
  }

  Widget _buildVisorMapa3D() {
    return Stack(
      children: [
        WebViewWidget(
          controller: _webViewController,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
            ),
          },
        ),
        if (!_mapaCargado)
          Container(
            color: const Color(0xFFD9E8DC),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: _utVerdeOscuro,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Cargando campus UTChetumal 3D...",
                    style: TextStyle(
                      color: _utVerdeOscuro,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBotonCarrera(String assetPath, String carreraCodigo) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _utDorado.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarreraScreen(carrera: carreraCodigo),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Modo Pantalla Completa con barra superior dedicada fuera del WebView
    if (_pantallaCompleta) {
      return Scaffold(
        backgroundColor: const Color(0xFFD9E8DC),
        appBar: AppBar(
          backgroundColor: _utVerdeOscuro,
          foregroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          title: const Text(
            "Campus UTChetumal 3D",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: _alternarPantallaCompleta,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.16),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.fullscreen_exit_rounded, size: 20),
                label: const Text(
                  "Salir",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        body: SizedBox.expand(
          child: _buildVisorMapa3D(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _utFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: _utDorado.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _utDorado.withOpacity(0.45),
                            ),
                          ),
                          child: const Text(
                            "CAMPUS UTCHETUMAL",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _utVerdeOscuro,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Text(
                          "Mapa interactivo 3D",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _utVerdeOscuro,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Rota el campus y toca los edificios para explorar",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _utDorado.withOpacity(0.5),
                        width: 1.4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.fullscreen_rounded,
                        color: _utVerdeOscuro,
                        size: 26,
                      ),
                      tooltip: "Pantalla completa",
                      onPressed: _alternarPantallaCompleta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contenedor del visor HTML5 3D con marco institucional
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _utVerdeMedio, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _utVerdeOscuro.withOpacity(0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 410,
                    width: double.infinity,
                    child: _buildVisorMapa3D(),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _utDorado,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(
                    "Oferta Educativa",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _utVerdeOscuro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildBotonCarrera('Assets/Carreras/botonG.jpg', 'G'),
              const SizedBox(height: 16),
              _buildBotonCarrera('Assets/Carreras/botonDIA.jpg', 'DIA'),
              const SizedBox(height: 16),
              _buildBotonCarrera('Assets/Carreras/botonIM.jpg', 'IM'),
              const SizedBox(height: 16),
              _buildBotonCarrera('Assets/Carreras/botonIF.jpg', 'IF'),
              const SizedBox(height: 16),
              _buildBotonCarrera('Assets/Carreras/botonTIID.jpg', 'TIID'),
              const SizedBox(height: 16),
              _buildBotonCarrera('Assets/Carreras/botonNM.jpg', 'NM'),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Center(
                  child: SizedBox(
                    width: 160,
                    child: botonesVerdes("Regresar", () {
                      Navigator.pop(context);
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}