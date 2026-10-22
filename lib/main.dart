import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bindings/places_binding.dart';
import 'controllers/auth_controller.dart';
import 'i18n/app_translations.dart';
import 'screens/assistant_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/gastos_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'services/ai_assistant_service.dart';
import 'services/api_client.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'utils/reporte_errores.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ReporteErrores.instalar();
  await Hive.initFlutter();
  await Hive.openBox<Map>('favoritos');
  await SettingsService.abrir();

  Get.put(ApiClient(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(AiAssistantService(), permanent: true);
  runApp(const ExploraEcApp());
}

class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        0 => const LoginScreen(),
        // 1 => const HomeScreen(),
        // 2 => const MapScreen(),
        // 3 => const FavoritesScreen(),
        // 4 => const GastosScreen(),
        _ => const AssistantScreen(),
      },
      /* bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'inicio'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map), label: 'mapa'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite), label: 'favoritos'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long), label: 'gastos'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome), label: 'asistente'.tr),
        ],
      ),*/
    );
  }
}
