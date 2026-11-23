import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/services/file_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_details.dart';
import '../../../core/widgets/attachments_section.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../units/data/unit_repository.dart';
import '../../units/presentation/unit_form.dart';
import '../../units/presentation/units_view.dart';
import '../data/property_repository.dart';
import 'properties_view.dart';
import 'property_form.dart';

class _PropData {
  _PropData(this.property, this.units, this.contracts, this.outstanding,
      this.services);
  final DbRow property;
  final List<DbRow> units;
  final List<DbRow> contracts;
  final double outstanding;
  final List<DbRow> services;
}

class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({super.key});

  Future<_PropData> _load(int id) async {
    final repo = PropertyRepository();
    final p = await repo.getById(id);
    if (p == null) throw 'not_found'.tr;
    final units = await UnitRepository().listForProperty(id);
    final contracts = await repo.raw('''
      SELECT c.id, c.contract_no, c.status, c.rent_amount, c.end_date,
             t.full_name AS tenant_name, u.number AS unit_number
      FROM contracts c JOIN units u ON u.id = c.unit_id
      JOIN tenants t ON t.id = c.tenant_id
      WHERE u.property_id = ? AND c.status = 'active' ORDER BY u.number''',
        [id]);
    final out = await repo.raw(
        "SELECT COALESCE(SUM(amount - paid_amount),0) AS s FROM obligations "
        "WHERE property_id = ? AND status NOT IN ('paid','cancelled')",
        [id]);
    final services = await repo.raw(
        'SELECT * FROM services WHERE property_id = ? ORDER BY name', [id]);
    return _PropData(p, units, contracts, toD(out.first['s']), services);
  }

  @override
  Widget build(BuildContext context) {
    final id = (Get.arguments as Map)['id'] as int;
    return AsyncDetails<_PropData>(
      loader: () => _load(id),
      builder: (context, d, reload) {
        final p = d.property;
        final rented = d.units.where((u) => u['status'] == 'rented').length;
        final pct = d.units.isEmpty ? 0.0 : rented / d.units.length;
        return Scaffold(
          appBar: AppBar(
            title: Text(txt(p['name'])),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  if (await openPropertyForm(existing: p)) reload();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await deleteProperty(p)) Get.back();
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (await openUnitForm(propertyId: id)) reload();
            },
            icon: const Icon(Icons.add),
            label: Text('add_unit'.tr),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              SectionCard(
                titleKey: 'property_info',
                icon: Icons.apartment,
                trailing: IconButton(
                  tooltip: 'change_photo'.tr,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  onPressed: () async {
                    final f = await Get.find<FileService>().pickImage();
                    if (f != null) {
                      await PropertyRepository().setImage(id, f.path);
                      reload();
                    }
                  },
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (txt(p['image_path']).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: propertyThumb(context, p, size: 160)),
                      ),
                    InfoRow(
                        'f_property_type',
                        txt(p['property_type']).isEmpty
                            ? null
                            : 'o_${p['property_type']}'.tr),
                    InfoRow('f_address', txt(p['address'])),
                    InfoRow('f_city', txt(p['city'])),
                    InfoRow('f_country', txt(p['country'])),
                    InfoRow('f_postal_code', txt(p['postal_code'])),
                    InfoRow('f_floors', txt(p['floors'])),
                    InfoRow('f_owner_name', txt(p['owner_name'])),
                    InfoRow('f_owner_phone', txt(p['owner_phone'])),
                    InfoRow('f_description', txt(p['description'])),
                    InfoRow('f_notes', txt(p['notes'])),
                    InfoRow('status',
                        p['is_active'] == 1 ? 'o_active'.tr : 'o_inactive'.tr),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'occupancy',
                icon: Icons.pie_chart_outline,
                child: Column(children: [
                  LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(8)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${'rented_units'.tr}: $rented / ${d.units.length}'),
                      Text('${(pct * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('outstanding'.tr),
                      Text(formatMoney(d.outstanding),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: d.outstanding > 0
                                  ? Colors.red.shade700
                                  : null)),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'units',
                icon: Icons.meeting_room_outlined,
                child: d.units.isEmpty
                    ? Text('no_units'.tr)
                    : Column(children: [
                        for (final u in d.units)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: unitCard(context, u, showProperty: false,
                                onEdit: () async {
                              if (await openUnitForm(existing: u)) reload();
                            }, onDelete: () async {
                              if (await deleteUnit(u)) reload();
                            }),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'active_contracts',
                icon: Icons.description_outlined,
                child: d.contracts.isEmpty
                    ? Text('no_active_contracts'.tr)
                    : Column(children: [
                        for (final c in d.contracts)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${txt(c['unit_number'])} • ${txt(c['tenant_name'])}'),
                            subtitle: Text(
                                '${txt(c['contract_no'])}  •  ${'f_end_date'.tr}: ${txt(c['end_date'])}'),
                            trailing: Text(formatMoney(toD(c['rent_amount']))),
                            onTap: () => Get.toNamed(Routes.contractDetails,
                                arguments: {'id': c['id']}),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'services',
                icon: Icons.build_outlined,
                trailing: TextButton(
                    onPressed: () => Get.toNamed(Routes.services),
                    child: Text('view_all'.tr)),
                child: d.services.isEmpty
                    ? Text('no_services'.tr)
                    : Column(children: [
                        for (final s in d.services)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(txt(s['name'])),
                            subtitle: Text('o_${txt(s['billing_type'])}'.tr),
                            trailing: Text(formatMoney(toD(s['amount']))),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              AttachmentsSection(ownerType: 'property', ownerId: id),
            ],
          ),
        );
      },
    );
  }
}
