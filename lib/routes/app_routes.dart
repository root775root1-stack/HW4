abstract class Routes {
  static const splash = '/splash';
  static const pin = '/pin';
  static const home = '/home';

  static const propertyDetails = '/property-details';
  static const units = '/units';
  static const unitDetails = '/unit-details';
  static const tenantDetails = '/tenant-details';
  static const contractForm = '/contract-form';
  static const contractDetails = '/contract-details';
  static const contractPdf = '/contract-pdf';
  static const obligations = '/obligations';
  static const payments = '/payments';
  static const services = '/services';
  static const documents = '/documents';
  static const reports = '/reports';
  static const reportView = '/report-view';
  static const settings = '/settings';
  static const about = '/about';
  static const notFound = '/not-found';
}

/// Index of each tab in the bottom navigation bar.
abstract class Tabs {
  static const dashboard = 0;
  static const properties = 1;
  static const tenants = 2;
  static const contracts = 3;
  static const more = 4;
}
