import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/formatters.dart';
import 'field_spec.dart';
import 'form_model.dart';

/// Renders the fields of a [FormModel]: two columns on tablets, one on phones.
class DynamicForm extends StatelessWidget {
  const DynamicForm({super.key, required this.model});
  final FormModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (ctx, _) => Form(
        key: model.formKey,
        child: LayoutBuilder(builder: (ctx, c) {
          final twoCol = c.maxWidth >= 640;
          final half = (c.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 14,
            children: [
              for (final s in model.specs)
                SizedBox(
                  width: (!twoCol ||
                          s.wide ||
                          s.type == FieldType.multiline ||
                          s.type == FieldType.toggle)
                      ? c.maxWidth
                      : half,
                  child: _field(ctx, s),
                ),
            ],
          );
        }),
      ),
    );
  }

  String _label(FieldSpec s) => s.required ? '${s.label.tr} *' : s.label.tr;

  Widget _field(BuildContext ctx, FieldSpec s) {
    switch (s.type) {
      case FieldType.date:
        return _dateField(ctx, s);
      case FieldType.dropdown:
        return _dropdown(ctx, s);
      case FieldType.toggle:
        return _toggle(ctx, s);
      default:
        return _textField(s);
    }
  }

  Widget _textField(FieldSpec s) {
    final numeric = s.type == FieldType.number || s.type == FieldType.money;
    return TextFormField(
      controller: model.controllers[s.key],
      decoration: InputDecoration(labelText: _label(s)),
      maxLines: s.type == FieldType.multiline ? 3 : 1,
      minLines: s.type == FieldType.multiline ? 2 : 1,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : s.type == FieldType.phone
              ? TextInputType.phone
              : s.type == FieldType.email
                  ? TextInputType.emailAddress
                  : s.type == FieldType.multiline
                      ? TextInputType.multiline
                      : TextInputType.text,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      onChanged: (v) {
        model.values[s.key] = v;
        s.onChanged?.call(v);
      },
      validator: (v) {
        final t = (v ?? '').trim();
        if (s.required && t.isEmpty) return 'required'.tr;
        if (t.isEmpty) return null;
        if (numeric && num.tryParse(t.replaceAll(',', '')) == null) {
          return 'invalid_number'.tr;
        }
        if (s.type == FieldType.email &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
          return 'invalid_email'.tr;
        }
        return null;
      },
    );
  }

  Widget _dateField(BuildContext ctx, FieldSpec s) {
    final v = model.values[s.key];
    final shown = (v == null) ? '' : '$v';
    return FormField<String>(
      key: ValueKey('d_${s.key}_$shown'),
      initialValue: shown,
      validator: (_) => (s.required && shown.isEmpty) ? 'required'.tr : null,
      builder: (st) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final d = await showDatePicker(
            context: ctx,
            initialDate: parseDate(v) ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (d != null) {
            model.set(s.key, formatDate(d));
            s.onChanged?.call(formatDate(d));
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _label(s),
            errorText: st.errorText,
            suffixIcon: shown.isNotEmpty && !s.required
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => model.set(s.key, null),
                  )
                : const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          child: Text(shown.isEmpty ? ' ' : shown),
        ),
      ),
    );
  }

  Widget _dropdown(BuildContext ctx, FieldSpec s) {
    final options = model.dynamicOptions[s.key] ?? s.options;
    final raw = model.values[s.key];
    final cur = (raw == null) ? '' : '$raw';
    final known = options.any((o) => o.value == cur);
    final value = known ? cur : (s.required ? null : '');
    return FormField<String>(
      key: ValueKey('dd_${s.key}_${cur}_${options.length}'),
      initialValue: value,
      validator: (_) => (s.required && (value == null || value.isEmpty))
          ? 'required'.tr
          : null,
      builder: (st) => InputDecorator(
        decoration:
            InputDecoration(labelText: _label(s), errorText: st.errorText),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            isDense: true,
            value: value,
            items: [
              if (!s.required)
                const DropdownMenuItem<String>(value: '', child: Text('—')),
              for (final o in options)
                DropdownMenuItem<String>(
                  value: o.value,
                  child: Text(o.translate ? o.labelKey.tr : o.label,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) {
              model.set(s.key, (v == null || v.isEmpty) ? null : v);
              s.onChanged?.call(v);
            },
          ),
        ),
      ),
    );
  }

  Widget _toggle(BuildContext ctx, FieldSpec s) {
    final on = model.values[s.key] == true || model.values[s.key] == 1;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(ctx).colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        dense: true,
        title: Text(s.label.tr),
        value: on,
        onChanged: (v) {
          model.set(s.key, v);
          s.onChanged?.call(v);
        },
      ),
    );
  }
}

/// Modal bottom sheet with a form. Resolves to the saved map, or null.
Future<Map<String, Object?>?> showFormSheet({
  required String titleKey,
  required List<FieldSpec> specs,
  Map<String, dynamic>? initial,
  Map<String, List<FieldOption>>? options,
  Future<String?> Function(Map<String, Object?> values)? validateExtra,
}) {
  return Get.bottomSheet<Map<String, Object?>>(
    _FormSheet(
      titleKey: titleKey,
      specs: specs,
      initial: initial,
      options: options,
      validateExtra: validateExtra,
    ),
    isScrollControlled: true,
    ignoreSafeArea: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _FormSheet extends StatefulWidget {
  const _FormSheet({
    required this.titleKey,
    required this.specs,
    this.initial,
    this.options,
    this.validateExtra,
  });
  final String titleKey;
  final List<FieldSpec> specs;
  final Map<String, dynamic>? initial;
  final Map<String, List<FieldOption>>? options;
  final Future<String?> Function(Map<String, Object?> values)? validateExtra;

  @override
  State<_FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<_FormSheet> {
  late final FormModel model;
  String? error;

  @override
  void initState() {
    super.initState();
    model = FormModel(widget.specs, widget.initial);
    widget.options?.forEach((k, v) => model.dynamicOptions[k] = v);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!model.validate()) return;
    final map = model.toMap();
    if (widget.validateExtra != null) {
      final err = await widget.validateExtra!(map);
      if (err != null) {
        setState(() => error = err.tr);
        return;
      }
    }
    Get.back(result: map);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(children: [
                Expanded(
                  child: Text(widget.titleKey.tr,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: DynamicForm(model: model),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: Get.back, child: Text('cancel'.tr)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text('save'.tr),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
