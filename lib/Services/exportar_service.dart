import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:nexxus/Models/formulario_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportarService {
  static final ExportarService instancia = ExportarService._init();
  ExportarService._init();

  // [NUEVO]: Lista única y centralizada con los 12 encabezados exactos de 'solicitudes_prueba.xlsx'
  static const List<String> _columnasSolicitudes = [
    'nombre',
    'apellido1',
    'apellido2',
    'genero',
    'email',
    'telefono',
    'tel_referencia',
    'tipo_zona',
    'carrera',
    'preparatoria',
    'medio_enterado',
    'nota',
  ];

  // [NUEVO]: Convierte un Prospecto en una fila de 12 valores respetando el orden de 'solicitudes_prueba.xlsx'
  List<String> _mapearFila(Prospecto p) {
    return [
      p.nombre,
      p.apellido1,
      p.apellido2 ?? '',
      p.genero,
      p.email,
      p.telefono,
      p.telReferencia ?? '',
      p.tipoZona,
      p.carrera,
      p.preparatoria,
      p.medioEnterado,
      p.nota ?? '',
    ];
  }

  // Genera el prefijo de fecha y hora para el nombre del archivo
  String _generarPrefijoFecha() {
    final ahora = DateTime.now();
    return "${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}";
  }

  // Comparte o descarga el archivo según la plataforma (Web vs Android)
  Future<void> _compartirArchivo({
    required Uint8List bytes,
    required String nombreArchivo,
    required String mimeType,
    required String subject,
  }) async {
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: nombreArchivo, mimeType: mimeType)],
          subject: subject,
        ),
      );
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$nombreArchivo');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, name: nombreArchivo, mimeType: mimeType)],
          subject: subject,
        ),
      );
    }
  }

  // 1. Exportar a CSV (misma estructura de solicitudes_prueba.xlsx) *************
  Future<void> exportarCSV(List<Prospecto> prospectos) async {
    try {
      final List<List<dynamic>> filas = [
        _columnasSolicitudes,
        ...prospectos.map(_mapearFila),
      ];

      final String csvData = const ListToCsvConverter().convert(filas);
      final String fechaHora = _generarPrefijoFecha();
      final String nombreArchivo = '${fechaHora}_solicitudes_nexxus.csv';

      // UTF-8 con BOM para conservar acentos y ñ al abrirse en Excel
      final csvBytes = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode(csvData),
      ]);

      await _compartirArchivo(
        bytes: csvBytes,
        nombreArchivo: nombreArchivo,
        mimeType: 'text/csv',
        subject: 'Exportación de Solicitudes (CSV)',
      );
    } catch (e) {
      debugPrint("Error exportando archivo CSV: $e");
      rethrow;
    }
  }

  // 2. Exportar a Excel (idéntico a solicitudes_prueba.xlsx) ********************
  Future<void> exportarExcel(List<Prospecto> prospectos) async {
    try {
      final listaOrdenada = List<Prospecto>.from(prospectos)
        ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

      final excel = ex.Excel.createExcel();
      // [MODIFICADO]: La hoja se llama exactamente 'solicitudes' como en solicitudes_prueba.xlsx
      final hoja = excel['solicitudes'];
      excel.delete('Sheet1');

      // [MODIFICADO]: Estilo del encabezado con el verde #1A6B4A de solicitudes_prueba.xlsx
      final headerStyle = ex.CellStyle(
        backgroundColorHex: ex.ExcelColor.fromHexString('#1A6B4A'),
        fontColorHex: ex.ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: ex.HorizontalAlign.Center,
        verticalAlign: ex.VerticalAlign.Center,
      );

      // [NUEVO]: Estilos de filas alternadas (#F0FBF6 y #FFFFFF) igual que solicitudes_prueba.xlsx
      final filaVerdeClaroStyle = ex.CellStyle(
        backgroundColorHex: ex.ExcelColor.fromHexString('#F0FBF6'),
      );
      final filaBlancaStyle = ex.CellStyle(
        backgroundColorHex: ex.ExcelColor.fromHexString('#FFFFFF'),
      );

      // Anchos de columna de solicitudes_prueba.xlsx
      const List<double> anchosColumnas = [
        14.0, 13.0, 13.0, 12.0, 28.0, 14.0, 15.0, 12.0, 28.0, 22.0, 20.0, 32.0
      ];

      // Insertar encabezados y configurar anchos
      for (var col = 0; col < _columnasSolicitudes.length; col++) {
        hoja.setColumnWidth(col, anchosColumnas[col]);
        final celda = hoja.cell(
          ex.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
        );
        celda.value = ex.TextCellValue(_columnasSolicitudes[col]);
        celda.cellStyle = headerStyle;
      }

      // Insertar filas de datos
      for (var i = 0; i < listaOrdenada.length; i++) {
        final valoresFila = _mapearFila(listaOrdenada[i]);
        final indiceFila = i + 1;
        final estiloFila = (i % 2 == 0) ? filaVerdeClaroStyle : filaBlancaStyle;

        for (var col = 0; col < valoresFila.length; col++) {
          final celda = hoja.cell(
            ex.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: indiceFila),
          );
          celda.value = ex.TextCellValue(valoresFila[col]);
          celda.cellStyle = estiloFila;
        }
      }

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final fechaHora = _generarPrefijoFecha();
        final nombreArchivo = '${fechaHora}_solicitudes_nexxus.xlsx';

        await _compartirArchivo(
          bytes: Uint8List.fromList(fileBytes),
          nombreArchivo: nombreArchivo,
          mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          subject: 'Exportación de Solicitudes (Excel)',
        );
      }
    } catch (e) {
      debugPrint("Error exportando a Excel: $e");
      rethrow;
    }
  }

  // 3. Exportar a PDF (con las 12 columnas y colores de solicitudes_prueba.xlsx) *
  Future<void> exportarPDF(List<Prospecto> prospectos) async {
    try {
      final pdf = pw.Document();
      // [MODIFICADO]: Mismo verde #1A6B4A y fondo alternado #F0FBF6 del Excel de prueba
      final colorEncabezado = PdfColor.fromInt(0xFF1A6B4A);
      final colorFilaAlterna = PdfColor.fromInt(0xFFF0FBF6);

      final filas = prospectos.map(_mapearFila).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (context) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: colorEncabezado, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'solicitudes - UT Nexxus',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: colorEncabezado,
                  ),
                ),
                pw.Text(
                  'Total: ${prospectos.length} registros',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headers: _columnasSolicitudes,
              data: filas,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 7.5,
              ),
              headerDecoration: pw.BoxDecoration(color: colorEncabezado),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
              oddRowDecoration: pw.BoxDecoration(color: colorFilaAlterna),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      final fechaHora = _generarPrefijoFecha();
      final nombreArchivo = '${fechaHora}_solicitudes_nexxus.pdf';

      await _compartirArchivo(
        bytes: pdfBytes,
        nombreArchivo: nombreArchivo,
        mimeType: 'application/pdf',
        subject: 'Exportación de Solicitudes (PDF)',
      );
    } catch (e) {
      debugPrint("Error exportando a PDF: $e");
      rethrow;
    }
  }

  // 4. Vista previa (muestra exactamente las mismas 12 columnas antes de exportar)
  List<List<dynamic>> obtenerDatosVistaPrevia(List<Prospecto> prospectos) {
    return [
      _columnasSolicitudes,
      ...prospectos.map(_mapearFila),
    ];
  }
}