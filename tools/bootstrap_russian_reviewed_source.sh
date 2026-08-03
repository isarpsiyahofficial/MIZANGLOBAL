#!/usr/bin/env bash
set -euo pipefail

cat > /tmp/russian-reviewed-parts.sha256 <<'HASHES'
d1fbdbfdf1a92efb727cc16aa24197d47f23d4043b2940bf4e85f5ff32171e20  tools/russian_reviewed_payload/part.00.b64
a0dc1364af16085c10e3164c81658f31b729bf57d6a50e3184c7034dfe2d2bef  tools/russian_reviewed_payload/part.01.b64
717b604722ad73de7545b5b0e20ebe7c6b45d371a9f35704706cdf18825aedeb  tools/russian_reviewed_payload/part.02.b64
454b3368155368444885f693110ce15743a114c0f3cfd7ce9c2858a2ecc90559  tools/russian_reviewed_payload/part.03.b64
288bb0a78a8a311c17a6a67e0ab212c3d06a0011988ee52c6fda9a354d672160  tools/russian_reviewed_payload/part.04.b64
04897b0c04b4e8a30424aad8efb0e59f96ffac8424088f20a360a73b621fdab4  tools/russian_reviewed_payload/part.05.b64
87b6e418b697b3f2948eed16437ba07739522e93bd9784cf4ecb8fc3475db28c  tools/russian_reviewed_payload/part.06.b64
1797635318a29147e4d936a00529f735d4f4cd6bb6067d5a2ad6bb9218043666  tools/russian_reviewed_payload/part.07.b64
07fbce5728a013993d2b0f001427f6334ddc27e5cb7c3736ed76d1fba21d6c2e  tools/russian_reviewed_payload/part.08.b64
3ef4775dd83fa36761af354a1b65e1c8cc74ad9b4dd192881b212fa10ff00785  tools/russian_reviewed_payload/part.09.b64
6637d6bb198affd79e2579c74d0dc3947afb52d7ffe9b5d48d2211edde11ce21  tools/russian_reviewed_payload/part.10.b64
5cb5f3c42a7baf867ab959aaeb041b43fadfe2f7938c9aa5817e11eea7abc66f  tools/russian_reviewed_payload/part.11.b64
e2989cac22426bebfc57c6751c545c0ab0a44607d5ff7761193fee9572b37582  tools/russian_reviewed_payload/part.12.b64
be59612bd63eecc6310368cfee7dd0f26e829515f94ebe5bb7eec0ff39d061e7  tools/russian_reviewed_payload/part.13.b64
8503fa380a6c8a2b3c6b3a8104cff5af0fa7bb41618e6fbd9e75afd908b7d752  tools/russian_reviewed_payload/part.14.b64
369e126df1dedfa47d5d1a4206b692c033177620657bc0e4c05fa0573ce48402  tools/russian_reviewed_payload/part.15.b64
8de0bef5c17ebe78fe8fbaed913fefb3bf22b5d0243ea48031e9009dec25f56a  tools/russian_reviewed_payload/part.16.b64
HASHES
sha256sum -c /tmp/russian-reviewed-parts.sha256

cat tools/russian_reviewed_payload/part.*.b64 | base64 --decode > /tmp/russian-reviewed-source.tar.xz
echo 'a5c0ccefaa8b6e1c68cee58167380c907b1fd28e396c4e206a99a3af56386b0d  /tmp/russian-reviewed-source.tar.xz' | sha256sum -c -
xz -t /tmp/russian-reviewed-source.tar.xz
tar -tJf /tmp/russian-reviewed-source.tar.xz
tar -xJf /tmp/russian-reviewed-source.tar.xz
python -m py_compile tools/apply_russian_review.py tools/build_russian_locale.py tools/audit_russian_native_copy.py
python -m pip install 'Babel>=2.15,<3'
python tools/apply_russian_review.py
python tools/build_russian_locale.py
python tools/build_russian_locale.py --verify
python tools/audit_russian_native_copy.py

python tools/validate_english_localization.py
python tools/validate_spanish_localization.py
python tools/validate_portuguese_br_localization.py
python tools/validate_spanish_visible_copy.py
python tools/build_pt_pt_locale.py --verify
python tools/build_french_locale.py --verify
python tools/build_german_locale.py --verify
python tools/build_italian_locale.py --verify
python tools/build_dutch_locale.py --verify
python tools/build_polish_locale.py --verify
python tools/build_romanian_locale.py --verify
python tools/build_greek_locale.py --verify

python - <<'PY'
import json
from pathlib import Path
root=Path('.')
review=json.loads((root/'tools/russian_review.json').read_text(encoding='utf-8'))
assert review['count']==791
assert review['corrected']==397
assert review['accepted']==394
assert review['candidateSha256']=='59a4a2482d376b5bd71e5fc513e9c86d55bfc4362593c3de540402e6418e9357'
i18n=(root/'lib/l10n/mizan_i18n.dart').read_text(encoding='utf-8')
assert "import 'mizan_ru.dart';" in i18n
assert "'ru'" in i18n.split('supportedLanguageTags',1)[1].split(';',1)[0]
assert "Locale('ru', 'RU')" in (root/'lib/main.dart').read_text(encoding='utf-8')
for filename,count in [('languages_v1.json',29),('countries_v1.json',161),('currencies_v1.json',154)]:
    payload=json.loads((root/'assets/data'/filename).read_text(encoding='utf-8'))
    assert payload['count']==count
    assert all(item.get('nameRu') for item in payload['items'])
print('Russian runtime, locked review and 29/161/154 catalog coverage verified.')
PY

rm -rf tools/russian_reviewed_payload

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git add \
  tools/apply_russian_review.py \
  tools/build_russian_locale.py \
  tools/audit_russian_native_copy.py \
  tools/russian_review.json \
  tools/russian_native_terms.json \
  tools/*.py \
  assets/data/languages_v1.json \
  assets/data/countries_v1.json \
  assets/data/currencies_v1.json \
  lib/l10n/ru \
  lib/l10n/mizan_ru.dart \
  lib/l10n/mizan_ru_dynamic.dart \
  lib/l10n/mizan_i18n.dart \
  lib/main.dart \
  lib/global/global_catalog.dart \
  lib/core/formatters.dart \
  lib/widgets/global_picker_dialog.dart \
  test/*.dart
git add -u tools/russian_reviewed_payload
git diff --cached --exit-code --quiet && { echo 'No reviewed Russian changes to commit.'; exit 1; }
git commit -m 'feat(ru): integrate reviewed Russian product source'
git push origin HEAD:agent/russian-localization
