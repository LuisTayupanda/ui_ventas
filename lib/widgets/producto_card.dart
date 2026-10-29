import 'package:exploraec/screens/detailProductoscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/productos_controller.dart';
import '../models/productos.dart';
import '../theme/app_theme.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductosController>();
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Stack(
        children: [
          InkWell(
            onTap: () => Get.to(() => DetailProductoScreen(producto: producto)),
            child: Semantics(
              label: '${producto.nombre}, categoría ${producto.categoria}',
              hint: 'Toca dos veces para ver el detalle',
              button: true,
              excludeSemantics: true,
              child: _buildContenido(context),
            ),
          ),
          Positioned(
            right: AppSpacing.xs,
            top: AppSpacing.xs,
            child: Obx(
              () => IconButton(
                icon: Icon(
                  controller.esFavorito(producto)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.esFavorito(producto)
                      ? Colors.red
                      : Colors.grey,
                ),
                tooltip: controller.esFavorito(producto)
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                onPressed: () => controller.alternarFavorito(producto),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cambiado de Icons.place a Icons.checkroom o Icons.shopping_bag para tu FashionStore
          Icon(Icons.checkroom,
              size: 36, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Text(
                    producto.nombre,
                    style: estilos.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Muestra la Categoría y la Talla real del producto
                Text(
                  '${producto.categoria} · Talla: ${producto.talla.toUpperCase()}',
                  style: estilos.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  producto.descripcion,
                  style: estilos.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                // Añadido el precio con formato destacado en verde para la tienda
                Text(
                  '\$${producto.precio}',
                  style: estilos.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
