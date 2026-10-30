//import 'package:exploraec/controllers/productos_controller.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/widgets/producto_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//import '../controllers/places_controller.dart';
import '../controllers/productos_controller.dart';
import '../models/productos.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/place_card.dart';
import 'add_place_screen.dart';
import '../services/settings_service.dart';

class InicioScreen extends GetView<ProductosController> {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(ProductosController());
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Productos en Venta (${controller.total})')),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'idioma'.tr,
            onPressed: SettingsService.alternarIdioma,
          ),
          PopupMenuButton<String>(
            tooltip: 'Simular estado (solo práctica)',
            onSelected: (valor) {
              if (valor == 'cerrar') {
                // Buscamos el controlador de autenticación y cerramos sesión
                Get.find<AuthController>().cerrarSesion();
              } else {
                // Mantiene tu lógica de simular estados (normal, vacio, error)
                controller.simular(valor);
              }
            },
            itemBuilder: (context) => [
              // PopupMenuItem(value: 'normal', child: Text('sim_normal'.tr)),
              // PopupMenuItem(value: 'vacio', child: Text('sim_vacio'.tr)),
              // PopupMenuItem(value: 'error', child: Text('sim_error'.tr)),
              PopupMenuItem(value: 'cerrar', child: Text('cerrar sesion'.tr)),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.estado.value == EstadoCarga.cargando) {
          return const LoadingView(mensaje: 'Buscando productos en venta...');
        }
        if (controller.estado.value == EstadoCarga.error) {
          return ErrorView(
            mensaje: controller.mensajeError.value,
            onReintentar: controller.cargarProductos,
          );
        }
        if (controller.productos.isEmpty) {
          return const EmptyView(mensaje: 'Todavía no hay productos guardados');
        }
        return _buildLista(controller.productos);
      }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Get.to(() => const AddPlaceScreen()),
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildLista(List<Producto> productos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) =>
                ProductoCard(producto: productos[index]),
          );
        }
        final columnas = constraints.maxWidth < 900 ? 2 : 3;
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.sm),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            childAspectRatio: 2.2,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) =>
              ProductoCard(producto: productos[index]),
        );
      },
    );
  }
}
