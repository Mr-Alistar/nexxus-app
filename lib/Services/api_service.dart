import 'package:dio/dio.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService instancia = ApiService._init();
  ApiService._init();

  final Dio _dio = Dio();
  final String _urlApi = 'https://nexxusapi.datacode.space/apis/api_carreras.php';

  Future<bool> enviarProspecto(Prospecto prospecto) async {
    try {
      final Map<String, dynamic> datos = prospecto.toMap();

      // Campos que se remueven antes de enviar al hosting
      //estos se habilitaran en un futuro dependiendo de CRM Nexxus
      datos.remove('id');
      datos.remove('modalidad');
      datos.remove('id_asesor');
      datos.remove('updated_at');
      datos.remove('status');

      final respuesta = await _dio.post(
        _urlApi,
        data: datos,
        options: Options(headers: {'Content-Type': 'application/json'}),
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