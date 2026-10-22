import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Inicialización de la base de datos para la web (usa WebAssembly / IndexedDB).
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
