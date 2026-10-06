import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';

class TerminosScreen extends StatelessWidget {
  const TerminosScreen({super.key});

  /* Función para abrir URL externa
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://adip.cdmx.gob.mx/storage/app/media/Alameda%20Central_Terminos%20y%20Condiciones/alameda-central-terminos-y-condiciones.pdf'); // URL
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Términos y condiciones\nde uso",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Contenido de los terminos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tituloSeccion("Aplicación Nexxus Móvil de la Universidad Tecnológica de Chetumal"),
                          contenidoSeccion(
                            "Al descargar, instalar o utilizar la aplicación móvil (en adelante, la Aplicación) proporcionada por la *Universidad Tecnológica de Chetumal* (en adelante, la Institución), usted acepta y se obliga a cumplir con los siguientes Términos y Condiciones. Si no está de acuerdo con alguno de estos términos, le rogamos no utilizar la Aplicación.",
                          ),
                          const SizedBox(height: 20),
                          //INCISO 1
                          tituloSeccion("1. Elegibilidad y Uso Autorizado"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "1.1 Personal exclusivo:",
                                  "El uso de esta Aplicación está estrictamente limitado al personal autorizado de la Universidad Tecnológica de Chetumal (docentes, administrativos, investigadores y personal operativo).",
                                ),
                                contenidoPuntos(
                                  "1.2 Acceso restringido:",
                                  "Queda expresamente prohibido el acceso o uso de la Aplicación por parte de estudiantes, exalumnos, personal externo o cualquier tercero que no pertenezca a la plantilla laboral de la Institución.",
                                ),
                                contenidoPuntos(
                                  "1.3 Verificación:",
                                  "La Institución se reserva el derecho de verificar la identidad y el estatus laboral del usuario en cualquier momento. El uso de credenciales de terceros o la falsificación de datos para acceder a la Aplicación resultará en el bloqueo inmediato del acceso y las acciones legales correspondientes.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          //INCISO 2
                          tituloSeccion("2. Propósito de la aplicación"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "2.1 Uso interno:",
                                  "La Aplicación ha sido desarrollada exclusivamente para facilitar procesos internos, comunicación institucional y gestión administrativa de la Universidad Tecnológica de Chetumal.",
                                ),
                                contenidoPuntos(
                                  "2.2 Acceso restringido:",
                                  "Prohibición de Fines Lucrativos: Está terminantemente prohibido utilizar la Aplicación, sus contenidos, datos o funcionalidades con fines comerciales, de lucro, monetización o para cualquier actividad que no corresponda al propósito académico y administrativo de la Institución.",
                                ),
                                contenidoPuntos(
                                  "2.3 Mal uso de la aplicación:",
                                  "Extraer, copiar o distribuir datos de la Institución. Modificar, descompilar o ingeniería inversa del código fuente. Utilizar la Aplicación para actividades ilegales, fraudulentas o que dañen la reputación de la Universidad Tecnológica de Chetumal.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          //INCISO 3
                          tituloSeccion("3. Estado \"Tal Cual\" (AS IS) y Disponibilidad"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "3.1 Sin garantías:",
                                  "La Aplicación se proporciona bajo la modalidad \"tal cual\" (AS IS) y \"según disponibilidad\". La Institución no ofrece, ni hace ninguna representación ni garantía, ya sea expresa o implícita, respecto al funcionamiento, precisión, fiabilidad o disponibilidad de la Aplicación. ",
                                ),
                                contenidoPuntos(
                                  "3.2 Exclusión de garantías implícitas:",
                                  "Se excluyen explícitamente cualquier garantía implícita de comerciabilidad, idoneidad para un propósito particular, titularidad o no infracción.",
                                ),
                                contenidoPuntos(
                                  "3.3 Funcionalidad:",
                                  "La Institución no garantiza que la Aplicación: \nEsté libre de errores, virus o fallos.\nFuncione de manera ininterrumpida o en tiempo real.\nSe adapte a todas las versiones de sistemas operativos móviles o dispositivos.\nMantenga la sincronización de datos en todo momento.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          //INCISO 4
                          tituloSeccion("4. Limitación de responsabilidad"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "4.1:",
                                  "La Institución no será responsable ante usted ni ante ningún tercero por ningún daño directo, indirecto, incidental, especial o consecuente que surja del uso o la imposibilidad de uso de la Aplicación.",
                                ),
                                contenidoPuntos(
                                  "4.2:",
                                  "Esto incluye, pero no se limita a, la pérdida de datos, interrupciones en el servicio, daños al dispositivo móvil o cualquier perjuicio económico derivado de la falta de funcionalidad de la Aplicación.",
                                ),
                                contenidoPuntos(
                                  "4.3:",
                                  "El usuario reconoce que el uso de la Aplicación es bajo su propio riesgo y que la Institución no asume responsabilidad por cualquier decisión tomada basándose en la información mostrada en la misma.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          //INCISO 5
                          tituloSeccion("5. Modificaciones y suspensión"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "5.1: Cambios en la aplicación:",
                                  "Cambios en la Aplicación: La Institución se reserva el derecho de modificar, suspender o descontinuar, temporal o permanentemente, cualquier aspecto de la Aplicación, incluyendo funciones, características o accesos, sin previo aviso.",
                                ),
                                contenidoPuntos(
                                  "5.2 Actualizaciones:",
                                  "La Institución no está obligada a proporcionar actualizaciones, soporte técnico o mantenimiento continuo de la Aplicación.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          //INCISO 6
                          tituloSeccion("6. Propiedad intelectual"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "6.1:",
                                  "La Aplicación, su código, diseño, logotipos y todo el contenido asociado son propiedad exclusiva de la Universidad Tecnológica de Chetumal y están protegidos por las leyes de propiedad intelectual y derechos de autor.",
                                ),
                                contenidoPuntos(
                                  "6.2:",
                                  "No se otorga ningún derecho de propiedad sobre la Aplicación al usuario, salvo el derecho limitado y revocable de usarla conforme a estos términos.",
                                ),
                                contenidoPuntos(
                                  "4.3:",
                                  "El usuario reconoce que el uso de la Aplicación es bajo su propio riesgo y que la Institución no asume responsabilidad por cualquier decisión tomada basándose en la información mostrada en la misma.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          //INCISO 7
                          tituloSeccion("7. Ley aplicable y jurisdicción"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "7.1:",
                                  "Estos Términos y Condiciones se regirán e interpretarán de acuerdo con las leyes de los Estados Unidos Mexicanos.",
                                ),
                                contenidoPuntos(
                                  "7.2:",
                                  "Cualquier controversia derivada de este contrato estará sujeta a la jurisdicción exclusiva de los tribunales competentes en la ciudad de Chetumal, Quintana Roo, renunciando el usuario a cualquier otro fuero que pudiera corresponderle.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          //INCISO 8
                          tituloSeccion("8. Contacto"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Column(
                              children: [
                                contenidoPuntos(
                                  "8.1:",
                                  "Para reportar cualquier incidencia, mal uso o solicitar información sobre el acceso a la Aplicación, el personal autorizado debe contactar a la unidad de tecnología de la Universidad Tecnológica de Chetumal a través de los canales oficiales institucionales.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      const Spacer(), // Empuja el botón hacia abajo si hay espacio
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 200,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);//para regresar a la pantalla anterior
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14A38E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Regresar",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}