import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexxus/Models/formulario_opciones.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:nexxus/View_Models/formulario_view_model.dart';
import 'package:nexxus/Widgets/widgets_generales.dart';

class FormularioScreen extends StatefulWidget {
  final Prospecto? prospecto;
  const FormularioScreen({super.key, this.prospecto});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  late FormularioViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FormularioViewModel(prospecto: widget.prospecto);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _procesarGuardado() async {
    try {
      final resultado = await _viewModel.guardarProspecto();
      if (mounted) {
        if (resultado > 0) {
          _mostrarModalResultado(
            titulo: "Éxito",
            mensaje: widget.prospecto == null 
                ? "Prospecto registrado correctamente." 
                : "Prospecto actualizado correctamente.",
            esExito: true,
          );
        } else {
          _mostrarModalResultado(
            titulo: "Error",
            mensaje: "No se pudo realizar la operación. Contacte al personal de Nexxus.",
            esExito: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Mostramos el mensaje específico del campo que falta (viene de
        // validarCampos), en lugar de un texto genérico.
        _mostrarModalResultado(
          titulo: "Formulario incompleto",
          mensaje: e.toString().replaceFirst("Exception: ", ""),
          esExito: false,
        );
      }
    }
  }

  void _mostrarModalResultado({
    required String titulo,
    required String mensaje,
    required bool esExito,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(mensaje),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              if (esExito) {
                Navigator.pop(context, true); 
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: esExito ? const Color(0xFF14A38E) : Colors.redAccent,
            ),
            child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.prospecto != null; // Si existe el prospecto, entonces se trata de una edicion.

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: Text(esEdicion ? "Editar Prospecto" : "Registro de Prospecto",
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(esEdicion ? "Modifique los datos del prospecto:" : "Ingrese los datos del prospecto:",
                            style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                      const SizedBox(height: 30),

                      //campo Nombre
                      const Text("Nombre(s) *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _viewModel.nombreCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50), //limite de caracteres del campo
                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$')),//filtro para solo letras en este campo
                        ],
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(hintText: "Ej. Juan José"),
                      ),
                      const SizedBox(height: 20),

                      //campos Apellidos
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Apellido paterno *", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _viewModel.apellido1Ctrl,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50), //limite de caracteres del campo
                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$')),//filtro para solo letras en este campo
                                  ],
                                  decoration: const InputDecoration(hintText: "Ej. Pérez"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Apellido materno", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _viewModel.apellido2Ctrl,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50), //limite de caracteres del campo
                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$')),//filtro para solo letras en este campo
                                  ],
                                  decoration: const InputDecoration(hintText: "Ej. García"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // campos genero y zona
                      const Text("Género *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: decoracionCampos,
                        hint: const Text("Seleccione una opción"),
                        initialValue: _viewModel.genero,
                        items: opcionesGenero.map((String value) {
                          return DropdownMenuItem(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _viewModel.setGenero,
                      ),
                      const SizedBox(height: 20),

                      const Text("Tipo de zona *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: decoracionCampos,
                        hint: const Text("Seleccione una opción"),
                        initialValue: _viewModel.tipoZona,
                        items: opcionesTipoZona.map((String value) {
                          return DropdownMenuItem(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _viewModel.setTipoZona,
                      ),
                      const SizedBox(height: 20),

                      // campo Email (me falta validar que sea un correo válido con arroba etc)
                      const Text("Correo electrónico *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _viewModel.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')), //para bloquear espacios
                        ],
                        decoration: const InputDecoration(hintText: "Ej. micorreo@gmail.com"),
                      ),
                      const SizedBox(height: 20),

                      // campo Telefonos
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Teléfono *", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _viewModel.telefonoCtrl,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],//digits only para evitar letras en este campo
                                  decoration: const InputDecoration(hintText: "Ej. 983..."),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Tel. de referencia", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _viewModel.telReferenciaCtrl,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(hintText: "Opcional"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // otros campos de opcion multiple
                      const Text("Preparatoria de procedencia *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: decoracionCampos,
                        hint: const Text("Seleccione una opción"),
                        initialValue: _viewModel.preparatoria,
                        items: opcionesPreparatoria.map((String value) {
                          return DropdownMenuItem(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _viewModel.setPreparatoria,
                      ),
                      const SizedBox(height: 20),

                      const Text("Licenciatura/Ingeniería deseada *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: decoracionCampos,
                        initialValue: _viewModel.carrera,
                        items: opcionesCarrera.map((String value) {
                          return DropdownMenuItem(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _viewModel.setCarrera,
                      ),
                      const SizedBox(height: 20),

                      const Text("Modalidad *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: decoracionCampos,
                        initialValue: _viewModel.modalidad,
                        items: opcionesModalidad.map((String value){
                          return DropdownMenuItem(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _viewModel.setModalidad,
                      ),
                      const SizedBox(height: 20),

                      const Text("¿Cómo se enteró de la UT? *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: decoracionCampos,
                        initialValue: _viewModel.medioEnterado,
                        items: opcionesMedioEnterado.map((String value){
                          return DropdownMenuItem(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _viewModel.setMedioEnterado,
                      ),
                      const SizedBox(height: 20),

                      // Notas
                      const Text("Nota", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _viewModel.notaCtrl,
                        maxLines: 4,//altura del campo
                        maxLength: 200,//se usa si se requiere mostrar en la vista, el limite de caracteres permitidos para la nota
                        decoration: InputDecoration(
                          hintText: 'Observaciones adicionales...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Botones
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: botonesVerdes(esEdicion ? "Actualizar" : "Registrar", () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            //modalPrivacidad(context);
                            try {
                              //Validar primero si los campos obligatorios estan completos
                              _viewModel.validarCampos();

                              //Si es valido, se muestra el aviso de la UT simplificado
                              modalPrivacidad(context);
                            } catch (e) {
                              //Si hay error, popup para informar al usuario, se omite mostrar el aviso de privacidad obiamente.
                              _mostrarModalResultado(
                                titulo: "Formulario incompleto",
                                mensaje: e.toString().replaceFirst("Exception: ", ""),
                                esExito: false,
                              );
                            }
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A38E)),
                            child: const Text("Regresar", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                if (_viewModel.cargando)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      }
    );
  }

  void modalPrivacidad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Aviso de Privacidad simplificado"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tituloSeccion("Solicitudes de acceso a la información."),
              contenidoSeccion(
                "La Universidad Tecnológica de Chetumal (UTCHETUMAL) es la responsable del tratamiento de los datos personales que nos proporcione. los mismos serán tratados con la finalidad de registrar y auxiliar en la elaboración de solicitudes de acceso a la información; Recibir, dar trámite y respuesta a las solicitudes de acceso a la información: Facilitar la captura de las solicitudes de información.",
              ),
              const SizedBox(height: 20),
              contenidoSeccion(
                "Los datos personales que nos proporcione. serán protegidos de conformidad a lo dispuesto por la Ley General de Protección de Datos Personales en Posesión de Sujetos Obligados. la Ley de Protección de Datos Personales en Posesión de Sujetos Obligados del Estado de Quintana Roo. y demás normatividad que resulte aplicable.",
              ),
              const SizedBox(height: 20),
              contenidoSeccion(
                "Usted podrá consultar el aviso de privacidad integral en la Universidad Tecnológica de Chetumal. con domicilio Av. Instituto Politécnico Nacional. S/N. Lote 170, Subteniente López, Quintana Roo.. 0 mediante la siguiente liga electrónica: http://www.utchetumaLedu.mx/index/datos-pesonales/avisos—de-privacidad/.",
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
              _procesarGuardado(); 
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A38E)),
            child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
