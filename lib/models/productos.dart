class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String precio;
  final String imagen;
  final String talla;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.talla,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria,
        'descripcion': descripcion,
        'precio': precio,
        'imagen': imagen,
        'talla': talla,
      };

  factory Producto.fromMap(Map<String, dynamic> mapa) => Producto(
        id: mapa['id'] != null ? mapa['id'].toString() : '',
        nombre: mapa['nombre'] != null ? mapa['nombre'].toString() : '',
        categoria:
            mapa['categoria'] != null ? mapa['categoria'].toString() : '',
        descripcion:
            mapa['descripcion'] != null ? mapa['descripcion'].toString() : '',
        precio: mapa['precio'] != null ? mapa['precio'].toString() : '0.0',
        imagen: mapa['imagen'] != null ? mapa['imagen'].toString() : '',
        talla: mapa['talla'] != null ? mapa['talla'].toString() : '',
      );
}

final List<Producto> productosEjemplo = [
  Producto(
    id: '1',
    nombre: 'Camiseta Casual de Algodón',
    categoria: 'Camisetas',
    descripcion: 'Camiseta cómoda 100% de algodón, ideal para el uso diario.',
    precio: '15.99',
    imagen: 'https://unsplash.com', // URL real para pruebas
    talla: 'M',
  ),
  Producto(
    id: '2',
    nombre: 'Chaqueta de Mezclilla Premium',
    categoria: 'Chaquetas',
    descripcion:
        'Chaqueta de jean clásica con botones metálicos y costuras reforzadas.',
    precio: '45.00',
    imagen: 'https://unsplash.com',
    talla: 'L',
  ),
  Producto(
    id: '3',
    nombre: 'Pantalón Slim Fit',
    categoria: 'Pantalones',
    descripcion: 'Pantalón de gabardina semi-elástico con corte estilizado.',
    precio: '29.90',
    imagen: 'https://unsplash.com',
    talla: '32',
  ),
  Producto(
    id: '4',
    nombre: 'Vestido de Verano Floral',
    categoria: 'Vestidos',
    descripcion: 'Vestido ligero con estampado floral y tirantes ajustables.',
    precio: '34.50',
    imagen: 'https://unsplash.com',
    talla: 'S',
  ),
];

Future<List<Producto>> fetchProductosSimulado(
    {bool forzarError = false, bool forzarVacio = false}) async {
  await Future.delayed(const Duration(seconds: 1));
  if (forzarError) {
    throw Exception('No se pudo conectar con el servidor (simulado)');
  }
  return forzarVacio ? <Producto>[] : productosEjemplo;
}
