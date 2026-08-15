#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
FIL_FILES=[ROOT/'lib/l10n/fil/mizan_fil_core.dart',ROOT/'lib/l10n/fil/mizan_fil_dashboard.dart',ROOT/'lib/l10n/fil/mizan_fil_records.dart',ROOT/'lib/l10n/fil/mizan_fil_reports.dart',ROOT/'lib/l10n/fil/mizan_fil_settings.dart',ROOT/'lib/l10n/fil/mizan_fil_validation.dart']
ID_FILES=[ROOT/'lib/l10n/id/mizan_id_core.dart',ROOT/'lib/l10n/id/mizan_id_dashboard.dart',ROOT/'lib/l10n/id/mizan_id_records.dart',ROOT/'lib/l10n/id/mizan_id_reports.dart',ROOT/'lib/l10n/id/mizan_id_settings.dart',ROOT/'lib/l10n/id/mizan_id_validation.dart']
ENTRY = re.compile(r"'((?:\\.|[^'])*)'\s*:\s*'((?:\\.|[^'])*)'\s*,?", re.S)
FORBIDDEN_SCRIPT=re.compile(r'[\u0370-\u052f\u0590-\u0dff\u2e80-\u9fff\uac00-\ud7af]')
FORBIDDEN_TERMS=re.compile(r'\b(pengeluaran|pembayaran|catatan|tagihan|cicilan|notifikasi|pengingat|perangkat|riwayat|pemasukan|pengaturan|perbelanjaan|hutang|pemberitahuan|peringatan|tetapan|sandaran|tarikh|ansuran)\b',re.I)

def pairs(path:Path): return ENTRY.findall(path.read_text(encoding='utf-8'))
def keys(paths): return [k for p in paths for k,_ in pairs(p)]

def catalog_count(source:str,name:str)->int:
    m=re.search(rf"const\s+{name}\s*=\s*<String\s*,\s*String>\s*\{{(.*?)\n\}};",source,re.S)
    assert m,f'missing {name}'
    return len(ENTRY.findall(m.group(1)))

def main():
    fil_keys=keys(FIL_FILES); id_keys=keys(ID_FILES)
    values=[v for p in FIL_FILES for _,v in pairs(p)]
    assert len(fil_keys)==791,len(fil_keys)
    assert len(set(fil_keys))==791,'duplicate Filipino keys'
    assert set(fil_keys)==set(id_keys),'Filipino key set differs from 791-key product source'
    assert all(v.strip() for v in values),'empty Filipino value'
    joined='\n'.join(values)
    assert not FORBIDDEN_SCRIPT.search(joined),'foreign-script system copy leaked into Filipino'
    assert not FORBIDDEN_TERMS.search(joined),'Indonesian/Malay product terminology leaked into Filipino'
    brand_neutral = joined.replace('MİZAN', '').replace('LEFFERION PRIME', '')
    assert not re.search(r'[ğışçöüİ]',brand_neutral),'Turkish system copy leaked into Filipino'
    catalog=(ROOT/'lib/l10n/fil/mizan_fil_catalog.dart').read_text(encoding='utf-8')
    assert catalog_count(catalog,'filipinoLanguageNames')==29
    assert catalog_count(catalog,'filipinoCountryNames')==161
    assert catalog_count(catalog,'filipinoCurrencyNames')==154
    runtime=(ROOT/'lib/l10n/mizan_i18n.dart').read_text(encoding='utf-8')
    formatters=(ROOT/'lib/core/formatters.dart').read_text(encoding='utf-8')
    main_dart=(ROOT/'lib/main.dart').read_text(encoding='utf-8')
    for marker in ("'fil'",'mizanFilipino','translateFilipinoReviewedDynamic','KINUKUMPIRMA KO'): assert marker in runtime,marker
    assert re.search(r"\bcode\s*==\s*'PHP'", formatters), 'PHP formatter branch'
    for marker in ('_filipinoMonths','₱'): assert marker in formatters,marker
    assert re.search(r"Locale\(\s*'fil'\s*,\s*'PH'\s*\)", main_dart)
    print('Filipino native-copy audit passed: 791/791, 29/161/154 catalogs, runtime, PHP and locale markers.')
if __name__=='__main__': main()
