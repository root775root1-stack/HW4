import 'package:get/get.dart';

import '../core/widgets/placeholder_view.dart';
import '../features/home/presentation/home_binding.dart';
import '../features/home/presentation/home_view.dart';
import '../features/pin/presentation/pin_binding.dart';
import '../features/pin/presentation/pin_view.dart';
import '../features/properties/presentation/properties_binding.dart';
import '../features/properties/presentation/properties_view.dart';
import '../features/settings/presentation/settings_binding.dart';
import '../features/settings/presentation/settings_view.dart';
import '../features/splash/presentation/splash_view.dart';
import 'app_routes.dart';
import 'pin_middleware.dart';

class AppPages {
  static final _guard = [PinMiddleware()];

  static GetPage _placeholder(String route, String titleKey) => GetPage(
        name: route,
        page: () => PlaceholderView(titleKey: titleKey),
        middlewares: _guard,
      );

  static final notFound = GetPage(
    name: Routes.notFound,
    page: () => const PlaceholderView(titleKey: 'not_found'),
  );

  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(
      name: Routes.pin,
      page: () => const PinView(),
      binding: PinBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: _guard,
    ),
    GetPage(
      name: Routes.properties,
      page: () => const PropertiesView(),
      binding: PropertiesBinding(),
      middlewares: _guard,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: _guard,
    ),
    _placeholder(Routes.units, 'units'),
    _placeholder(Routes.services, 'services'),
    _placeholder(Routes.tenants, 'tenants'),
    _placeholder(Routes.contracts, 'contracts'),
    _placeholder(Routes.obligations, 'obligations'),
    _placeholder(Routes.payments, 'payments'),
    _placeholder(Routes.documents, 'documents'),
    _placeholder(Routes.reports, 'reports'),
    _placeholder(Routes.about, 'about'),
  ];
}