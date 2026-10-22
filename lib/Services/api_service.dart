import 'package:dio/dio.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/Services/auth_session.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService instancia = ApiService._init();
  ApiService._init();

  // URL base del CRM Nexxus (Laravel).
  // - Emulador Android: usar http://10.0.2.2:8000/api
  // - Dispositivo físico / producción: el dominio real del CRM, ej:
  //   https://crmnexxus.datacode.space/api
  static const String _baseUrl = 'http://10.252.0.69:8000/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  // Inicia sesión contra el CRM y guarda el token Sanctum para las
  // siguientes peticiones. Retorna null si todo salió bien, o un mensaje
  // de error listo para mostrar al usuario.
  Future<String?> login(String email, String password) async {
    try {
      final respuesta = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = respuesta.data;
      final token = data is Map ? data['token'] as String? : null;
      if (token == null || token.isEmpty) {
        return 'Respuesta inválida del servidor.';
      }

      AuthSession.instancia.guardarSesion(
        token,
        data['user'] is Map ? Map<String, dynamic>.from(data['user']) : null,
      );
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'Correo o contraseña incorrectos.';
      }
      debugPrint('Error de login: $e');
      return 'No se pudo conectar con el servidor. Verifique su conexión.';
    } catch (e) {
      debugPrint('Error de login: $e');
      return 'Ocurrió un error inesperado al iniciar sesión.';
    }
  }

  // Envía un prospecto al CRM. El id_asesor lo determina el servidor según
  // el token, así que aquí solo mandamos los datos capturados.
  Future<bool> enviarProspecto(Prospecto prospecto) async {
    final token = AuthSession.instancia.token;
    if (token == null || token.isEmpty) {
      debugPrint('No hay sesión activa: inicie sesión antes de subir.');
      return false;
    }

    try {
      final datos = {
        'nombre': prospecto.nombre,
        'apellido1': prospecto.apellido1,
        'apellido2': prospecto.apellido2,
        'genero': prospecto.genero,
        'email': prospecto.email,
        'telefono': prospecto.telefono,
        'tel_referencia': prospecto.telReferencia,
        'tipo_zona': prospecto.tipoZona,
        'carrera': prospecto.carrera,
        'modalidad': prospecto.modalidad,
        'preparatoria': prospecto.preparatoria,
        'medio_enterado': prospecto.medioEnterado,
        'nota': prospecto.nota,
      };

      final respuesta = await _dio.post(
        '/prospectos',
        data: datos,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return respuesta.statusCode == 200 || respuesta.statusCode == 201;
    } catch (e) {
      debugPrint('Error de conexión: $e');
      return false;
    }
  }

  Future<Map<String, int>> subirVariosProspectos(List<Prospecto> lista) async {
    int exitos = 0;
    int fallos = 0;
    for (var p in lista) {
      final resultado = await enviarProspecto(p);
      if (resultado) {
        exitos++;
      } else {
        fallos++;
      }
    }
    return {'exitos': exitos, 'fallos': fallos};
  }
}
