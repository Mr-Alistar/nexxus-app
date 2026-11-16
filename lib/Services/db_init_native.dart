import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Inicialización de la base de datos para plataformas NO-web.
// - Android / iOS: usan el sqflite nativo, no hay que hacer nada.
// - Windows / Linux / macOS (escritorio): requieren el factory FFI.
void initDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
