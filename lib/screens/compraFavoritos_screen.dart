import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/productos_controller.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductosController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos / Carrito'),
      ),
      body: Obx(() {
        if (controller.productosFavoritos.isEmpty) {
          return const Center(
            child: Text('Aún no has agregado productos.'),
          );
        }

        return Column(
          children: [
            // Listado de productos guardados
            Expanded(
              child: ListView.builder(
                itemCount: controller.productosFavoritos.length,
                itemBuilder: (context, index) {
                  final producto = controller.productosFavoritos[index];
                  return ListTile(
                    leading: const Icon(Icons.checkroom, color: Colors.blue),
                    title: Text(producto.nombre),
                    subtitle: Text('Talla: ${producto.talla.toUpperCase()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${producto.precio}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              controller.alternarFavorito(producto),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Sección inferior fija con el total y el botón comprar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Acumulado:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${controller.precioTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => _mostrarModalPago(context, controller),
                        child: const Text('Comprar Ahora',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // 3. Modal para ingresar los valores de pago
  void _mostrarModalPago(BuildContext context, ProductosController controller) {
    final txtMontoPago = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que suba cuando aparezca el teclado
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Ajuste de teclado
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Procesar Pago',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                  'Total a pagar: \$${controller.precioTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 15),
              TextField(
                controller: txtMontoPago,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto con el que paga (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    double pago = double.tryParse(txtMontoPago.text) ?? 0.0;
                    double total = controller.precioTotal;

                    if (pago >= total) {
                      double cambio = pago - total;
                      Get.back(); // Cierra el modal

                      // Alerta de éxito utilizando GetX
                      Get.snackbar(
                        '¡Compra Exitosa!',
                        'Pago recibido. Su cambio es: \$${cambio.toStringAsFixed(2)}',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                      );

                      controller
                          .vaciarFavoritos(); // Limpia la lista tras comprar
                    } else {
                      Get.snackbar(
                        'Error en el pago',
                        'El monto ingresado es insuficiente.',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text('Confirmar Pago'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
