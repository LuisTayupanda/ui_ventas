import 'package:exploraec/controllers/productos_controller.dart';
import 'package:get/get.dart';

import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';
import '../screens/gastos_screen.dart';
import 'gastos_controller.dart';
import '../screens/ventas_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  AuthController({ApiClient? api, SecureTokenStorage? almacen})
      : _api = api ?? Get.find<ApiClient>(),
        _almacen = almacen ?? SecureTokenStorage();

  final ApiClient _api;
  final SecureTokenStorage _almacen;

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  final RxBool cargando = false.obs;

  /// `true` mientras se comprueba el token guardado al abrir la app.
  final RxBool restaurando = false.obs;

  /// Error del último intento de registro o inicio de sesión.
  final RxString mensajeError = ''.obs;

  /// Aviso que se muestra donde pide iniciar sesión (por ejemplo, «caducó»).
  final RxString avisoSesion = ''.obs;

  bool get estaAutenticado => usuario.value != null;

  @override
  void onInit() {
    super.onInit();
    _api.alSesionCaducada = sesionCaducada;
    restaurarSesion();
  }

  Future<void> registrar(String email, String password) async {
    cargando.value = true;
    mensajeError.value = '';
    try {
      await _api
          .post('/usuarios/', data: {'email': email, 'password': password});
      await iniciarSesion(email, password);
      //Get.offAll(() => const LoginScreen());
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
    } finally {
      cargando.value = false;
    }
  }

  /// POST /usuarios/token — OJO: `application/x-www-form-urlencoded`, no JSON.
  /// El campo se llama `username` pero lleva el correo.
  Future<void> iniciarSesion(String email, String password) async {
    cargando.value = true;
    mensajeError.value = '';
    try {
      final r = await _api.post(
        '/usuarios/token',
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final token = (r.data as Map)['access_token'] as String;
      _api.token = token;
      await _almacen.guardar(token);
      await cargarUsuario();
      Get.offAll(() => const VentasScreen());
      //Get.offAll(() => const GastosScreen());
      avisoSesion.value = '';
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
    } finally {
      cargando.value = false;
    }
  }

  Future<void> restaurarSesion() async {
    restaurando.value = true;
    try {
      final guardado = await _almacen.leer();
      if (guardado == null) return;
      _api.token = guardado;
      await cargarUsuario();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await cerrarSesion();
        avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';
      } else {
        avisoSesion.value = e.mensaje;
      }
    } finally {
      restaurando.value = false;
    }
  }

  Future<void> sesionCaducada() async {
    await cerrarSesion();
    avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';

    if (Get.key.currentState != null) Get.until((ruta) => ruta.isFirst);
  }

  /// Borra el token (seguro y en memoria) y deja la sesión cerrada.
  Future<void> cerrarSesion() async {
    await _almacen.borrar();
    _api.token = null;
    usuario.value = null;
    Get.offAll(() => const LoginScreen());
  }

  Future<void> cambiarPassword(String actual, String nueva) async {
    cargando.value = true;
    mensajeError.value = '';
    try {
      await _api.put('/usuarios/me/password',
          data: {'password_actual': actual, 'password_nueva': nueva});
      await cerrarSesion();
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
    } finally {
      cargando.value = false;
    }
  }

  Future<void> cargarUsuario() async {
    final r = await _api.get('/usuarios/me');
    usuario.value = Usuario.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  void invalidarTokenParaPruebas() => _api.token = 'token-invalido';
}
