#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path
from babel import Locale

ROOT = Path(__file__).resolve().parents[1]
locale = Locale.parse('sw')

def load_codes(name: str) -> list[str]:
    data = json.loads((ROOT / 'assets' / 'data' / name).read_text(encoding='utf-8'))
    return [str(item['code']) for item in data['items']]

def dart_quote(value: str) -> str:
    return "'" + value.replace('\\', '\\\\').replace("'", "\\'").replace('\n', ' ') + "'"

language_codes = load_codes('languages_v1.json')
country_codes = load_codes('countries_v1.json')
currency_codes = load_codes('currencies_v1.json')
lang_alias = {'pt-BR':'pt', 'pt-PT':'pt', 'fil':'fil', 'zh':'zh'}
langs = {code: str(locale.languages.get(lang_alias.get(code, code), code)) for code in language_codes}
langs.update({'pt-BR':'Kireno (Brazili)','pt-PT':'Kireno (Ureno)','fil':'Kifilipino','zh':'Kichina','sw':'Kiswahili'})
countries = {code: str(locale.territories.get(code, code)) for code in country_codes}
currencies = {code: str(locale.currencies.get(code, code)) for code in currency_codes}
currencies.update({'XCG':'Gilda ya Karibea','ZWG':'Dhahabu ya Zimbabwe'})
assert len(langs) == 29 and len(countries) == 161 and len(currencies) == 154
assert all(v for v in langs.values()) and all(v for v in countries.values()) and all(v for v in currencies.values())

def render(name: str, values: dict[str,str]) -> str:
    body = ',\n  '.join(f"{dart_quote(k)}:{dart_quote(v)}" for k,v in values.items())
    return f"const {name}=<String,String>{{\n  {body},\n}};\n"
out = '// Reviewed offline Swahili catalog names used by global selectors.\n' + render('swahiliLanguageNames', langs) + render('swahiliCountryNames', countries) + render('swahiliCurrencyNames', currencies)
path = ROOT / 'lib' / 'l10n' / 'sw' / 'mizan_sw_catalog.dart'
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(out, encoding='utf-8')
