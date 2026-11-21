class AppConstants {
  static const dbName = 'ptms.db';
  static const dbVersion = 1;
  static const defaultCurrency = 'SAR';
}

class UnitStatus {
  static const available = 'available';
  static const rented = 'rented';
  static const maintenance = 'maintenance';
  static const inactive = 'inactive';
}

class ContractStatus {
  static const draft = 'draft';
  static const active = 'active';
  static const expired = 'expired';
  static const cancelled = 'cancelled';
  static const suspended = 'suspended';
}

class ObligationStatus {
  static const unpaid = 'unpaid';
  static const partial = 'partial';
  static const paid = 'paid';
  static const overdue = 'overdue';
  static const cancelled = 'cancelled';
}

class ObligationType {
  static const rent = 'rent';
  static String service(int serviceId) => 'service:$serviceId';
}

class ServiceBilling {
  static const fixedMonthly = 'fixed_monthly';
  static const consumption = 'consumption';
  static const oneTime = 'one_time';
}

class ServiceSplit {
  static const equal = 'equal';
  static const area = 'area';
  static const consumption = 'consumption';
  static const direct = 'direct';
}

class PaymentMethod {
  static const cash = 'cash';
  static const bank = 'bank_transfer';
  static const wallet = 'e_wallet';
  static const other = 'other';
}