import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

/// SQLite access with versioned migrations.
///  v1 : original prototype schema
///  v2 : extended columns + contract sub-tables (non-destructive ALTERs)
class DatabaseService extends GetxService {
  late Database db;
  late String dbPath;

  Future<DatabaseService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    dbPath = p.join(dir.path, AppConstants.dbName);
    await _safetyCopy();
    db = await _open();
    return this;
  }

  Future<Database> _open() => openDatabase(
        dbPath,
        version: AppConstants.dbVersion,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await _createV1(d);
          await _migrateV2(d);
        },
        onUpgrade: (d, oldV, newV) async {
          if (oldV < 2) await _migrateV2(d);
        },
      );

  /// One-time copy of a pre-existing v1 database before it is migrated.
  Future<void> _safetyCopy() async {
    final f = File(dbPath);
    final bak = File('$dbPath.pre_v2.bak');
    if (await f.exists() && !await bak.exists()) {
      try {
        await f.copy(bak.path);
      } catch (_) {}
    }
  }

  Future<File> createBackupCopy() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final target = p.join(dir.path, 'ptms_backup_$stamp.db');
    return File(dbPath).copy(target);
  }

  /// Replaces the live database with [source] after validating it.
  /// Returns false when the file is not a valid PTMS database.
  Future<bool> restoreFrom(File source) async {
    Database? test;
    try {
      test = await openDatabase(source.path, readOnly: true);
      final t = await test.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('properties','contracts','obligations')");
      await test.close();
      test = null;
      if (t.length < 3) return false;
    } catch (_) {
      try {
        await test?.close();
      } catch (_) {}
      return false;
    }
    await db.close();
    final pre = File('$dbPath.before_restore.bak');
    if (await File(dbPath).exists()) await File(dbPath).copy(pre.path);
    await source.copy(dbPath);
    db = await _open();
    return true;
  }

  Future<void> _createV1(Database d) async {
    final b = d.batch();
    b.execute('''CREATE TABLE properties(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL, description TEXT, address TEXT,
      floors INTEGER DEFAULT 1, notes TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute('''CREATE TABLE units(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      property_id INTEGER NOT NULL REFERENCES properties(id) ON DELETE RESTRICT,
      number TEXT NOT NULL, floor INTEGER, type TEXT, area REAL,
      base_rent REAL NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'available',
      description TEXT, notes TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(property_id, number))''');
    b.execute('''CREATE TABLE tenants(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL, phone TEXT, national_id TEXT,
      address TEXT, notes TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute('''CREATE TABLE contracts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
      unit_id INTEGER NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
      status TEXT NOT NULL DEFAULT 'draft',
      start_date TEXT NOT NULL, end_date TEXT NOT NULL,
      rent_amount REAL NOT NULL, deposit_amount REAL NOT NULL DEFAULT 0,
      payment_cycle TEXT NOT NULL DEFAULT 'monthly',
      due_day INTEGER NOT NULL DEFAULT 1, payment_method TEXT,
      renewal_terms TEXT, termination_terms TEXT, terms_text TEXT,
      owner_snapshot TEXT, tenant_snapshot TEXT, pdf_path TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute('''CREATE TABLE services(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL, billing_type TEXT NOT NULL,
      split_method TEXT NOT NULL DEFAULT 'direct',
      amount REAL NOT NULL DEFAULT 0,
      property_id INTEGER REFERENCES properties(id) ON DELETE RESTRICT,
      unit_id INTEGER REFERENCES units(id) ON DELETE RESTRICT,
      is_active INTEGER NOT NULL DEFAULT 1, notes TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute('''CREATE TABLE service_readings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      service_id INTEGER NOT NULL REFERENCES services(id) ON DELETE CASCADE,
      unit_id INTEGER NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
      period TEXT NOT NULL, quantity REAL NOT NULL DEFAULT 0,
      amount REAL NOT NULL DEFAULT 0,
      UNIQUE(service_id, unit_id, period))''');
    b.execute('''CREATE TABLE obligations(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
      property_id INTEGER, unit_id INTEGER,
      type TEXT NOT NULL, period TEXT NOT NULL, due_date TEXT NOT NULL,
      amount REAL NOT NULL, paid_amount REAL NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'unpaid',
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute(
        'CREATE UNIQUE INDEX ux_obligation ON obligations(contract_id, period, type)');
    b.execute('CREATE INDEX ix_obl_status ON obligations(status, due_date)');
    b.execute('''CREATE TABLE payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
      obligation_id INTEGER NOT NULL REFERENCES obligations(id) ON DELETE RESTRICT,
      paid_on TEXT NOT NULL, amount REAL NOT NULL,
      method TEXT NOT NULL DEFAULT 'cash', reference TEXT, notes TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute('''CREATE TABLE documents(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      owner_type TEXT NOT NULL, owner_id INTEGER NOT NULL,
      kind TEXT NOT NULL, file_path TEXT NOT NULL, mime TEXT,
      size_bytes INTEGER,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute('CREATE INDEX ix_doc_owner ON documents(owner_type, owner_id)');
    await b.commit(noResult: true);
  }

  static const _alters = <String>[
    // properties
    'ALTER TABLE properties ADD COLUMN property_type TEXT',
    'ALTER TABLE properties ADD COLUMN city TEXT',
    'ALTER TABLE properties ADD COLUMN country TEXT',
    'ALTER TABLE properties ADD COLUMN postal_code TEXT',
    'ALTER TABLE properties ADD COLUMN units_count INTEGER',
    'ALTER TABLE properties ADD COLUMN owner_name TEXT',
    'ALTER TABLE properties ADD COLUMN owner_phone TEXT',
    'ALTER TABLE properties ADD COLUMN image_path TEXT',
    // units
    'ALTER TABLE units ADD COLUMN bedrooms INTEGER',
    'ALTER TABLE units ADD COLUMN bathrooms INTEGER',
    'ALTER TABLE units ADD COLUMN furnishing TEXT',
    'ALTER TABLE units ADD COLUMN deposit_amount REAL',
    'ALTER TABLE units ADD COLUMN meter_electric TEXT',
    'ALTER TABLE units ADD COLUMN meter_water TEXT',
    'ALTER TABLE units ADD COLUMN image_path TEXT',
    // tenants
    'ALTER TABLE tenants ADD COLUMN name_ar TEXT',
    'ALTER TABLE tenants ADD COLUMN name_en TEXT',
    'ALTER TABLE tenants ADD COLUMN id_type TEXT',
    'ALTER TABLE tenants ADD COLUMN id_issue_date TEXT',
    'ALTER TABLE tenants ADD COLUMN id_expiry_date TEXT',
    'ALTER TABLE tenants ADD COLUMN nationality TEXT',
    'ALTER TABLE tenants ADD COLUMN birth_date TEXT',
    'ALTER TABLE tenants ADD COLUMN gender TEXT',
    'ALTER TABLE tenants ADD COLUMN phone2 TEXT',
    'ALTER TABLE tenants ADD COLUMN email TEXT',
    'ALTER TABLE tenants ADD COLUMN employer TEXT',
    'ALTER TABLE tenants ADD COLUMN job_title TEXT',
    'ALTER TABLE tenants ADD COLUMN emergency_name TEXT',
    'ALTER TABLE tenants ADD COLUMN emergency_phone TEXT',
    'ALTER TABLE tenants ADD COLUMN emergency_relation TEXT',
    // contracts
    'ALTER TABLE contracts ADD COLUMN contract_no TEXT',
    'ALTER TABLE contracts ADD COLUMN title TEXT',
    'ALTER TABLE contracts ADD COLUMN contract_type TEXT',
    'ALTER TABLE contracts ADD COLUMN created_date TEXT',
    'ALTER TABLE contracts ADD COLUMN renewal_option INTEGER DEFAULT 0',
    'ALTER TABLE contracts ADD COLUMN renewal_period TEXT',
    'ALTER TABLE contracts ADD COLUMN notice_period INTEGER',
    'ALTER TABLE contracts ADD COLUMN language TEXT',
    'ALTER TABLE contracts ADD COLUMN currency TEXT',
    'ALTER TABLE contracts ADD COLUMN rent_words TEXT',
    'ALTER TABLE contracts ADD COLUMN advance_payment REAL',
    'ALTER TABLE contracts ADD COLUMN grace_period INTEGER',
    'ALTER TABLE contracts ADD COLUMN late_fee REAL',
    'ALTER TABLE contracts ADD COLUMN late_fee_type TEXT',
    'ALTER TABLE contracts ADD COLUMN payment_notes TEXT',
    'ALTER TABLE contracts ADD COLUMN allow_overlap INTEGER NOT NULL DEFAULT 0',
    'ALTER TABLE contracts ADD COLUMN handover_date TEXT',
    'ALTER TABLE contracts ADD COLUMN keys_count INTEGER',
    'ALTER TABLE contracts ADD COLUMN cards_count INTEGER',
    'ALTER TABLE contracts ADD COLUMN handover_notes TEXT',
    'ALTER TABLE contracts ADD COLUMN condition_at_handover TEXT',
    'ALTER TABLE contracts ADD COLUMN governing_law TEXT',
    'ALTER TABLE contracts ADD COLUMN jurisdiction TEXT',
    'ALTER TABLE contracts ADD COLUMN dispute_resolution TEXT',
    'ALTER TABLE contracts ADD COLUMN signed_date TEXT',
    // payments / documents
    'ALTER TABLE payments ADD COLUMN bank_txn_no TEXT',
    'ALTER TABLE documents ADD COLUMN name TEXT',
  ];

  Future<void> _migrateV2(Database d) async {
    // Each ALTER is isolated: a column that already exists is simply skipped.
    for (final sql in _alters) {
      try {
        await d.execute(sql);
      } catch (_) {}
    }
    final b = d.batch();
    b.execute('''CREATE TABLE IF NOT EXISTS contract_parties(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
      role TEXT NOT NULL,
      full_name TEXT, name_ar TEXT, name_en TEXT,
      id_number TEXT, id_type TEXT, nationality TEXT, birth_date TEXT,
      phone TEXT, phone2 TEXT, email TEXT,
      address TEXT, city TEXT, country TEXT,
      employer TEXT, emergency_name TEXT, emergency_phone TEXT,
      bank_name TEXT, iban TEXT, rep_name TEXT, rep_id TEXT, notes TEXT,
      UNIQUE(contract_id, role))''');
    b.execute('''CREATE TABLE IF NOT EXISTS contract_clauses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
      section TEXT NOT NULL, clause_key TEXT NOT NULL, body TEXT,
      sort_order INTEGER NOT NULL DEFAULT 0,
      UNIQUE(contract_id, section, clause_key))''');
    b.execute('''CREATE TABLE IF NOT EXISTS contract_witnesses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
      position INTEGER NOT NULL, name TEXT, id_number TEXT,
      UNIQUE(contract_id, position))''');
    b.execute('''CREATE TABLE IF NOT EXISTS contract_inventory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
      kind TEXT NOT NULL, description TEXT NOT NULL,
      quantity INTEGER DEFAULT 1, condition TEXT)''');
    b.execute('''CREATE TABLE IF NOT EXISTS contract_meter_readings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
      meter_type TEXT NOT NULL, meter_no TEXT, reading REAL, read_on TEXT)''');
    b.execute('''CREATE TABLE IF NOT EXISTS contract_attachments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
      name TEXT, kind TEXT, file_path TEXT NOT NULL, size_bytes INTEGER,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)''');
    b.execute(
        'CREATE INDEX IF NOT EXISTS ix_contract_unit ON contracts(unit_id, status)');
    b.execute(
        'CREATE INDEX IF NOT EXISTS ix_contract_tenant ON contracts(tenant_id)');
    b.execute(
        'CREATE INDEX IF NOT EXISTS ix_pay_obl ON payments(obligation_id)');
    b.execute('CREATE INDEX IF NOT EXISTS ix_units_prop ON units(property_id)');
    await b.commit(noResult: true);
  }
}
