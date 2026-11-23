class AppConstants {
  static const dbName = 'ptms.db';
  static const dbVersion = 2;
  static const defaultCurrency = 'SAR';
  static const appVersion = '2.0.0';
}

class UnitStatus {
  static const available = 'available';
  static const rented = 'rented';
  static const maintenance = 'maintenance';
  static const inactive = 'inactive';
  static const all = [available, rented, maintenance, inactive];
}

class ContractStatus {
  static const draft = 'draft';
  static const active = 'active';
  static const expired = 'expired';
  static const terminated = 'terminated';
  static const cancelled = 'cancelled';
  static const suspended = 'suspended';
  static const all = [draft, active, expired, terminated, cancelled];
}

class ObligationStatus {
  static const unpaid = 'unpaid';
  static const partial = 'partial';
  static const paid = 'paid';
  static const overdue = 'overdue';
  static const cancelled = 'cancelled';
  static const all = [unpaid, partial, paid, overdue, cancelled];
}

class ObligationType {
  static const rent = 'rent';
  static String service(int serviceId) => 'service:$serviceId';
  static bool isService(String t) => t.startsWith('service:');
}

class ServiceBilling {
  static const fixedMonthly = 'fixed_monthly';
  static const consumption = 'consumption';
  static const oneTime = 'one_time';
  static const all = [fixedMonthly, consumption, oneTime];
}

class ServiceSplit {
  static const equal = 'equal';
  static const area = 'area';
  static const direct = 'direct';
  static const all = [direct, equal, area];
}

class PaymentMethod {
  static const cash = 'cash';
  static const bank = 'bank_transfer';
  static const wallet = 'e_wallet';
  static const other = 'other';
  static const all = [cash, bank, wallet, other];
}

/// Number of months covered by one payment cycle.
int cycleMonths(String? cycle) {
  switch (cycle) {
    case 'quarterly':
      return 3;
    case 'semi_annual':
      return 6;
    case 'annual':
      return 12;
    default:
      return 1;
  }
}
