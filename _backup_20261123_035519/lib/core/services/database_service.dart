import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class DatabaseService extends GetxService {
  late final Database db;
  late final String dbPath;

  Future<DatabaseService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    dbPath = p.join(dir.path, AppConstants.dbName);
    db = await openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
    return this;
  }

  /// Copies the database file so the owner can save it outside the app.
  Future<File> createBackupCopy() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final target = p.join(dir.path, 'ptms_backup_$stamp.db');
    await db.execute('PRAGMA wal_checkpoint(FULL)');
    return File(dbPath).copy(target);
  }

  Future<void> _onCreate(Database d, int v) async {
    final batch = d.batch();

    batch.execute('''
      CREATE TABLE properties(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        address TEXT,
        floors INTEGER DEFAULT 1,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');

    batch.execute('''
      CREATE TABLE units(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        property_id INTEGER NOT NULL REFERENCES properties(id) ON DELETE RESTRICT,
        number TEXT NOT NULL,
        floor INTEGER,
        type TEXT,
        area REAL,
        base_rent REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'available',
        description TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(property_id, number)
      )''');

    batch.execute('''
      CREATE TABLE tenants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        phone TEXT,
        national_id TEXT,
        address TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');

    batch.execute('''
      CREATE TABLE contracts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
        unit_id INTEGER NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
        status TEXT NOT NULL DEFAULT 'draft',
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        rent_amount REAL NOT NULL,
        deposit_amount REAL NOT NULL DEFAULT 0,
        payment_cycle TEXT NOT NULL DEFAULT 'monthly',
        due_day INTEGER NOT NULL DEFAULT 1,
        payment_method TEXT,
        renewal_terms TEXT,
        termination_terms TEXT,
        terms_text TEXT,
        owner_snapshot TEXT,
        tenant_snapshot TEXT,
        pdf_path TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');

    batch.execute('''
      CREATE TABLE services(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        billing_type TEXT NOT NULL,
        split_method TEXT NOT NULL DEFAULT 'direct',
        amount REAL NOT NULL DEFAULT 0,
        property_id INTEGER REFERENCES properties(id) ON DELETE RESTRICT,
        unit_id INTEGER REFERENCES units(id) ON DELETE RESTRICT,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');

    batch.execute('''
      CREATE TABLE service_readings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_id INTEGER NOT NULL REFERENCES services(id) ON DELETE CASCADE,
        unit_id INTEGER NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
        period TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        amount REAL NOT NULL DEFAULT 0,
        UNIQUE(service_id, unit_id, period)
      )''');

    batch.execute('''
      CREATE TABLE obligations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
        contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
        property_id INTEGER,
        unit_id INTEGER,
        type TEXT NOT NULL,
        period TEXT NOT NULL,
        due_date TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'unpaid',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');
    // Idempotency guarantee: one obligation per contract + period + type.
    batch.execute(
        'CREATE UNIQUE INDEX ux_obligation ON obligations(contract_id, period, type)');
    batch.execute('CREATE INDEX ix_obl_status ON obligations(status, due_date)');

    batch.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
        contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
        obligation_id INTEGER NOT NULL REFERENCES obligations(id) ON DELETE RESTRICT,
        paid_on TEXT NOT NULL,
        amount REAL NOT NULL,
        method TEXT NOT NULL DEFAULT 'cash',
        reference TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');

    batch.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_type TEXT NOT NULL,
        owner_id INTEGER NOT NULL,
        kind TEXT NOT NULL,
        file_path TEXT NOT NULL,
        mime TEXT,
        size_bytes INTEGER,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');
    batch.execute('CREATE INDEX ix_doc_owner ON documents(owner_type, owner_id)');

    await batch.commit(noResult: true);
  }
}