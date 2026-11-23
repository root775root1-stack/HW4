import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/crud/form_model.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../data/contract_repository.dart';
import '../data/contract_specs.dart';

/// Drives the multi-step lease contract form (create / edit draft).
class ContractFormController extends GetxController {
  final repo = ContractRepository();
  final storage = Get.find<StorageService>();

  late final List<ContractStep> steps;
  late final List<FormModel> models;

  final current = 0.obs;
  final loading = true.obs;
  final saving = false.obs;
  final invalidSteps = <int>{}.obs;

  int? editId;
  int? _presetUnit;
  List<DbRow> _tenants = [];
  String? _lastProperty;
  String? _lastUnit;
  String? _lastTenant;
  bool _wiring = false;

  FormModel modelOf(String id) => models[steps.indexWhereId(id)];

  @override
  void onInit() {
    super.onInit();
    steps = buildContractSteps();
    models = [for (final s in steps) FormModel(s.specs)];
    final a = Get.arguments;
    if (a is Map) {
      editId = a['id'] as int?;
      _presetUnit = a['unit_id'] as int?;
    }
    _init();
  }

  @override
  void onClose() {
    for (final m in models) {
      m.dispose();
    }
    super.onClose();
  }

  FormModel get _unitModel => modelOf('unit');
  FormModel get _tenantModel => modelOf('tenant');

  Future<void> _init() async {
    try {
      _tenants = await repo
          .raw('SELECT * FROM tenants ORDER BY full_name COLLATE NOCASE');
      _tenantModel.setOptions('tenant_id', [
        for (final t in _tenants)
          FieldOption('${t['id']}',
              label: '${t['full_name']}  •  ${t['phone'] ?? ''}',
              translate: false)
      ]);
      final props = await repo
          .raw('SELECT id, name FROM properties ORDER BY name COLLATE NOCASE');
      _unitModel.setOptions('property_id', [
        for (final p in props)
          FieldOption('${p['id']}', label: '${p['name']}', translate: false)
      ]);

      if (editId != null) {
        final b = await repo.loadBundle(editId!);
        if (b == null || b.contract['status'] != ContractStatus.draft) {
          showErr('only_draft_editable');
          Get.back();
          return;
        }
        await _populate(b);
      } else {
        await _defaults();
      }
      _lastProperty = _str(_unitModel.get('property_id'));
      _lastUnit = _str(_unitModel.get('unit_id'));
      _lastTenant = _str(_tenantModel.get('tenant_id'));
      _unitModel.addListener(_onUnitChanged);
      _tenantModel.addListener(_onTenantChanged);
      loading.value = false;
    } catch (e) {
      showErr('error_generic');
      loading.value = false;
    }
  }

  String? _str(dynamic v) => (v == null || '$v'.isEmpty) ? null : '$v';

  // ------------------------------------------------------------ defaults
  Future<void> _defaults() async {
    final d = storage.contractDefaults;
    final now = DateTime.now();
    final info = modelOf('info');
    info.setAll({
      'contract_no': await repo.nextNumber(),
      'created_date': formatDate(now),
      'start_date': formatDate(now),
      'end_date': formatDate(DateTime(now.year + 1, now.month, now.day)
          .subtract(const Duration(days: 1))),
      'language': d['language'] ?? storage.langCode,
      'currency': d['currency'] ?? storage.currency,
      'notice_period': d['notice_period'],
      'renewal_period': d['renewal_period'],
    });
    modelOf('financial').setAll({
      'payment_cycle': d['payment_cycle'] ?? 'monthly',
      'due_day': d['due_day'] ?? 1,
      'grace_period': d['grace_period'],
      'late_fee': d['late_fee'],
      'late_fee_type': d['late_fee_type'],
    });
    modelOf('conditions').setAll({
      'governing_law': d['governing_law'],
      'jurisdiction': d['jurisdiction'],
      'dispute_resolution': d['dispute_resolution'],
    });
    // Landlord section is pre-filled from the owner profile (Settings).
    modelOf('landlord').setAll(storage.owner);
    if (_presetUnit != null) {
      final u = await repo
          .raw('SELECT property_id FROM units WHERE id = ?', [_presetUnit]);
      if (u.isNotEmpty) {
        await _loadUnitOptions('${u.first['property_id']}');
        _unitModel.setAll({
          'property_id': u.first['property_id'],
          'unit_id': _presetUnit,
        });
        await _fillFromUnit('$_presetUnit');
      }
    }
  }

  // ------------------------------------------------------------ listeners
  Future<void> _loadUnitOptions(String propertyId) async {
    final units = await repo.raw(
        'SELECT id, number, status FROM units WHERE property_id = ? ORDER BY number',
        [propertyId]);
    _unitModel.setOptions('unit_id', [
      for (final u in units)
        FieldOption('${u['id']}',
            label: '${u['number']}  (${'o_${u['status']}'.tr})',
            translate: false)
    ]);
  }

  Future<void> _onUnitChanged() async {
    if (_wiring) return;
    _wiring = true;
    try {
      final pid = _str(_unitModel.get('property_id'));
      if (pid != _lastProperty) {
        _lastProperty = pid;
        _lastUnit = null;
        _unitModel.set('unit_id', null, notify: false);
        if (pid != null) await _loadUnitOptions(pid);
        _unitModel.refresh();
      }
      final uid = _str(_unitModel.get('unit_id'));
      if (uid != _lastUnit) {
        _lastUnit = uid;
        if (uid != null) await _fillFromUnit(uid);
      }
    } finally {
      _wiring = false;
    }
  }

  Future<void> _fillFromUnit(String unitId) async {
    final r = await repo.raw('''
      SELECT u.*, p.name AS pname, p.address AS paddress, p.city AS pcity
      FROM units u JOIN properties p ON p.id = u.property_id WHERE u.id = ?''',
        [unitId]);
    if (r.isEmpty) return;
    final u = r.first;
    _unitModel.setAll({
      'property_name': u['pname'],
      'property_address': [u['paddress'], u['pcity']]
          .where((e) => e != null && '$e'.isNotEmpty)
          .join(', '),
      'unit_number': u['number'],
      'floor': u['floor'],
      'unit_type': u['type'] == null ? null : 'o_${u['type']}'.tr,
      'area': u['area'],
      'bedrooms': u['bedrooms'],
      'bathrooms': u['bathrooms'],
      'furnishing': u['furnishing'] == null ? null : 'o_${u['furnishing']}'.tr,
      'meter_electric': u['meter_electric'],
      'meter_water': u['meter_water'],
    });
    final fin = modelOf('financial');
    if (fin.text('rent_amount').isEmpty && u['base_rent'] != null) {
      fin.set('rent_amount', u['base_rent']);
    }
    if (fin.text('deposit_amount').isEmpty && u['deposit_amount'] != null) {
      fin.set('deposit_amount', u['deposit_amount']);
    }
  }

  void _onTenantChanged() {
    final tid = _str(_tenantModel.get('tenant_id'));
    if (tid == _lastTenant) return;
    _lastTenant = tid;
    if (tid == null) return;
    final t = _tenants.firstMatch((e) => '${e['id']}' == tid);
    if (t == null) return;
    _tenantModel.setAll({
      'full_name': t['full_name'],
      'name_ar': t['name_ar'],
      'name_en': t['name_en'],
      'id_number': t['national_id'],
      'id_type': t['id_type'],
      'nationality': t['nationality'],
      'birth_date': t['birth_date'],
      'phone': t['phone'],
      'phone2': t['phone2'],
      'email': t['email'],
      'address': t['address'],
      'employer': t['employer'],
      'emergency_name': t['emergency_name'],
      'emergency_phone': t['emergency_phone'],
      'notes': t['notes'],
    });
  }

  /// "Suggest in words": converts the monthly rent into words.
  void suggestRentWords() {
    final fin = modelOf('financial');
    final v = num.tryParse(fin.text('rent_amount').replaceAll(',', ''));
    if (v == null || v <= 0) return;
    final lang = _str(modelOf('info').get('language')) ?? storage.langCode;
    final cur = modelOf('info').text('currency');
    fin.set('rent_words', '${numberToWords(v, lang)} $cur'.trim());
  }

  // ------------------------------------------------------------ edit mode
  Future<void> _populate(ContractBundle b) async {
    final c = b.contract;
    for (var i = 0; i < steps.length; i++) {
      final id = steps[i].id;
      final data = <String, dynamic>{};
      for (final s in steps[i].specs) {
        if (contractColumnKeys.contains(s.key)) {
          data[s.key] = c[s.key];
        } else if (b.clauses[id]?.containsKey(s.key) ?? false) {
          final raw = b.clauses[id]![s.key]!;
          data[s.key] = s.type == FieldType.toggle ? raw == '1' : raw;
        }
      }
      models[i].setAll(data);
    }
    modelOf('info').set('status', 'draft', notify: false);
    for (final e in {
      'renewal_option': c['renewal_option'],
      'allow_overlap': c['allow_overlap']
    }.entries) {
      modelOf('info').set(e.key, e.value == 1, notify: false);
    }
    modelOf('landlord').setAll({for (final k in partyKeys) k: b.landlord[k]});
    modelOf('tenant').setAll({for (final k in partyKeys) k: b.tenant[k]});
    _tenantModel.set('tenant_id', c['tenant_id'], notify: false);

    await _loadUnitOptions('${c['property_id']}');
    _unitModel
        .setAll({'property_id': c['property_id'], 'unit_id': c['unit_id']});

    final h = modelOf('handover');
    for (final e in inventoryKeys.entries) {
      h.set(
          e.key,
          b.inventory
              .where((r) => r['kind'] == e.value)
              .map((r) => '${r['description']}')
              .join('\n'),
          notify: false);
    }
    for (final e in readingKeys.entries) {
      final r = b.readings.firstMatch((x) => x['meter_type'] == e.value);
      h.set(e.key, r?['reading'], notify: false);
    }
    h.refresh();
    final w = modelOf('witnesses');
    for (final r in b.witnesses) {
      final p = r['position'];
      w.set('w${p}_name', r['name'], notify: false);
      w.set('w${p}_id', r['id_number'], notify: false);
    }
    w.refresh();
  }

  // ------------------------------------------------------------ navigation
  void goTo(int i) => current.value = i.clamp(0, steps.length - 1);
  void next() => goTo(current.value + 1);
  void back() => goTo(current.value - 1);
  bool get isLast => current.value == steps.length - 1;

  // ------------------------------------------------------------ saving
  int? _int(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  Future<void> save({bool forceDraft = false}) async {
    if (saving.value) return;
    invalidSteps.clear();
    for (var i = 0; i < models.length; i++) {
      if (!models[i].validate()) invalidSteps.add(i);
    }
    if (invalidSteps.isNotEmpty) {
      goTo(invalidSteps.first);
      showErr('fix_errors');
      return;
    }
    final info = modelOf('info');
    final start = info.dateOf('start_date')!;
    final end = info.dateOf('end_date')!;
    if (!end.isAfter(start)) {
      goTo(0);
      showErr('end_before_start');
      return;
    }
    final rent = num.tryParse(
            modelOf('financial').text('rent_amount').replaceAll(',', '')) ??
        0;
    if (rent <= 0) {
      goTo(steps.indexWhere((s) => s.id == 'financial'));
      showErr('rent_positive');
      return;
    }

    saving.value = true;
    try {
      final contract = <String, Object?>{};
      final clauses = <String, Map<String, String>>{};
      var landlord = <String, Object?>{};
      var tenantParty = <String, Object?>{};
      final inventory = <DbRow>[];
      final readings = <DbRow>[];
      final witnesses = <DbRow>[];
      int? tenantId;

      for (var i = 0; i < steps.length; i++) {
        final id = steps[i].id;
        final m = models[i].toMap();
        switch (id) {
          case 'landlord':
            landlord = {
              for (final k in partyKeys)
                if (m.containsKey(k)) k: m[k]
            };
            break;
          case 'tenant':
            tenantParty = {
              for (final k in partyKeys)
                if (m.containsKey(k)) k: m[k]
            };
            tenantId = _int(m['tenant_id']);
            break;
          default:
            m.forEach((k, v) {
              if (inventoryKeys.containsKey(k)) {
                for (final line in '${v ?? ''}'.split('\n')) {
                  if (line.trim().isNotEmpty) {
                    inventory.add({
                      'kind': inventoryKeys[k],
                      'description': line.trim(),
                      'quantity': 1,
                    });
                  }
                }
              } else if (readingKeys.containsKey(k)) {
                if (v != null) {
                  final isElec = readingKeys[k] == 'electric';
                  readings.add({
                    'meter_type': readingKeys[k],
                    'meter_no': modelOf('unit')
                        .text(isElec ? 'meter_electric' : 'meter_water'),
                    'reading': v,
                    'read_on': modelOf('handover').get('handover_date'),
                  });
                }
              } else if (id == 'witnesses' && k != 'signed_date') {
                // handled below
              } else if (contractColumnKeys.contains(k)) {
                contract[k] = v;
              } else if (!(id == 'unit' && k == 'property_id') && v != null) {
                clauses.putIfAbsent(id, () => {})[k] = '$v';
              }
            });
        }
      }
      final w = modelOf('witnesses').toMap();
      for (final p in [1, 2]) {
        final n = '${w['w${p}_name'] ?? ''}';
        final wid = '${w['w${p}_id'] ?? ''}';
        if (n.isNotEmpty || wid.isNotEmpty) {
          witnesses.add({'position': p, 'name': n, 'id_number': wid});
        }
      }

      final wantActive = !forceDraft && contract['status'] == 'active';
      contract['status'] = ContractStatus.draft;
      contract['unit_id'] = _int(contract['unit_id']);
      for (final k in [
        'due_day',
        'notice_period',
        'grace_period',
        'keys_count',
        'cards_count'
      ]) {
        contract[k] = _int(contract[k]);
      }

      final id = await repo.save(
        id: editId,
        contract: contract,
        landlord: landlord,
        tenantParty: tenantParty,
        tenantId: tenantId,
        clauses: clauses,
        witnesses: witnesses,
        inventory: inventory,
        readings: readings,
      );

      if (wantActive) {
        final err = await repo.activate(id);
        if (err != null) {
          showErr(err);
        } else {
          showOk('contract_activated');
        }
      } else {
        showOk('saved_ok');
      }
      Get.find<DataBus>().bump();
      if (editId == null) {
        Get.offNamed(Routes.contractDetails, arguments: {'id': id});
      } else {
        Get.back();
      }
    } catch (e) {
      showErr(e.toString().contains('UNIQUE')
          ? 'duplicate_contract_no'
          : 'save_failed');
    } finally {
      saving.value = false;
    }
  }
}

extension _StepIndex on List<ContractStep> {
  int indexWhereId(String id) => indexWhere((s) => s.id == id);
}

extension _FirstMatch<T> on Iterable<T> {
  T? firstMatch(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
