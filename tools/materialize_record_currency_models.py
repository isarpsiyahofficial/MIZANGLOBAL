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
    ('_DebtFormState', 'item', 'widget.debt', ['addDebtProduct', 'updateDebtProduct']),
    ('_PersonalDebtFormState', 'item', 'widget.debt', ['addPersonalDebt', 'updatePersonalDebt']),
    ('_BillFormState', 'item', 'widget.bill', ['addBill', 'updateBill']),
    ('_SubscriptionFormState', 'item', 'widget.subscription', ['addSubscription', 'updateSubscription']),
    ('_RentFormState', 'i', 'widget.rent', ['addRent', 'updateRent']),
]

for class_name, item_name, item_expr, methods in configs:
    start = s.index(f'class {class_name} extends State<')
    nxt = s.find('\nclass ', start + 1)
    end = len(s) if nxt < 0 else nxt
    region = s[start:end]

    if 'late String currencyCode;' not in region:
        key_anchor = '  final key = GlobalKey<FormState>();\n'
        if key_anchor not in region:
            raise SystemExit(f'{class_name}: key anchor missing')
        region = region.replace(key_anchor, key_anchor + '  late String currencyCode;\n', 1)

    init_anchor = f'    final {item_name} = {item_expr};\n'
    init_new = init_anchor + f'    currencyCode = {item_name}?.currencyCode ?? widget.controller.state.defaultCurrencyCode;\n'
    if 'widget.controller.state.defaultCurrencyCode' not in region[region.find('void initState()'):region.find('void dispose()')]:
        if init_anchor not in region:
            raise SystemExit(f'{class_name}: init anchor missing')
        region = region.replace(init_anchor, init_new, 1)

    if '_RecordCurrencyField(' not in region:
        field_lines = [
            '_RecordCurrencyField(',
            '  currencyCode: currencyCode,',
            '  onChanged: (value) => setState(() => currencyCode = value),',
            '),',
        ]
        # Both regular `_DialogShell` and compact arrow-body forms use a
        # `children: [` list, only indentation differs.
        child_pos = region.find('children: [')
        if child_pos < 0:
            raise SystemExit(f'{class_name}: children list missing')
        line_start = region.rfind('\n', 0, child_pos) + 1
        indent = region[line_start:child_pos]
        after = region.find('\n', child_pos) + 1
        child_indent = indent + '  '
        field = ''.join(child_indent + line + '\n' for line in field_lines)
        region = region[:after] + field + region[after:]

    for method in methods:
        call = f'widget.controller.{method}(\n'
        pos = 0
        while True:
            idx = region.find(call, pos)
            if idx < 0:
                break
            after = idx + len(call)
            nearby = region[after:after + 320]
            if 'currencyCode: currencyCode,' not in nearby:
                next_line = region.find('\n', after)
                if next_line < 0:
                    raise SystemExit(f'{class_name}: {method} call line missing')
                first_arg_start = next_line + 1
                first_arg_end = region.find('\n', first_arg_start)
                first_line = region[first_arg_start:first_arg_end]
                arg_indent = first_line[:len(first_line) - len(first_line.lstrip())]
                region = region[:first_arg_start] + arg_indent + 'currencyCode: currencyCode,\n' + region[first_arg_start:]
                pos = first_arg_start + len(arg_indent) + 32
            else:
                pos = after
    s = s[:start] + region + s[end:]

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(p)], check=True)
