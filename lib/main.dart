import 'package:flutter/material.dart';

import 'package:nexxus/Views/splash_screen.dart';
import 'package:nexxus/Views/inicio_screen.dart';
import 'package:nexxus/Views/terminos_screen.dart';
import 'package:nexxus/Views/login_screen.dart';
import 'package:nexxus/Views/recuperar_screen.dart';
import 'package:nexxus/Views/verificar_screen.dart';
import 'package:nexxus/Views/plan_screen.dart';
import 'package:nexxus/Views/guardar_password_screen.dart';
import 'package:nexxus/Views/mapa_screen.dart';
import 'package:nexxus/Views/carrera_screen.dart';
import 'package:nexxus/Views/acerca_screen.dart';
import 'package:nexxus/Views/dashboard_screen.dart';

void main() {
  // inicio minimo requerido para arrancar flutter
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexxus Móvil',
      home: const SplashScreen(),
      routes: {
        '/Inicio': (context) => const InicioScreen(),
        '/Terminos': (context) => const TerminosScreen(),
        '/Login': (context) => const LoginScreen(),
        '/Recuperar': (context) => const RecuperarScreen(),
        '/Verificar': (context) => const VerificarScreen(),
        '/Plan': (context) => const PlanScreen(carrera: '',),
        '/GuardarPassword': (context) => const GuardarPasswordScreen(),
        '/Mapa': (context) => const MapaScreen(),
        '/Acerca': (context) => const AcercaScreen(carrera: '',),
        '/Carrera': (context) => const CarreraScreen(carrera: '',),
        '/Dashboard': (context) => const DashboardScreen(),
      },
      theme: ThemeData(
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14A38E),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
