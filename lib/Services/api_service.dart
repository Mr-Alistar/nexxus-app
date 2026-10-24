import 'package:dio/dio.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/Services/auth_session.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService instancia = ApiService._init();
  ApiService._init();

  // URL base del CRM Nexxus (Laravel).
  // - Emulador Android: usar http://10.0.2.2:8000/api
  // - Dispositivo físico / producción: usar la IP local de tu PC o dominio real
  static const String _baseUrl = 'http://192.168.1.71:8000/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

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

  // [NUEVO]: Envía un registro a '/solicitudes' y devuelve el estado exacto:
  // - 'creado': Se guardó como nuevo en el CRM (HTTP 201).
  // - 'duplicado': Ya existía en el CRM (ej. importado por Excel) y fue omitido (HTTP 200 con duplicado: true).
  // - 'error': Falló la conexión o la validación.
  Future<String> enviarSolicitud(Prospecto prospecto) async {
    final token = AuthSession.instancia.token;
    if (token == null || token.isEmpty) {
      debugPrint('No hay sesión activa: inicie sesión antes de subir.');
      return 'error';
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
        '/solicitudes',
        data: datos,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        final data = respuesta.data;
        if (data is Map && data['duplicado'] == true) {
          return 'duplicado';
        }
        return 'creado';
      }
      return 'error';
    } on DioException catch (e) {
      debugPrint(
        'Error HTTP al subir solicitud (${e.response?.statusCode}): ${e.response?.data}',
      );
      return 'error';
    } catch (e) {
      debugPrint('Error de conexión: $e');
      return 'error';
    }
  }

  // Se mantiene por compatibilidad
  Future<bool> enviarProspecto(Prospecto prospecto) async {
    final estado = await enviarSolicitud(prospecto);
    return estado == 'creado' || estado == 'duplicado';
  }

  Future<Map<String, int>> subirVariosProspectos(List<Prospecto> lista) async {
    int exitos = 0;
    int duplicados = 0;
    int fallos = 0;
    for (var p in lista) {
      final estado = await enviarSolicitud(p);
      if (estado == 'creado') {
        exitos++;
      } else if (estado == 'duplicado') {
        duplicados++;
      } else {
        fallos++;
      }
    }
    return {'exitos': exitos, 'duplicados': duplicados, 'fallos': fallos};
  }
}