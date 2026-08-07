#!/usr/bin/env python3
from pathlib import Path
import subprocess


def add_imports(path: Path):
    s = path.read_text(encoding='utf-8')
    if "../global/global_catalog.dart" not in s:
        anchor = "import '../models/mizan_models.dart';\n"
        if anchor not in s:
            raise SystemExit(f'{path}: model import anchor missing')
        s = s.replace(
            anchor,
            "import '../global/global_catalog.dart';\n" + anchor + "import '../widgets/global_picker_dialog.dart';\n",
            1,
        )
    path.write_text(s, encoding='utf-8')

expense_path = Path('lib/screens/expenses_screen.dart')
add_imports(expense_path)
s = expense_path.read_text(encoding='utf-8')
start = s.index('  Future<void> _showExpenseForm(')
end = s.index('\n  Future<void> _confirmDeleteExpense', start)
region = s[start:end]
currency_init = "    var currencyCode =\n        item?.currencyCode ?? widget.controller.state.defaultCurrencyCode;\n"
if 'item?.currencyCode ?? widget.controller.state.defaultCurrencyCode' not in region:
    anchor = '    var spentAt = item?.spentAt ?? dateOnly(DateTime.now());\n'
    if anchor not in region: raise SystemExit('expense currency init anchor missing')
    region = region.replace(anchor, anchor + currency_init, 1)
if "showCurrencyPicker(" not in region:
    anchor = '                      const SizedBox(height: 12),\n                      TextFormField(\n                        controller: name,\n'
    if anchor not in region: raise SystemExit('expense picker placement anchor missing')
    picker = """                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.currency_exchange_outlined),
                        title: const Text('Para birimi seç'),
                        subtitle: Text.user(currencyCode),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final catalog = GlobalCatalogRepository.current;
                          final selected = await showCurrencyPicker(
                            dialogContext,
                            catalog: catalog,
                            selectedCode: currencyCode,
                          );
                          if (selected != null) {
                            setDialogState(() => currencyCode = selected.code);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: name,
"""
    region = region.replace(anchor, picker, 1)
for method in ['addExpense', 'updateExpense']:
    call = f'widget.controller.{method}(\n'
    pos = region.find(call)
    if pos < 0: raise SystemExit(f'expense {method} call missing')
    after = pos + len(call)
    if 'currencyCode: currencyCode,' not in region[after:after+240]:
        next_line = region.find('\n', after) + 1
        first_end = region.find('\n', next_line)
        first = region[next_line:first_end]
        indent = first[:len(first)-len(first.lstrip())]
        region = region[:next_line] + indent + 'currencyCode: currencyCode,\n' + region[next_line:]
s = s[:start] + region + s[end:]
expense_path.write_text(s, encoding='utf-8')

dash_path = Path('lib/screens/dashboard_screen.dart')
add_imports(dash_path)
s = dash_path.read_text(encoding='utf-8')
start = s.index('  Future<void> _showIncomeForm(')
end = s.index('\n  static String _weekdayName', start)
region = s[start:end]
if 'income?.currencyCode ?? controller.state.defaultCurrencyCode' not in region:
    anchor = '    var frequency = income?.frequency ?? IncomeFrequency.monthly;\n'
    if anchor not in region: raise SystemExit('income currency init anchor missing')
    region = region.replace(
        anchor,
        "    var currencyCode =\n        income?.currencyCode ?? controller.state.defaultCurrencyCode;\n" + anchor,
        1,
    )
if 'showCurrencyPicker(' not in region:
    anchor = '                    const SizedBox(height: 12),\n                    TextFormField(\n                      controller: amount,\n'
    if anchor not in region: raise SystemExit('income picker placement anchor missing')
    picker = """                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.currency_exchange_outlined),
                      title: const Text('Para birimi seç'),
                      subtitle: Text.user(currencyCode),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final catalog = GlobalCatalogRepository.current;
                        final selected = await showCurrencyPicker(
                          dialogContext,
                          catalog: catalog,
                          selectedCode: currencyCode,
                        );
                        if (selected != null) {
                          setDialogState(() => currencyCode = selected.code);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amount,
"""
    region = region.replace(anchor, picker, 1)
region = region.replace("const InputDecoration(\n                          labelText: 'Gelir tutarı',\n                          suffixText: 'TL',", "InputDecoration(\n                          labelText: 'Gelir tutarı',\n                          suffixText: currencyCode,")
for method in ['addIncome', 'updateIncome']:
    call = f'controller.{method}(\n'
    pos = region.find(call)
    if pos < 0: raise SystemExit(f'income {method} call missing')
    after = pos + len(call)
    if 'currencyCode: currencyCode,' not in region[after:after+260]:
        next_line = region.find('\n', after) + 1
        first_end = region.find('\n', next_line)
        first = region[next_line:first_end]
        indent = first[:len(first)-len(first.lstrip())]
        region = region[:next_line] + indent + 'currencyCode: currencyCode,\n' + region[next_line:]
s = s[:start] + region + s[end:]
s = s.replace('money(income.amount)', 'money(income.amount, currencyCode: income.currencyCode)')
dash_path.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(expense_path), str(dash_path)], check=True)
