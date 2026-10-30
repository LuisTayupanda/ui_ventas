import 'package:exploraec/screens/favorites_screen.dart';
import 'package:exploraec/screens/inicio_screen.dart';
import 'package:exploraec/screens/map_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/gastos_controller.dart';
import '../controllers/places_controller.dart' show EstadoCarga;
import '../models/gasto.dart';
import '../services/api_exception.dart';
import 'pantalla_con_fallo.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/sin_sesion_view.dart';
import 'cambiar_password_screen.dart';
import 'gasto_form_screen.dart';
import '../theme/app_theme.dart';
import '../i18n/app_translations.dart';
import '../services/settings_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../bindings/places_binding.dart';
import '../screens/assistant_screen.dart';
import '../screens/home_screen.dart';
import '../screens/compraFavoritos_screen.dart';

class VentasScreen extends GetView<GastosController> {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    print('TOKEN  ventass: ${auth}');
    return Obx(() {
      if (!auth.estaAutenticado) return const SinSesionView();
      //return const InicioScreen();
      //return _buildGastos(context, auth);
      //return build_Nacigation(context, auth);
      return const RootShell();
    });
  }

  Widget build_Nacigation(BuildContext context, AuthController auth) {
    print(
        '=================================LLEGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
    return GetMaterialApp(
      title: 'FashionStore',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),
      locale: SettingsService.idioma,
      fallbackLocale: const Locale('es', 'EC'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'EC'), Locale('en', 'US')],
      initialBinding: PlacesBinding(),
      home: const RootShell(),
    );
  }

  Widget _buildGastos(BuildContext context, AuthController auth) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
            () => Text('${'Ventas'.tr} (${controller.totalEnServidor.value})')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: controller.cargarGastos,
          ),
          PopupMenuButton<String>(
            onSelected: (valor) {
              if (valor == 'salir') auth.cerrarSesion();
              if (valor == 'invalidar') auth.invalidarTokenParaPruebas();
              if (valor == 'password')
                Get.to(() => const CambiarPasswordScreen());

              if (valor == 'error_pantalla')
                Get.to(() => const PantallaConFallo());
              if (valor == 'error_async') {
                Future<void>.delayed(
                    Duration.zero,
                    () => throw StateError(
                        'Fallo asíncrono provocado a propósito'));
              }
              if (valor == 'acerca')
                showLicensePage(
                    context: context,
                    applicationName: 'Ventas App',
                    applicationVersion: '1.0.0');
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'password', child: Text('Cambiar contraseña')),
              const PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
              if (kDebugMode) ...const [
                PopupMenuItem(
                    value: 'invalidar',
                    child: Text('Invalidar token (solo práctica)')),
                PopupMenuItem(
                    value: 'error_pantalla',
                    child: Text('Error de pantalla (solo práctica)')),
                PopupMenuItem(
                    value: 'error_async',
                    child: Text('Error asíncrono (solo práctica)')),
              ],
            ],
          ),
        ],
      ),
      // Por qué: el botón «+» abre el formulario vacío para crear un gasto.
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const GastoFormScreen()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.estado.value == EstadoCarga.cargando) {
          return const LoadingView(mensaje: 'Cargando productos...');
        }
        if (controller.estado.value == EstadoCarga.error) {
          return ErrorView(
            mensaje: controller.mensajeError.value,
            onReintentar: controller.iniciar,
          );
        }
        if (controller.gastos.isEmpty) {
          return const EmptyView(
              mensaje: 'Aún no registras gastos en este viaje');
        }
        return Column(
          children: [
            if (controller.desdeCache.value)
              MaterialBanner(
                leading: const Icon(Icons.cloud_off),
                content: Text(
                    'Sin conexión — gastos guardados (última sincronización: ${controller.ultimaSincronizacion})'),
                actions: [
                  TextButton(
                    onPressed: controller.cargarGastos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.cargarGastos,
                child: _buildLista(context, controller.gastos),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLista(BuildContext context, List<Gasto> gastos) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: gastos.length,
      itemBuilder: (context, i) {
        final g = gastos[i];
        return ListTile(
          title: Text('Lsta de compras'), //Text(g.descripcion),
          subtitle: Text('${g.categoria} · ${g.fecha}'),
          // Por qué: tocar una fila abre el mismo formulario, ya relleno.
          onTap: () => Get.to(() => GastoFormScreen(gasto: g)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(g.monto.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar',
                onPressed: () => confirmarEliminar(context, g),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pide confirmación antes de borrar; si el servidor falla, avisa con el
  /// mensaje que devolvió.
  Future<void> confirmarEliminar(BuildContext context, Gasto g) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Text('¿Eliminar "${g.descripcion}"?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogo, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogo, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await controller.eliminar(g.id);
    } on ApiException catch (e) {
      Get.snackbar('No se pudo eliminar', e.mensaje);
    }
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_indiceActual) {
        0 => const InicioScreen(),
        1 => const MapScreen(),
        // 2 => const FavoritosScreen(),
        _ => const AssistantScreen(),
      },
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'inicio'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map), label: 'mapa'.tr),
          // BottomNavigationBarItem(
          //  icon: const Icon(Icons.shopping_cart), label: 'carrito'.tr),
          // BottomNavigationBarItem(
          //     icon: const Icon(Icons.receipt_long), label: 'gastos'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome), label: 'asistente'.tr),
        ],
      ),
    );
  }
}
