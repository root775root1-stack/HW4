import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/contracts/presentation/contract_details_view.dart';
import '../features/contracts/presentation/contract_form_view.dart';
import '../features/contracts/presentation/contract_pdf_view.dart';
import '../features/documents/presentation/documents_view.dart';
import '../features/obligations/presentation/obligations_view.dart';
import '../features/payments/presentation/payments_controller.dart';
import '../features/payments/presentation/payments_view.dart';
import '../features/pin/presentation/pin_binding.dart';
import '../features/pin/presentation/pin_view.dart';
import '../features/properties/presentation/property_details_view.dart';
import '../features/reports/presentation/reports_view.dart';
import '../features/services/presentation/services_controller.dart';
import '../features/services/presentation/services_view.dart';
import '../features/settings/presentation/about_view.dart';
import '../features/settings/presentation/settings_view.dart';
import '../features/shell/shell.dart';
import '../features/splash/presentation/splash_view.dart';
import '../features/tenants/presentation/tenant_details_view.dart';
import '../features/units/presentation/unit_details_view.dart';
import '../features/units/presentation/units_controller.dart';
import '../features/units/presentation/units_view.dart';
import 'app_routes.dart';
import 'pin_middleware.dart';

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('not_found'.tr)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 12),
            Text('not_found'.tr),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Get.offAllNamed(Routes.home),
              child: Text('dashboard'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPages {
  static final _guard = [PinMiddleware()];

  static final notFound = GetPage(
    name: Routes.notFound,
    page: () => const _NotFoundPage(),
  );

  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(
        name: Routes.pin, page: () => const PinView(), binding: PinBinding()),
    GetPage(
        name: Routes.home,
        page: () => const ShellView(),
        binding: ShellBinding(),
        middlewares: _guard),
    GetPage(
        name: Routes.propertyDetails,
        page: () => const PropertyDetailsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.units,
        page: () => const UnitsView(),
        binding: BindingsBuilder(() => Get.lazyPut(() => UnitsController())),
        middlewares: _guard),
    GetPage(
        name: Routes.unitDetails,
        page: () => const UnitDetailsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.tenantDetails,
        page: () => const TenantDetailsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.contractForm,
        page: () => const ContractFormView(),
        binding: ContractFormBinding(),
        middlewares: _guard),
    GetPage(
        name: Routes.contractDetails,
        page: () => const ContractDetailsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.contractPdf,
        page: () => const ContractPdfView(),
        middlewares: _guard),
    GetPage(
        name: Routes.obligations,
        page: () => const ObligationsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.payments,
        page: () => const PaymentsView(),
        binding: BindingsBuilder(() => Get.lazyPut(() => PaymentsController())),
        middlewares: _guard),
    GetPage(
        name: Routes.services,
        page: () => const ServicesView(),
        binding: BindingsBuilder(() => Get.lazyPut(() => ServicesController())),
        middlewares: _guard),
    GetPage(
        name: Routes.documents,
        page: () => const DocumentsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.reports,
        page: () => const ReportsView(),
        middlewares: _guard),
    GetPage(
        name: Routes.reportView,
        page: () => const ReportViewScreen(),
        middlewares: _guard),
    GetPage(
        name: Routes.settings,
        page: () => const SettingsView(),
        binding: SettingsBinding(),
        middlewares: _guard),
    GetPage(
        name: Routes.about, page: () => const AboutView(), middlewares: _guard),
  ];
}
