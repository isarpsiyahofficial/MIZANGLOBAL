#!/usr/bin/env python3
"""Generate a fail-closed 791/791 Russian review candidate outside runtime."""
from __future__ import annotations
import concurrent.futures, hashlib, json, random, re, time
import urllib.error, urllib.parse, urllib.request
from pathlib import Path
from build_greek_locale import ROOT, english_pairs, parse_map

SOURCE_DIR=ROOT/'lib/l10n/el'
OUT_DIR=ROOT/'lib/l10n/ru'
INDEX=ROOT/'lib/l10n/mizan_ru.dart'
MANIFEST=ROOT/'tools/russian_candidate_manifest.json'
ENDPOINT='https://translate.googleapis.com/translate_a/single'
PROTECTED=re.compile(r'(?:LEFFERION PRIME|MİZAN|ISO 4217|Google Play|Android|PDF|CSV|Pro|USD|EUR|TRY|GBP|CHF|JPY|CNY|RUB|PLN|RON|AED|SAR|KWD|QAR|BHD|OMR|\b\d+(?:[.,]\d+)?\b|https?://\S+|[\w.+-]+@[\w.-]+\.[A-Za-z]{2,})')

def quote(value:str)->str:
    return "'"+value.replace('\\','\\\\').replace("'","\\'").replace('$','\\$').replace('\r','\\r').replace('\n','\\n').replace('\t','\\t')+"'"

def groups()->list[tuple[str,list[str]]]:
    result=[]
    for path in sorted(SOURCE_DIR.glob('mizan_el_*.dart')):
        source=path.read_text(encoding='utf-8')
        match=re.search(r'const Map<String, String> (mizanGreek\w+)',source)
        if not match: raise SystemExit(f'Greek source marker missing: {path}')
        result.append((path.stem.removeprefix('mizan_el_'),[k for k,_ in parse_map(source,match.group(0))]))
    return result

def protect(value:str)->tuple[str,dict[str,str]]:
    replacements={}
    def repl(match:re.Match[str])->str:
        token=f'ZXQ{len(replacements):03d}QXZ'; replacements[token]=match.group(0); return token
    return PROTECTED.sub(repl,value),replacements

def translate_once(value:str)->str:
    protected,replacements=protect(value)
    query=urllib.parse.urlencode({'client':'gtx','sl':'en','tl':'ru','dt':'t','q':protected})
    request=urllib.request.Request(f'{ENDPOINT}?{query}',headers={'User-Agent':'Mozilla/5.0 MIZAN-GLOBAL-Russian-Review/1.0','Accept':'application/json'})
    with urllib.request.urlopen(request,timeout=25) as response:
        payload=json.loads(response.read().decode('utf-8'))
    translated=''.join(segment[0] for segment in payload[0] if segment and segment[0]).strip()
    for token,original in replacements.items():
        translated=translated.replace(token,original).replace(token.lower(),original)
    if not translated or any(token in translated or token.lower() in translated for token in replacements):
        raise ValueError('empty translation or unrestored protected token')
    return translated

def translate(value:str)->str:
    error=None
    for attempt in range(1,7):
        try: return translate_once(value)
        except (urllib.error.URLError,urllib.error.HTTPError,TimeoutError,ValueError,json.JSONDecodeError) as exc:
            error=exc
            if attempt<6: time.sleep(min(18,1.4**attempt+random.random()))
    raise RuntimeError(f'translation failed: {value!r}: {error}')

def write_part(suffix:str,pairs:list[tuple[str,str]])->Path:
    class_suffix=''.join(piece.capitalize() for piece in suffix.split('_'))
    name=f'mizanRussian{class_suffix}'; path=OUT_DIR/f'mizan_ru_{suffix}.dart'
    lines=['// MACHINE-GENERATED RUSSIAN REVIEW CANDIDATE — NOT RUNTIME-APPROVED.',f'const Map<String, String> {name} = <String, String>{{']
    lines += [f'  {quote(k)}: {quote(v)},' for k,v in pairs]
    lines += ['};','']; path.write_text('\n'.join(lines),encoding='utf-8'); return path

def main()->None:
    pairs=english_pairs(); english=dict(pairs)
    if len(pairs)!=791 or len(english)!=791: raise SystemExit(f'English coverage changed: {len(pairs)}')
    key_groups=groups(); grouped=[k for _,keys in key_groups for k in keys]
    if len(grouped)!=791 or set(grouped)!=set(english): raise SystemExit('Russian part-key coverage mismatch')
    unique=sorted(set(english.values())); translations={}; failures=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
        futures={pool.submit(translate,value):value for value in unique}
        for done,future in enumerate(concurrent.futures.as_completed(futures),1):
            value=futures[future]
            try: translations[value]=future.result()
            except Exception as exc: failures.append(f'{value!r}: {exc}')
            if done%50==0 or done==len(unique): print(f'Russian candidate progress: {done}/{len(unique)} unique values')
    if failures: raise SystemExit('\n'.join(failures))
    OUT_DIR.mkdir(parents=True,exist_ok=True); candidate={}; paths=[]
    for suffix,keys in key_groups:
        part=[(key,translations[english[key]]) for key in keys]; candidate.update(part); paths.append(write_part(suffix,part))
    imports=[f"import 'ru/{path.name}';" for path in paths]
    spreads=[f"  ...mizanRussian{''.join(piece.capitalize() for piece in path.stem.removeprefix('mizan_ru_').split('_'))}," for path in paths]
    INDEX.write_text('\n'.join(['// MACHINE-GENERATED RUSSIAN REVIEW CANDIDATE — NOT RUNTIME-APPROVED.',*imports,'','const Map<String, String> mizanRussian = <String, String>{',*spreads,'};','']),encoding='utf-8')
    if len(candidate)!=791 or set(candidate)!=set(english): raise SystemExit('Written Russian coverage mismatch')
    digest=hashlib.sha256(json.dumps(candidate,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    MANIFEST.write_text(json.dumps({'status':'review-candidate-only','sourceLanguage':'en','targetLanguage':'ru-RU','count':791,'uniqueSourceValues':len(unique),'sha256':digest,'runtimeIntegrated':False},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'Russian candidate generated: 791/791 values; sha256={digest}')
if __name__=='__main__': main()
