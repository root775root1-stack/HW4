import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_details.dart';
import '../../../core/widgets/attachments_section.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../data/tenant_repository.dart';
import 'tenant_form.dart';

class _TenantData {
  _TenantData(this.tenant, this.contracts, this.payments, this.open);
  final DbRow tenant;
  final List<DbRow> contracts;
  final List<DbRow> payments;
  final List<DbRow> open;
}

class TenantDetailsView extends StatelessWidget {
  const TenantDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = (Get.arguments as Map)['id'] as int;
    final repo = TenantRepository();
    return AsyncDetails<_TenantData>(
      loader: () async {
        final t = await repo.getById(id);
        if (t == null) throw 'not_found'.tr;
        return _TenantData(t, await repo.contractsOf(id),
            await repo.paymentsOf(id), await repo.openObligationsOf(id));
      },
      builder: (context, d, reload) {
        final t = d.tenant;
        final balance = d.open.fold<double>(
            0, (a, o) => a + toD(o['amount']) - toD(o['paid_amount']));
        return Scaffold(
          appBar: AppBar(
            title: Text(txt(t['full_name'])),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  if (await openTenantForm(existing: t)) reload();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await deleteTenant(t)) Get.back();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                titleKey: 'personal_info',
                icon: Icons.person_outline,
                child: Column(children: [
                  InfoRow('f_name_ar', txt(t['name_ar'])),
                  InfoRow('f_name_en', txt(t['name_en'])),
                  InfoRow(
                      'f_id_type',
                      txt(t['id_type']).isEmpty
                          ? null
                          : 'o_${t['id_type']}'.tr),
                  InfoRow('f_id_number', txt(t['national_id'])),
                  InfoRow('f_id_issue_date', txt(t['id_issue_date'])),
                  InfoRow('f_id_expiry_date', txt(t['id_expiry_date'])),
                  InfoRow('f_nationality', txt(t['nationality'])),
                  InfoRow('f_birth_date', txt(t['birth_date'])),
                  InfoRow('f_gender',
                      txt(t['gender']).isEmpty ? null : 'o_${t['gender']}'.tr),
                  InfoRow('f_phone', txt(t['phone'])),
                  InfoRow('f_phone2', txt(t['phone2'])),
                  InfoRow('f_email', txt(t['email'])),
                  InfoRow('f_address', txt(t['address'])),
                  InfoRow('f_employer', txt(t['employer'])),
                  InfoRow('f_job_title', txt(t['job_title'])),
                  InfoRow('f_emergency_name', txt(t['emergency_name'])),
                  InfoRow('f_emergency_phone', txt(t['emergency_phone'])),
                  InfoRow('f_emergency_relation', txt(t['emergency_relation'])),
                  InfoRow('f_notes', txt(t['notes'])),
                ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'contracts',
                icon: Icons.description_outlined,
                child: d.contracts.isEmpty
                    ? Text('no_contracts'.tr)
                    : Column(children: [
                        for (final c in d.contracts)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${txt(c['contract_no'])}  •  ${txt(c['property_name'])} / ${txt(c['unit_number'])}'),
                            subtitle: Text(
                                '${txt(c['start_date'])} → ${txt(c['end_date'])}'),
                            trailing: StatusChip(txt(c['status'])),
                            onTap: () => Get.toNamed(Routes.contractDetails,
                                arguments: {'id': c['id']}),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'outstanding_obligations',
                icon: Icons.request_quote_outlined,
                trailing: Text(formatMoney(balance),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                child: d.open.isEmpty
                    ? Text('no_outstanding'.tr)
                    : Column(children: [
                        for (final o in d.open)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${txt(o['period'])}  •  ${txt(o['unit_number'])}'),
                            subtitle: Text('${'due'.tr} ${txt(o['due_date'])}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatMoney(
                                    toD(o['amount']) - toD(o['paid_amount']))),
                                StatusChip(txt(o['status'])),
                              ],
                            ),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'payment_history',
                icon: Icons.payments_outlined,
                child: d.payments.isEmpty
                    ? Text('no_payments'.tr)
                    : Column(children: [
                        for (final p in d.payments)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(txt(p['paid_on'])),
                            subtitle: Text('o_${txt(p['method'])}'.tr),
                            trailing: Text(formatMoney(toD(p['amount'])),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700)),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              AttachmentsSection(ownerType: 'tenant', ownerId: id),
            ],
          ),
        );
      },
    );
  }
}
