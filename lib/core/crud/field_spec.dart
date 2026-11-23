enum FieldType {
  text,
  multiline,
  number,
  money,
  date,
  dropdown,
  toggle,
  phone,
  email
}

/// Option of a dropdown. [translate] = false for literal labels (names from
/// the database); otherwise the label is the translation key `o_<value>`.
class FieldOption {
  const FieldOption(this.value, {String? label, this.translate = true})
      : label = label ?? value;
  final String value;
  final String label;
  final bool translate;

  String get labelKey => translate ? 'o_$label' : label;
}

class FieldSpec {
  const FieldSpec(
    this.key, {
    String? label,
    this.type = FieldType.text,
    this.required = false,
    this.options = const [],
    this.defaultValue,
    this.wide = false,
    this.onChanged,
  }) : label = label ?? 'f_$key';

  final String key;

  /// Translation key. Defaults to `f_<key>`.
  final String label;
  final FieldType type;
  final bool required;
  final List<FieldOption> options;
  final dynamic defaultValue;

  /// Force the field to use the full row on wide screens.
  final bool wide;
  final void Function(dynamic value)? onChanged;

  bool get isTextLike =>
      type == FieldType.text ||
      type == FieldType.multiline ||
      type == FieldType.number ||
      type == FieldType.money ||
      type == FieldType.phone ||
      type == FieldType.email;
}

class FieldGroup {
  const FieldGroup(this.titleKey, this.fields);
  final String titleKey;
  final List<FieldSpec> fields;
}

/// Shorthand builders for option lists whose values are translated keys.
List<FieldOption> opts(List<String> values) =>
    values.map((v) => FieldOption(v)).toList();
