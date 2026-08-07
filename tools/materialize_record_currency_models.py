#!/usr/bin/env python3
from pathlib import Path
import subprocess

p = Path('lib/screens/record_form_dialogs.dart')
s = p.read_text(encoding='utf-8')

imports_anchor = "import '../core/theme.dart';\nimport '../models/mizan_models.dart';\n"
imports_new = "import '../core/theme.dart';\nimport '../global/global_catalog.dart';\nimport '../models/mizan_models.dart';\nimport '../widgets/global_picker_dialog.dart';\n"
if "../global/global_catalog.dart" not in s:
    if imports_anchor not in s:
        raise SystemExit('form import anchor missing')
    s = s.replace(imports_anchor, imports_new, 1)

picker_code = r'''
class _RecordCurrencyField extends StatelessWidget {
  const _RecordCurrencyField({
    required this.currencyCode,
    required this.onChanged,
  });

  final String currencyCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    GlobalCatalog? catalog;
    try {
      catalog = GlobalCatalogRepository.current;
    } on StateError {
      catalog = null;
    }
    final option = catalog?.currency(currencyCode);
    final subtitle = option == null
        ? currencyCode
        : '${option.code} · ${option.nameFor(MizanI18n.languageTag)} · ${option.primarySymbol}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Para birimi seç'),
      subtitle: Text.user(subtitle),
      leading: const Icon(Icons.currency_exchange_outlined),
      trailing: const Icon(Icons.chevron_right),
      enabled: catalog != null,
      onTap: catalog == null
          ? null
          : () async {
              final selected = await showCurrencyPicker(
                context,
                catalog: catalog!,
                selectedCode: currencyCode,
              );
              if (selected != null) onChanged(selected.code);
            },
    );
  }
}

'''
if 'class _RecordCurrencyField extends StatelessWidget' not in s:
    anchor = 'class _MoneyField extends StatelessWidget {'
    if anchor not in s:
        raise SystemExit('MoneyField class anchor missing')
    s = s.replace(anchor, picker_code + anchor, 1)

configs = [
    ('_DebtFormState', 'widget.debt', ['addDebtProduct', 'updateDebtProduct']),
    ('_PersonalDebtFormState', 'widget.debt', ['addPersonalDebt', 'updatePersonalDebt']),
    ('_BillFormState', 'widget.bill', ['addBill', 'updateBill']),
    ('_SubscriptionFormState', 'widget.subscription', ['addSubscription', 'updateSubscription']),
    ('_RentFormState', 'widget.rent', ['addRent', 'updateRent']),
]

for class_name, item_expr, methods in configs:
    start = s.index(f'class {class_name} extends State<')
    nxt = s.find('\nclass ', start + 1)
    end = len(s) if nxt < 0 else nxt
    region = s[start:end]

    if 'late String currencyCode;' not in region:
        key_anchor = '  final key = GlobalKey<FormState>();\n'
        if key_anchor not in region:
            raise SystemExit(f'{class_name}: key anchor missing')
        region = region.replace(key_anchor, key_anchor + '  late String currencyCode;\n', 1)

    init_anchor = f'    final item = {item_expr};\n'
    init_new = init_anchor + '    currencyCode = item?.currencyCode ?? widget.controller.state.defaultCurrencyCode;\n'
    if 'currencyCode = item?.currencyCode' not in region:
        if init_anchor not in region:
            raise SystemExit(f'{class_name}: init item anchor missing')
        region = region.replace(init_anchor, init_new, 1)

    if '_RecordCurrencyField(' not in region:
        field = "_RecordCurrencyField(\n          currencyCode: currencyCode,\n          onChanged: (value) => setState(() => currencyCode = value),\n        ),\n"
        children_anchor = '      children: [\n'
        idx = region.find(children_anchor)
        if idx >= 0:
            after = idx + len(children_anchor)
            region = region[:after] + '        ' + field + region[after:]
        else:
            # Some compact forms compose children in a local list instead of
            # passing `children:` directly to _DialogShell. Insert before the
            # first real form control in build(), preserving existing layout.
            build_idx = region.find('  Widget build(BuildContext context)')
            control_candidates = [
                region.find('DropdownButtonFormField<', build_idx),
                region.find('TextFormField(', build_idx),
                region.find('_DateField(', build_idx),
            ]
            control_candidates = [i for i in control_candidates if i >= 0]
            if not control_candidates:
                raise SystemExit(f'{class_name}: form control anchor missing')
            control_idx = min(control_candidates)
            line_start = region.rfind('\n', 0, control_idx) + 1
            indent = region[line_start:control_idx]
            region = region[:line_start] + indent + field.replace('\n', '\n' + indent).rstrip(indent) + region[line_start:]

    for method in methods:
        call = f'widget.controller.{method}(\n'
        pos = 0
        while True:
            idx = region.find(call, pos)
            if idx < 0:
                break
            after = idx + len(call)
            nearby = region[after:after + 300]
            if 'currencyCode: currencyCode,' not in nearby:
                line_start = region.rfind('\n', 0, idx) + 1
                indent = region[line_start:idx] + '  '
                region = region[:after] + indent + 'currencyCode: currencyCode,\n' + region[after:]
                pos = after + len(indent) + 32
            else:
                pos = after
    s = s[:start] + region + s[end:]

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(p)], check=True)
