import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import 'field_spec.dart';

/// Holds the values, text controllers and validation of one form section.
class FormModel extends ChangeNotifier {
  FormModel(this.specs, [Map<String, dynamic>? initial]) {
    for (final s in specs) {
      final v = initial != null && initial.containsKey(s.key)
          ? initial[s.key]
          : s.defaultValue;
      values[s.key] = v;
      if (s.isTextLike) {
        controllers[s.key] = TextEditingController(text: _show(v));
      }
    }
  }

  final List<FieldSpec> specs;
  final Map<String, dynamic> values = {};
  final Map<String, TextEditingController> controllers = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Runtime options for dropdowns whose choices come from the database.
  final Map<String, List<FieldOption>> dynamicOptions = {};

  String _show(dynamic v) {
    if (v == null) return '';
    if (v is double && v == v.roundToDouble()) return v.toStringAsFixed(0);
    return '$v';
  }

  dynamic get(String key) => values[key];

  String text(String key) => controllers[key]?.text.trim() ?? '';

  /// Programmatic update (also refreshes the visible text field).
  void set(String key, dynamic v, {bool notify = true}) {
    values[key] = v;
    final c = controllers[key];
    if (c != null) {
      final t = _show(v);
      if (c.text != t) c.text = t;
    }
    if (notify) notifyListeners();
  }

  void setAll(Map<String, dynamic> data) {
    data.forEach((k, v) {
      if (values.containsKey(k)) set(k, v, notify: false);
    });
    notifyListeners();
  }

  void setOptions(String key, List<FieldOption> o) {
    dynamicOptions[key] = o;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  bool _isEmpty(FieldSpec s) {
    if (s.isTextLike) return text(s.key).isEmpty;
    final v = values[s.key];
    return v == null || '$v'.isEmpty;
  }

  /// True when every required field is filled and every visible validator
  /// passes. Works even when the section is not currently on screen.
  bool validate() {
    final visible = formKey.currentState?.validate() ?? true;
    var ok = visible;
    for (final s in specs) {
      if (s.required && _isEmpty(s)) ok = false;
    }
    return ok;
  }

  /// Database-ready map: numbers parsed, empty strings -> null, bool -> 0/1.
  Map<String, Object?> toMap() {
    final m = <String, Object?>{};
    for (final s in specs) {
      switch (s.type) {
        case FieldType.number:
        case FieldType.money:
          final t = text(s.key).replaceAll(',', '');
          m[s.key] = t.isEmpty ? null : num.tryParse(t);
          break;
        case FieldType.toggle:
          m[s.key] = (values[s.key] == true || values[s.key] == 1) ? 1 : 0;
          break;
        case FieldType.date:
        case FieldType.dropdown:
          final v = values[s.key];
          m[s.key] = (v == null || '$v'.isEmpty) ? null : v;
          break;
        default:
          final t = text(s.key);
          m[s.key] = t.isEmpty ? null : t;
      }
    }
    return m;
  }

  /// Same as [toMap] but values are plain strings (clause storage).
  Map<String, String> toStringMap() => {
        for (final e in toMap().entries)
          if (e.value != null) e.key: '${e.value}'
      };

  DateTime? dateOf(String key) => parseDate(values[key]);

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
