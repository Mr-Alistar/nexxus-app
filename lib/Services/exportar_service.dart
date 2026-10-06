import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:nexxus/Models/formulario_model.dart';

class ExportarService {
  static final ExportarService instancia = ExportarService._init();
  ExportarService._init();

  // Exportar a CSV*************************************************************
  Future<void> exportarCSV(List<Prospecto> prospectos) async {
    try {
      List<List<dynamic>> filas = [];
      // El archivo CVS exporta toda la tabla tal cual, en Excel sólo se exportan los campos solicitados
      filas.add(["Nombre", "Apellido 1", "Apellido 2", "Género", "Email", "Teléfono", "Tel.referencia", "Tipo de zona", "Carrera", "Preparatoria", "Medio enterado", "Nota"]);

      for (var p in prospectos) {//use var p de prospectos
        filas.add([
          p.nombre, 
          p.apellido1, 
          p.apellido2 ?? '', //como algunos campos son opcionales, se usa ?? '' para evitar errores
          p.genero,
          p.email,
          p.telefono,
          p.telReferencia ?? '',
          p.tipoZona,
          p.carrera,
          //p.modalidad,
          p.preparatoria,
          p.medioEnterado,
          p.nota ?? '',
        ]);
      }
      // Exportar a CSV
      String csvData = const ListToCsvConverter().convert(filas);

      // opcional, agregué un nombre de archivo con fecha y hora para saber cuando se exporto y evitar duplicados
      final ahora = DateTime.now();
      final fechaHora = "${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}";

      final directory = await getTemporaryDirectory();
      final nombreArchivo = '${fechaHora}_prospectos_nexxus.csv';
      final file = File('${directory.path}/$nombreArchivo');
      await file.writeAsString(csvData, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, name: nombreArchivo, mimeType: 'text/csv')],
          subject: 'Exportación de Prospectos (CSV)',
        ),
      );
    } catch (e) {
      debugPrint("Error exportando archivo CSV: $e");
      rethrow;
    }
  }

  // Exportar a Excel***********************************************************
  Future<void> exportarExcel(List<Prospecto> prospectos) async {
    try {
      // Orden por id, se puede omitir.
      prospectos.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

      var excel = ex.Excel.createExcel();
      var hoja = excel['Prospectos'];
      excel.delete('Sheet1'); // Eliminar la hoja por defecto del Excel

      //Estilo de los títulos de las columnas (verde con texto blanco)
      ex.CellStyle headerStyle = ex.CellStyle(
        backgroundColorHex: ex.ExcelColor.fromHexString('#14A38E'),
        fontColorHex: ex.ExcelColor.fromHexString('#FFFFFF'),
        bold: true,//negritas
        horizontalAlign: ex.HorizontalAlign.Center,
      );

      // Columnas de acuerdo al ejemplo que me enviaron
      List<String> columnas = [
        "Nombre", "Apellido1", "Apellido2", "Género", "Email", 
        "Teléfono", "Tel. referencia", "Tipo de zona", "Carrera", 
        "Preparatoria", "Medio enterado", "Nota"
      ];

      // Llenar encabezados
      for (var i = 0; i < columnas.length; i++) {
        var celda = hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        celda.value = ex.TextCellValue(columnas[i]);
        celda.cellStyle = headerStyle;
      }

      // Llenar con los datos
      for (var i = 0; i < prospectos.length; i++) {
        var p = prospectos[i];
        int indiceFila = i + 1;
        
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indiceFila)).value = ex.TextCellValue(p.nombre);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: indiceFila)).value = ex.TextCellValue(p.apellido1);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: indiceFila)).value = ex.TextCellValue(p.apellido2 ?? '');
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indiceFila)).value = ex.TextCellValue(p.genero);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indiceFila)).value = ex.TextCellValue(p.email);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indiceFila)).value = ex.TextCellValue(p.telefono);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indiceFila)).value = ex.TextCellValue(p.telReferencia ?? '');
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indiceFila)).value = ex.TextCellValue(p.tipoZona);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: indiceFila)).value = ex.TextCellValue(p.carrera);
        //hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indiceFila)).value = ex.TextCellValue(p.modalidad);//habilitar cuando CRM web lo incluya
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indiceFila)).value = ex.TextCellValue(p.preparatoria);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indiceFila)).value = ex.TextCellValue(p.medioEnterado);
        hoja.cell(ex.CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: indiceFila)).value = ex.TextCellValue(p.nota ?? '');
      }

      var fileBytes = excel.save();
      if (fileBytes != null) {
        final ahora = DateTime.now();
        final fechaHora = "${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}";

        final directorio = await getTemporaryDirectory();
        final nombreArchivo = '${fechaHora}_prospectos_nexxus.xlsx';
        final file = File('${directorio.path}/$nombreArchivo');
        await file.writeAsBytes(fileBytes, flush: true);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, name: nombreArchivo, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
            subject: 'Exportación de Prospectos (Excel)',
          ),
        );
      }
    } catch (e) {
      debugPrint("Error exportando a Excel: $e");
      rethrow;
    }
  }

  // función en ExportarService para obtener los datos puros de sqlite (vista previa)
  List<List<dynamic>> obtenerDatosVistaPrevia(List<Prospecto> prospectos) {
    List<List<dynamic>> filas = [
      ["Nombre", "Apellido 1", "Apellido 2", "Género", "Email", "Teléfono", "Carrera", "Nota"]
    ];
    for (var p in prospectos) {
      filas.add([p.nombre, p.apellido1, p.apellido2 ?? '', p.genero, p.email, p.telefono, p.carrera, p.nota ?? '']);
    }
    return filas;
  }
}
