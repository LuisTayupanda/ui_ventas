import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

//import '../models/place.dart';
import '../services/location_service.dart';
import '../models/productos.dart';

enum EstadoCarga { cargando, exito, error }

class ProductosController extends GetxController {
  final RxList<Producto> productos = <Producto>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.cargando.obs;
  final RxString mensajeError = ''.obs;
  final Rx<Position?> posicion = Rx<Position?>(null);
  final Rx<EstadoCarga> estadoPosicion = EstadoCarga.cargando.obs;
  final RxString mensajeErrorPosicion = ''.obs;

  int get total => productos.length;

  var productosFavoritos = <Producto>[].obs;

  void _observarErrores() {
    ever(estado, (EstadoCarga e) {
      if (e == EstadoCarga.error) {
        Get.snackbar('Error', mensajeError.value);
      }
    });
  }

  bool _modoDebugError = false;
  bool _modoDebugVacio = false;

  @override
  void onInit() {
    /*  _observarErrores();
    super.onInit();
    favoritos.value = _favoritosBox.values
        .map((mapa) => Producto.fromMap(Map<String, dynamic>.from(mapa)))
        .toList();
    cargarProductos();*/
    _observarErrores();
    super.onInit();

    // CONTROL DE EXCEPCIONES: Evita que la app falle si la BD local está vacía
    try {
      if (_favoritosBox.isNotEmpty) {
        favoritos.value = _favoritosBox.values
            .map((mapa) => Producto.fromMap(Map<String, dynamic>.from(mapa)))
            .toList();
      }
    } catch (e) {
      print("Error al cargar favoritos locales: $e");
    }

    // Ahora se ejecutará sin interrupciones
    cargarProductos();
  }

  void simular(String modo) {
    _modoDebugError = modo == 'error';
    _modoDebugVacio = modo == 'vacio';
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    estado.value = EstadoCarga.cargando;
    try {
      final resultado = await fetchProductosSimulado(
        forzarError: _modoDebugError,
        forzarVacio: _modoDebugVacio,
      );

      productos.assignAll(resultado);
      estado.value = EstadoCarga.exito;
    } catch (e) {
      mensajeError.value = '$e';
      estado.value = EstadoCarga.error;
    }
  }

  /// Pide la posición real al sistema operativo una sola vez y la deja en
  /// [posicion]; si ya la tiene, no vuelve a pedirla salvo que se pida con
  /// [forzar] (por ejemplo, desde el botón "Reintentar" del Mapa).
  Future<void> cargarPosicion({bool forzar = false}) async {
    if (posicion.value != null && !forzar) {
      estadoPosicion.value = EstadoCarga.exito;
      return;
    }
    estadoPosicion.value = EstadoCarga.cargando;
    try {
      posicion.value = await LocationService.obtenerPosicionActual();
      estadoPosicion.value = EstadoCarga.exito;
    } on LocationException catch (e) {
      mensajeErrorPosicion.value = e.mensaje;
      estadoPosicion.value = EstadoCarga.error;
    } catch (e) {
      mensajeErrorPosicion.value = '$e';
      estadoPosicion.value = EstadoCarga.error;
    }
  }

  void agregarProducto(Producto producto) {
    productosEjemplo.add(producto);
    productos.add(producto);
  }

  final RxList<Producto> favoritos = <Producto>[].obs;
  final Box<Map> _favoritosBox = Hive.box<Map>('favoritos');

  bool esFavorito(Producto producto) =>
      favoritos.any((p) => p.id == producto.id);

  int get totalFavoritos => favoritos.length;

  void alternarFavorito(Producto producto) {
    if (esFavorito(producto)) {
      _favoritosBox.delete(producto.id);
      favoritos.removeWhere((p) => p.id == producto.id);
    } else {
      _favoritosBox.put(producto.id, producto.toMap());
      favoritos.add(producto);
    }
  }

  double get precioTotal {
    double sum = 0.0;
    /* for (var item in productosFavoritos) {
      // Eliminamos la comparación innecesaria con null
      // y convertimos a string de forma segura antes del parseo
      final precioNum = double.tryParse(item.precio.toString()) ?? 0.0;
      sum += precioNum;
    }*/
    return sum;
  }

  // Limpiar favoritos después de una compra exitosa
  void vaciarFavoritos() {
    productosFavoritos.clear();
  }

  // double? distanciaA(Place lugar) {
  //   final pos = posicion.value;
  //   return pos == null ? null : distanciaAPlaceEnMetros(pos, lugar);
  // }
}
