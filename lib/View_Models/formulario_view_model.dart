import 'package:flutter/material.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/Services/formulario_service.dart';

class FormularioViewModel extends ChangeNotifier {
  final Prospecto? prospecto;

  // Controladores, campos que se deben llenar con texto
  late TextEditingController nombreCtrl;
  late TextEditingController apellido1Ctrl;
  late TextEditingController apellido2Ctrl;
  late TextEditingController emailCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController telReferenciaCtrl;
  late TextEditingController notaCtrl;

  // campos de opcipn múltiple
  String? genero;
  String? tipoZona;
  String? carrera;
  String? modalidad;
  String? preparatoria;
  String? medioEnterado;

  bool _cargando = false;
  bool get cargando => _cargando;

  FormularioViewModel({this.prospecto}) {
    nombreCtrl = TextEditingController(text: prospecto?.nombre);
    apellido1Ctrl = TextEditingController(text: prospecto?.apellido1);
    apellido2Ctrl = TextEditingController(text: prospecto?.apellido2);
    emailCtrl = TextEditingController(text: prospecto?.email);
    telefonoCtrl = TextEditingController(text: prospecto?.telefono);
    telReferenciaCtrl = TextEditingController(text: prospecto?.telReferencia);
    notaCtrl = TextEditingController(text: prospecto?.nota);

    if (prospecto != null) {
      genero = prospecto!.genero;
      tipoZona = prospecto!.tipoZona;
      carrera = prospecto!.carrera;
      modalidad = prospecto!.modalidad;
      preparatoria = prospecto!.preparatoria;
      medioEnterado = prospecto!.medioEnterado;
    }
  }

  void setGenero(String? value) {
    genero = value;
    notifyListeners();
  }

  void setTipoZona(String? value) {
    tipoZona = value;
    notifyListeners();
  }

  void setCarrera(String? value) {
    carrera = value;
    notifyListeners();
  }

  void setModalidad(String? value) {
    modalidad = value;
    notifyListeners();
  }

  void setPreparatoria(String? value) {
    preparatoria = value;
    notifyListeners();
  }

  void setMedioEnterado(String? value) {
    medioEnterado = value;
    notifyListeners();
  }

  // Validaciones de que los campos obligatorios (*) no esten vacios
  void validarCampos() {
    if (nombreCtrl.text.trim().isEmpty) throw Exception("El nombre es obligatorio.");
    if (apellido1Ctrl.text.trim().isEmpty) throw Exception("El apellido paterno es obligatorio.");
    if (genero == null || genero!.isEmpty) throw Exception("Debe seleccionar un género.");
    if (emailCtrl.text.trim().isEmpty) throw Exception("Se requiere de un correo electrónico.");
    if (telefonoCtrl.text.trim().isEmpty) throw Exception("Se requiere de un número telefónico.");
    if (tipoZona == null || tipoZona!.isEmpty) throw Exception("Debe seleccionar un tipo de zona.");
    if (carrera == null || carrera!.isEmpty) throw Exception("Debe seleccionar la carrera deseada.");
    if (modalidad == null || modalidad!.isEmpty) throw Exception("Debe seleccionar una modalidad.");
    if (preparatoria == null || preparatoria!.isEmpty) throw Exception("Debe seleccionar una preparatoria.");
    if (medioEnterado == null || medioEnterado!.isEmpty) throw Exception("Debe indicar cómo se enteró de la UT.");
  }

  Future<int> guardarProspecto() async {
    // Validar antes de mostrar carga o intentar guardar
    validarCampos();

    _cargando = true;
    notifyListeners();

    try {
      final nuevoProspecto = Prospecto(
        id: prospecto?.id,
        nombre: nombreCtrl.text.trim(),
        apellido1: apellido1Ctrl.text.trim(),
        apellido2: apellido2Ctrl.text.trim().isEmpty ? null : apellido2Ctrl.text.trim(),//como algunos campos son opcionales, agregué isEmpty ? null : etc..
        genero: genero!,
        email: emailCtrl.text.trim(),
        telefono: telefonoCtrl.text.trim(),
        telReferencia: telReferenciaCtrl.text.trim().isEmpty ? null : telReferenciaCtrl.text.trim(),
        tipoZona: tipoZona!,
        carrera: carrera!,
        modalidad: modalidad!,
        preparatoria: preparatoria!,
        medioEnterado: medioEnterado!,
        nota: notaCtrl.text.trim().isEmpty ? null : notaCtrl.text.trim(),
        idAsesor: prospecto?.idAsesor ?? 1,
        status: prospecto?.status ?? 'sin-contacto',
        createdAt: prospecto?.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      int resultado;
      if (prospecto == null) {
        resultado = await FormularioService.instancia.insertarProspecto(nuevoProspecto);
      } else {
        resultado = await FormularioService.instancia.actualizarProspecto(nuevoProspecto);
      }

      _cargando = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellido1Ctrl.dispose();
    apellido2Ctrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    telReferenciaCtrl.dispose();
    notaCtrl.dispose();
    super.dispose();
  }
}
