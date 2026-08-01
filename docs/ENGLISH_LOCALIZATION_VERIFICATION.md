# MİZAN GLOBAL English localization verification

This candidate intentionally enables only Turkish (`tr`) and English (`en`).

The English candidate may be integrated into `agent/mizanglobal-globalization` only after all of the following pass on the materialized source tree:

- centralized fixed-copy coverage validation,
- Flutter static analysis with fatal warnings,
- English UI, settings, validation, reports, PDF, notifications and backup tests,
- preservation of user-authored names, titles and notes,
- Turkish regression tests,
- deterministic visual regression tests,
- universal release APK build,
- ABI-split release APK builds,
- independent APK byte-size and SHA-256 verification.

Unsupported languages must not be selectable and must not silently expose partially translated UI.
