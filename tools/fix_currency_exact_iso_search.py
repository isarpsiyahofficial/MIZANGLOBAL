#!/usr/bin/env python3
"""Prioritize an exact ISO 4217 code over multilingual prefix aliases."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / 'lib' / 'global' / 'global_catalog.dart'
PICKER = ROOT / 'lib' / 'widgets' / 'global_picker_dialog.dart'
TEST = ROOT / 'test' / 'global_setup_test.dart'

catalog = CATALOG.read_text(encoding='utf-8')
anchor = """  LanguageOption language(String code) => languages.firstWhere(
"""
method = """  bool currencyMatches(CurrencyOption item, String query) {
    final normalized = normalizeGlobalSearch(query);
    if (normalized.isEmpty) return true;
    final hasExactIsoCode = currencies.any(
      (candidate) => normalizeGlobalSearch(candidate.code) == normalized,
    );
    if (hasExactIsoCode) {
      return normalizeGlobalSearch(item.code) == normalized;
    }
    return item.matches(query);
  }

"""
if method not in catalog:
    if anchor not in catalog:
        raise SystemExit('GlobalCatalog insertion point is missing')
    catalog = catalog.replace(anchor, method + anchor, 1)
    CATALOG.write_text(catalog, encoding='utf-8')

picker = PICKER.read_text(encoding='utf-8')
old_picker = """  items: catalog.currencies,
  matches: (item, query) => item.matches(query),
"""
new_picker = """  items: catalog.currencies,
  matches: (item, query) => catalog.currencyMatches(item, query),
"""
if old_picker in picker:
    PICKER.write_text(picker.replace(old_picker, new_picker, 1), encoding='utf-8')
elif new_picker not in picker:
    raise SystemExit('Currency picker match wiring is missing')

test = TEST.read_text(encoding='utf-8')
old_test = "catalog.currencies.where((item) => item.matches('TRY')).single.code"
new_test = "catalog.currencies\n          .where((item) => catalog.currencyMatches(item, 'TRY'))\n          .single\n          .code"
if old_test in test:
    TEST.write_text(test.replace(old_test, new_test, 1), encoding='utf-8')
elif "catalog.currencyMatches(item, 'TRY')" not in test:
    raise SystemExit('Exact TRY search assertion is missing')

print('Exact ISO currency search now takes precedence over multilingual prefixes.')
