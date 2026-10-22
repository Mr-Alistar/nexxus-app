// Selecciona la implementación correcta según la plataforma de compilación:
// - En web se usa db_init_web.dart (FFI web / WebAssembly).
// - En móvil y escritorio se usa db_init_native.dart.
// Así el código de sqflite_common_ffi (que usa dart:ffi) nunca se compila en web.
import 'db_init_native.dart'
    if (dart.library.js_interop) 'db_init_web.dart' as impl;

void initDatabaseFactory() => impl.initDatabaseFactory();
