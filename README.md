# UT Nexxus — App Móvil (Flutter)

App móvil del CRM **Nexxus** de la Universidad Tecnológica de Chetumal. Permite a los
asesores de admisiones **capturar prospectos sin conexión** (se guardan en una base de
datos local) y luego **subirlos al CRM** cuando hay internet. También incluye un mapa
interactivo con información de las carreras.

> El backend (API + base de datos) vive en un proyecto Laravel aparte (`crm-nexxus`).
> Esta app lo consume vía HTTP.

---

## 1. Requisitos previos

| Herramienta | Versión recomendada | Notas |
|---|---|---|
| **Flutter SDK** | 3.47.x (canal stable) | Incluye Dart. `flutter --version` |
| **Dart** | ≥ 3.12.1 | Viene con Flutter |
| **Git** | cualquiera reciente | Para clonar el repo |
| **Android Studio** o **VS Code** | — | Con el plugin de Flutter/Dart |
| **Android SDK** | API 21+ | Para compilar/emular Android |
| **Chrome** | — | Opcional, para correr en web |

Verifica que todo esté bien configurado con:

```bash
flutter doctor
```

Resuelve cualquier ❌ que aparezca (SDK de Android, licencias, etc.) antes de continuar.

---

## 2. Clonar el repositorio

```bash
git clone https://github.com/Mr-Alistar/nexxus-app.git
cd nexxus-app
```

---

## 3. Instalar dependencias

```bash
flutter pub get
```

Esto descarga los paquetes definidos en `pubspec.yaml` (dio, sqflite, flutter_svg,
excel, csv, share_plus, etc.).

### 3.1 Solo si vas a correr en **Web** (paso extra, una vez)

La base de datos usa `sqflite`, que en web necesita WebAssembly. Genera los archivos
necesarios dentro de `web/`:

```bash
dart run sqflite_common_ffi_web:setup
```

> Esto crea `web/sqlite3.wasm` y `web/sqflite_sw.js`. En Android/iOS/escritorio **no**
> hace falta.

---

## 4. Configurar la conexión al backend (CRM)

La URL de la API está en:

**`lib/Services/api_service.dart`**

```dart
static const String _baseUrl = 'http://10.252.0.69:8000/api';
```

Cámbiala según dónde corras el CRM Laravel:

| Escenario | URL a usar |
|---|---|
| Emulador Android + CRM local | `http://10.0.2.2:8000/api` |
| Dispositivo físico + CRM en tu PC | `http://<IP-de-tu-PC>:8000/api` |
| Producción | `https://<dominio-del-crm>/api` |

> El CRM debe estar corriendo (`php artisan serve`) y tener al menos un usuario
> **asesor** y los catálogos sembrados (`php artisan migrate --seed`).

---

## 5. Ejecutar la app

Lista los dispositivos disponibles:

```bash
flutter devices
```

Corre en el dispositivo que quieras:

```bash
# Android (emulador o físico conectado)
flutter run

# Especificando dispositivo
flutter run -d <id-del-dispositivo>

# Web (ver nota de abajo)
flutter run -d chrome
```

**Nota web:** si `flutter run -d chrome` falla con
`Failed to establish connection with the web debug service: TimeoutException`,
es un problema del *debug service*, no del código. Alternativas:

```bash
flutter run -d web-server --web-port 8080   # y abre http://localhost:8080 manualmente
```

### Comandos útiles durante `flutter run`
- `r` → hot reload
- `R` → hot restart
- `q` → salir

### Compilar para producción
```bash
flutter build apk        # Android (APK)
flutter build appbundle  # Android (Play Store)
flutter build web         # Web
```

---

## 6. Estructura del proyecto

```
nexxus-app/
├── Assets/                      # Imágenes, logos e imágenes de carreras
│   ├── Generales/               # Logo e ícono de Nexxus
│   ├── Carreras/                # Mapa y botones de carreras
│   └── Images/                  # Fotos por carrera (G, DIA, IM, IF, TIID, NM)
├── lib/                         # Código Dart (ver detalle abajo)
├── web/                         # Archivos web (incluye sqlite3.wasm tras el setup)
├── android/ ios/ web/ windows/ linux/ macos/   # Proyectos nativos por plataforma
├── pubspec.yaml                 # Dependencias y assets
└── README.md
```

### Dentro de `lib/` (arquitectura MVVM)

```
lib/
├── main.dart                        # Punto de entrada. Inicializa la BD y las rutas.
│
├── Models/                          # Modelos de datos
│   ├── formulario_model.dart        # Prospecto (aspirante)
│   ├── formulario_opciones.dart     # Listas de opciones (género, carreras, etc.)
│   └── carrera_model.dart           # CarreraModel (info y fotos de carrera)
│
├── Services/                        # Lógica de datos / acceso externo
│   ├── formulario_service.dart      # Base de datos local SQLite (prospectos, carreras)
│   ├── api_service.dart             # Conexión al CRM (login + subir prospectos)
│   ├── auth_session.dart            # Token de sesión del asesor (en memoria)
│   ├── carrera_service.dart         # Datos locales/fallback de carreras
│   ├── exportar_service.dart        # Exportar prospectos a CSV / Excel
│   ├── db_init.dart                 # Selector de BD por plataforma (web/nativo)
│   ├── db_init_native.dart          # Init BD en móvil/escritorio (FFI)
│   └── db_init_web.dart             # Init BD en web (WebAssembly)
│
├── View_Models/                     # Estado y lógica de cada pantalla (ChangeNotifier)
│   ├── dashboard_view_model.dart    # Pestaña activa del dashboard
│   ├── formulario_view_model.dart   # Validación y guardado del formulario
│   └── prospectos_locales_view_model.dart  # Lista/editar/eliminar/subir prospectos
│
├── Views/                           # Pantallas (UI) — ver tabla abajo
│
└── Widgets/                         # Componentes reutilizables
    ├── widgets_generales.dart       # Botones, decoraciones, textos comunes
    └── Dialogos/
        └── vista_previa.dart        # Modal de vista previa antes de exportar
```

---

## 7. ¿Dónde está cada pantalla?

Todas las pantallas están en **`lib/Views/`**:

| Pantalla | Archivo | Qué hace |
|---|---|---|
| **Splash** | `splash_screen.dart` | Animación de arranque y navega a Inicio. |
| **Inicio (bienvenida)** | `inicio_screen.dart` | Menú principal: Formulario, Mapa, Login, Términos. |
| **Términos** | `terminos_screen.dart` | Términos y aviso de privacidad. |
| **Login** | `login_screen.dart` | Inicio de sesión del asesor (consume `/api/login`). |
| **Recuperar contraseña** | `recuperar_screen.dart` | Captura el correo (flujo sin backend aún). |
| **Verificar código** | `verificar_screen.dart` | Captura el código (sin backend aún). |
| **Nueva contraseña** | `guardar_password_screen.dart` | Nueva contraseña (sin backend aún). |
| **Formulario de prospecto** | `formulario_screen.dart` | Alta/edición de aspirantes (guarda en SQLite). |
| **Dashboard (contenedor)** | `dashboard_screen.dart` | Barra inferior: Inicio · Registrados · Salir. |
| **Inicio / Dashboard (stats)** | `inicio_dashboard_screen.dart` | Panel de estadísticas (solo vista, datos de ejemplo). |
| **Registrados** | `prospectos_locales_screen.dart` | Lista local: buscar, editar, eliminar, subir, exportar. |
| **Mapa interactivo** | `mapa_screen.dart` | Mapa con botones por carrera. |
| **Carrera (galería)** | `carrera_screen.dart` | Fotos + accesos a "Acerca" y "Plan". |
| **Acerca de la carrera** | `acerca_screen.dart` | Descripción de la carrera. |
| **Plan de estudios** | `plan_screen.dart` | Plan de estudios de la carrera. |

---

## 8. Flujo de la aplicación (resumen)

```
Splash → Inicio
          ├── Aspirantes → Formulario  (guarda prospecto en SQLite)
          ├── Mapa → Carrera → Acerca / Plan
          └── Asesores → Login → Dashboard
                                   ├── Inicio (estadísticas)
                                   ├── Registrados (lista local → Subir al CRM)
                                   └── Salir (cierra sesión)
```

- Los prospectos se **guardan localmente** (SQLite) aunque no haya internet.
- En **Registrados** se pueden **subir al CRM** (requiere haber iniciado sesión) y
  **exportar** (CSV / Excel / PDF).

---

## 9. Problemas comunes

| Problema | Causa / Solución |
|---|---|
| `databaseFactory not initialized` | Corriendo en web/escritorio sin el setup. Ejecuta el paso 3.1 y reinicia en frío. |
| Login falla / "No se pudo conectar" | El CRM no está corriendo o la `_baseUrl` es incorrecta. Revisa el paso 4. |
| Error de debug service en Chrome | Usa `flutter run -d web-server` (paso 5). |
| El formulario dice que falta un campo | Campos con `*` son obligatorios (incluye Correo y Teléfono). |
```
