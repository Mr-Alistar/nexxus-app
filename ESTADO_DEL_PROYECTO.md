# Estado actual del proyecto — UT Nexxus App (contexto para IA)

> Este documento resume el estado del proyecto para dárselo a una IA (ChatGPT, Claude,
> etc.) y que tenga contexto completo antes de ayudar. Pégalo o adjúntalo al inicio de
> la conversación.

---

## 1. Qué es el proyecto

App móvil en **Flutter** (Dart) para el CRM **Nexxus** de la Universidad Tecnológica de
Chetumal. Objetivo principal: que los **asesores de admisiones** capturen **prospectos
(aspirantes)** incluso **sin conexión**, guardándolos en una **base de datos local
(SQLite)**, y luego los **suban a un backend CRM** cuando haya internet.

- **Plataforma objetivo real:** Android. También compila en web y escritorio (para
  pruebas).
- **Arquitectura:** MVVM (Models / Views / View_Models / Services / Widgets).
- **Gestión de estado:** `ChangeNotifier` + `ListenableBuilder` (sin paquetes externos
  de estado como Provider o Riverpod).
- **Backend:** proyecto **Laravel** separado llamado `crm-nexxus` (API REST + MySQL +
  Sanctum para tokens). Esta app solo lo consume por HTTP con **dio**.

---

## 2. Stack y dependencias clave

- Flutter 3.47.x / Dart ≥ 3.12.1
- `dio` — peticiones HTTP al CRM
- `sqflite` + `sqflite_common_ffi` + `sqflite_common_ffi_web` — base de datos local
  (nativo, escritorio y web respectivamente)
- `path`, `path_provider` — rutas de archivos
- `flutter_svg` — logos SVG
- `google_fonts`
- `csv`, `excel`, `share_plus`, `file_selector` — exportación de datos
- `url_launcher`

---

## 3. Estructura de carpetas (lib/)

```
lib/
├── main.dart                 # Entry point: inicializa BD por plataforma + rutas + tema
├── Models/
│   ├── formulario_model.dart        # class Prospecto
│   ├── formulario_opciones.dart     # listas const de opciones (deben coincidir con catálogos del CRM)
│   └── carrera_model.dart           # class CarreraModel
├── Services/
│   ├── formulario_service.dart      # SQLite: tablas 'prospectos' y 'carreras' (singleton)
│   ├── api_service.dart             # login() y enviarProspecto() al CRM
│   ├── auth_session.dart            # guarda token Sanctum EN MEMORIA
│   ├── carrera_service.dart         # info local/fallback de carreras (ya NO sincroniza por red)
│   ├── exportar_service.dart        # CSV / Excel
│   ├── db_init.dart / db_init_native.dart / db_init_web.dart  # init BD condicional por plataforma
├── View_Models/
│   ├── dashboard_view_model.dart            # índice de pestaña activa
│   ├── formulario_view_model.dart           # validación + guardado del formulario
│   └── prospectos_locales_view_model.dart   # cargar/editar/eliminar/subir prospectos
├── Views/                    # (ver tabla en el README)
└── Widgets/
    ├── widgets_generales.dart
    └── Dialogos/vista_previa.dart
```

---

## 4. Modelo de datos (Prospecto)

`lib/Models/formulario_model.dart`. Campos:

- `id` (int?, autoincrement local)
- `nombre`, `apellido1`, `apellido2?`
- `genero`, `email`, `telefono`, `telReferencia?`
- `tipoZona`, `carrera`, `modalidad`, `preparatoria`, `medioEnterado`
- `nota?`
- `status` (default `'sin-contacto'`), `idAsesor` (default 1)
- `createdAt?`, `updatedAt?`

La BD local SQLite (`formulario_service.dart`) tiene las tablas `prospectos` y
`carreras`.

---

## 5. Integración con el backend (CRM Laravel)

- URL base en `lib/Services/api_service.dart` → `_baseUrl` (actualmente una IP local
  `http://10.252.0.69:8000/api`).
- **Login:** `POST /api/login` → devuelve `{ token, user }`. El token se guarda en
  `AuthSession` (en memoria; se pierde al cerrar la app).
- **Subir prospecto:** `POST /api/prospectos` (requiere header
  `Authorization: Bearer <token>`). El `id_asesor` lo determina el servidor según el
  token. La app envía los catálogos como **texto** (nombre) y el backend los resuelve a
  IDs.
- **IMPORTANTE:** los nombres de `género`, `carrera`, `modalidad` y `preparatoria` en
  `formulario_opciones.dart` deben coincidir EXACTAMENTE con los catálogos del CRM
  (tablas `generos`, `carreras`, `modalidades`, `preparatorias`), porque la API los
  busca por nombre.

### En el proyecto CRM (crm-nexxus) ya existe:
- `routes/api.php`: `POST /api/login`, `POST /api/prospectos` (protegida con
  `auth:sanctum`), `GET /api/solicitudes`, `POST /api/notificar-asesores`.
- `app/Http/Controllers/Api/ProspectoController.php`: valida, traduce nombres→IDs,
  valida disponibilidad de modalidad por carrera y crea el prospecto.

---

## 6. Qué funciona hoy

- ✅ Captura de prospectos y **guardado local en SQLite** (incluye web/escritorio, con
  el factory FFI ya inicializado en `main.dart`).
- ✅ **Validación** del formulario con mensaje específico del campo que falta.
- ✅ Sección **Registrados**: listar, **buscar**, **editar**, **eliminar** prospectos
  locales.
- ✅ **Subir** prospectos al CRM (si hay sesión iniciada).
- ✅ **Login** real contra el CRM (token Sanctum).
- ✅ **Mapa** de carreras + pantallas Acerca/Plan (con datos locales empaquetados).
- ✅ Rediseño visual (estilo Material 3, paleta teal/esmeralda) en Registrados, el
  navbar inferior y el dashboard de Inicio.

---

## 7. Qué está pendiente / incompleto

- ⚠️ **Dashboard de Inicio (`inicio_dashboard_screen.dart`)**: es **solo vista**, con
  **datos de ejemplo estáticos** (142, 6, etc.). No está conectado a datos reales.
- ⚠️ **Exportar en Registrados**: el botón "Exportar" muestra opciones **Excel / CSV /
  PDF** pero **sin funcionalidad** (solo UI). Nota: existe `exportar_service.dart` con
  CSV y Excel ya implementados que podrían reconectarse; **PDF no está implementado**.
- ⚠️ **Flujo de recuperación de contraseña** (`recuperar_screen`, `verificar_screen`,
  `guardar_password_screen`): solo UI, **sin backend** (no hay endpoints).
- ⚠️ **Sesión en memoria**: al cerrar la app hay que volver a iniciar sesión (no se
  persiste el token; se podría agregar `flutter_secure_storage`).
- ⚠️ La sincronización remota de info de carreras se **retiró**; la app usa datos
  locales/fallback.
- ⚠️ El botón "Subir todo" del dashboard de Inicio no hace nada (es parte de la vista
  estática).

---

## 8. Notas importantes para quien continúe

- **Base de datos por plataforma:** `main.dart` llama a `initDatabaseFactory()`. En web
  requiere ejecutar una vez `dart run sqflite_common_ffi_web:setup` (genera archivos en
  `web/`). En Android/iOS es `sqflite` nativo.
- **Web vs móvil:** la BD local vive en IndexedDB (web) o en el dispositivo (móvil); son
  almacenes distintos, los registros no se comparten entre plataformas.
- **No hay tests automatizados** relevantes aún.
- **Gestión de estado** simple con `ChangeNotifier`; mantener ese patrón al agregar
  features.
- Al **agregar o cambiar opciones** de catálogos en el formulario, sincronizar los
  nombres con el CRM.

---

## 9. Ideas de siguientes pasos (sugeridas)

1. Conectar el dashboard de Inicio a datos reales (agregaciones de la BD local).
2. Implementar la exportación a **PDF** y reconectar CSV/Excel al botón nuevo.
3. Persistir el token de sesión (recordar sesión).
4. Completar el flujo de recuperación de contraseña (requiere endpoints en el CRM).
5. Manejo de errores/estados de red más robusto al subir prospectos (reintentos, marcar
   los ya subidos y limpiarlos de la BD local).
