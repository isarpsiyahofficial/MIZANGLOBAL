#!/usr/bin/env python3
"""Wire the fully reviewed Brazilian Portuguese locale into runtime sources."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"Expected exactly one integration target in {path.relative_to(ROOT)}; "
            f"found {count}: {old[:80]!r}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_all(path: Path, old: str, new: str, expected: int) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != expected:
        raise SystemExit(
            f"Expected {expected} integration targets in {path.relative_to(ROOT)}; "
            f"found {count}: {old[:80]!r}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")


def integrate_i18n() -> None:
    path = ROOT / "lib/l10n/mizan_i18n.dart"
    replace_once(
        path,
        "import 'mizan_es.dart';",
        "import 'mizan_es.dart';\nimport 'mizan_pt_br.dart';\nimport 'mizan_pt_br_dynamic.dart';",
    )
    replace_once(
        path,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR'};",
    )
    replace_once(
        path,
        "  static bool get isSpanish => _languageTag == 'es';\n",
        "  static bool get isSpanish => _languageTag == 'es';\n"
        "  static bool get isPortugueseBr => _languageTag == 'pt-BR';\n",
    )
    replace_once(
        path,
        "    'es' => 'CONFIRMO',\n    _ => 'ONAYLIYORUM',",
        "    'es' => 'CONFIRMO',\n"
        "    'pt-BR' => 'CONFIRMO',\n"
        "    _ => 'ONAYLIYORUM',",
    )
    replace_once(
        path,
        """  static String normalizeLanguageTag(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'en' || normalized.startsWith('en-')) return 'en';
    if (normalized == 'es' || normalized.startsWith('es-')) return 'es';
    return 'tr';
  }
""",
        """  static String normalizeLanguageTag(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', '-');
    if (normalized == 'en' || normalized.startsWith('en-')) return 'en';
    if (normalized == 'es' || normalized.startsWith('es-')) return 'es';
    if (normalized == 'pt-br') return 'pt-BR';
    return 'tr';
  }
""",
    )
    replace_once(
        path,
        """  static bool isSupported(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return normalized == 'tr' ||
        normalized.startsWith('tr-') ||
        normalized == 'en' ||
        normalized.startsWith('en-') ||
        normalized == 'es' ||
        normalized.startsWith('es-');
  }
""",
        """  static bool isSupported(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', '-');
    return normalized == 'tr' ||
        normalized.startsWith('tr-') ||
        normalized == 'en' ||
        normalized.startsWith('en-') ||
        normalized == 'es' ||
        normalized.startsWith('es-') ||
        normalized == 'pt-br';
  }
""",
    )
    replace_once(
        path,
        """    } else {
      result =
          mizanSpanish[visibleSource] ??
          translateSpanishDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'es'),
          );
    }
""",
        """    } else if (effective == 'es') {
      result =
          mizanSpanish[visibleSource] ??
          translateSpanishDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'es'),
          );
    } else {
      result =
          mizanPortugueseBr[visibleSource] ??
          translatePortugueseBrReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-BR'),
          );
    }
""",
    )


def integrate_main() -> None:
    path = ROOT / "lib/main.dart"
    replace_once(
        path,
        "        locale: Locale(languageTag),",
        "        locale: languageTag == 'pt-BR'\n"
        "            ? const Locale('pt', 'BR')\n"
        "            : Locale(languageTag),",
    )
    replace_once(
        path,
        "        supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')],",
        "        supportedLocales: const [\n"
        "          Locale('tr'),\n"
        "          Locale('en'),\n"
        "          Locale('es'),\n"
        "          Locale('pt', 'BR'),\n"
        "        ],",
    )


def integrate_catalog() -> None:
    path = ROOT / "lib/global/global_catalog.dart"
    replace_all(
        path,
        "    required this.nameEs,\n",
        "    required this.nameEs,\n    required this.namePtBr,\n",
        3,
    )
    replace_all(
        path,
        "  final String nameEs;\n",
        "  final String nameEs;\n  final String namePtBr;\n",
        3,
    )
    replace_all(
        path,
        "    nameEs: json['nameEs']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameEs: json['nameEs']?.toString() ?? json['nameEn']?.toString() ?? '',\n"
        "    namePtBr:\n"
        "        json['namePtBr']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'es' => nameEs,\n    _ => nameTr,",
        "    'es' => nameEs,\n    'pt-BR' => namePtBr,\n    _ => nameTr,",
        3,
    )
    replace_once(
        path,
        "      '$code $nativeName $nameTr $nameEn $nameEs',",
        "      '$code $nativeName $nameTr $nameEn $nameEs $namePtBr',",
    )
    replace_once(
        path,
        "      '$code $nameTr $nameEn $nameEs $nativeName',",
        "      '$code $nameTr $nameEn $nameEs $namePtBr $nativeName',",
    )
    replace_once(
        path,
        "      nameEs,\n      ...symbols,",
        "      nameEs,\n      namePtBr,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    path = ROOT / "lib/core/formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isTurkish && code == 'TRY') {
    return '$amount TL';
  }
  return '$code $amount';
""",
        """  if (MizanI18n.isTurkish && code == 'TRY') {
    return '$amount TL';
  }
  if (MizanI18n.isPortugueseBr && code == 'BRL') {
    return 'R\$ $amount';
  }
  return '$code $amount';
""",
    )
    replace_once(
        path,
        """  const esMonths = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
""",
        """  const esMonths = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  const ptBrMonths = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
""",
    )
    replace_once(
        path,
        "  final months = MizanI18n.isSpanish ? esMonths : trMonths;\n",
        "  final months = MizanI18n.isSpanish\n"
        "      ? esMonths\n"
        "      : (MizanI18n.isPortugueseBr ? ptBrMonths : trMonths);\n",
    )
    replace_once(
        path,
        """  const esMonths = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
""",
        """  const esMonths = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  const ptBrMonths = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isSpanish) {
    return '${esMonths[value.month - 1]} de ${value.year}';
  }
  return '${trMonths[value.month - 1]} ${value.year}';
""",
        """  if (MizanI18n.isSpanish) {
    return '${esMonths[value.month - 1]} de ${value.year}';
  }
  if (MizanI18n.isPortugueseBr) {
    return '${ptBrMonths[value.month - 1]} de ${value.year}';
  }
  return '${trMonths[value.month - 1]} ${value.year}';
""",
    )


def update_legacy_validators() -> None:
    english = ROOT / "tools/validate_english_localization.py"
    replace_once(
        english,
        "    if path == I18N or rel in {\"lib/l10n/mizan_es.dart\", \"lib/global/global_catalog.dart\"}:\n",
        "    if path == I18N or rel in {\n"
        "        \"lib/l10n/mizan_es.dart\",\n"
        "        \"lib/l10n/mizan_pt_br.dart\",\n"
        "        \"lib/l10n/mizan_pt_br_dynamic.dart\",\n"
        "        \"lib/global/global_catalog.dart\",\n"
        "    }:\n",
    )
    replace_once(
        english,
        "if \"static const supportedLanguageTags = <String>{'tr', 'en', 'es'};\" not in text:\n    failures.append(\"Turkish, English and Spanish must be enabled at this stage\")",
        "if \"static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR'};\" not in text:\n"
        "    failures.append(\"Turkish, English, Spanish and Brazilian Portuguese must be enabled\")",
    )
    replace_once(
        english,
        "if \"supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')]\" not in main_source:\n    failures.append(\"MaterialApp must expose Turkish, English and Spanish\")",
        "if \"Locale('pt', 'BR')\" not in main_source:\n"
        "    failures.append(\"MaterialApp must expose Brazilian Portuguese\")",
    )

    spanish = ROOT / "tools/validate_spanish_localization.py"
    replace_once(
        spanish,
        "if \"static const supportedLanguageTags = <String>{'tr', 'en', 'es'};\" not in i18n_text:\n    failures.append(\"supported locales must be exactly tr/en/es at the Spanish stage\")",
        "if \"static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR'};\" not in i18n_text:\n"
        "    failures.append(\"supported locales must include tr/en/es/pt-BR\")",
    )
    replace_once(
        spanish,
        "if \"supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')]\" not in main_source:\n    failures.append(\"MaterialApp must expose Turkish, English and Spanish\")",
        "if \"Locale('pt', 'BR')\" not in main_source:\n"
        "    failures.append(\"MaterialApp must expose Brazilian Portuguese\")",
    )
    replace_once(
        spanish,
        """        "lib/l10n/mizan_es.dart",
        "lib/global/global_catalog.dart",
""",
        """        "lib/l10n/mizan_es.dart",
        "lib/l10n/mizan_pt_br.dart",
        "lib/l10n/mizan_pt_br_dynamic.dart",
        "lib/global/global_catalog.dart",
""",
    )


def main() -> None:
    integrate_i18n()
    integrate_main()
    integrate_catalog()
    integrate_formatters()
    update_legacy_validators()
    print("Brazilian Portuguese runtime integration applied deterministically")


if __name__ == "__main__":
    main()
