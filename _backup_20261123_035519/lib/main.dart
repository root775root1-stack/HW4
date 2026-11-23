import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/locale/app_translations.dart';
import 'core/services/database_service.dart';
import 'core/services/obligation_service.dart';
import 'core/services/session_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => StorageService().init(), permanent: true);
  await Get.putAsync(() => DatabaseService().init(), permanent: true);
  Get.put(SessionService(), permanent: true);
  Get.put(ObligationService(), permanent: true);
  runApp(const PtmsApp());
}

class PtmsApp extends StatelessWidget {
  const PtmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    return GetMaterialApp(
      title: 'PTMS',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: storage.locale,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: storage.themeMode,
      initialBinding: InitialBinding(),
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      unknownRoute: AppPages.notFound,
    );
  }
}