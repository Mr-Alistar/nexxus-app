// Guarda el token de autenticación del asesor durante la sesión de la app.
// Es en memoria: al cerrar la app se pierde y hay que volver a iniciar sesión.
class AuthSession {
  static final AuthSession instancia = AuthSession._init();
  AuthSession._init();

  String? _token;
  Map<String, dynamic>? _usuario;

  String? get token => _token;
  Map<String, dynamic>? get usuario => _usuario;
  bool get autenticado => _token != null && _token!.isNotEmpty;

  void guardarSesion(String token, Map<String, dynamic>? usuario) {
    _token = token;
    _usuario = usuario;
  }

  void cerrarSesion() {
    _token = null;
    _usuario = null;
  }
}
