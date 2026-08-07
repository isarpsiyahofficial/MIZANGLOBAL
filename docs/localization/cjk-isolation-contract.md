# Korean / Japanese / Chinese isolation contract

The next three product languages are implemented as separate, complete localization layers in this exact order: Korean (`ko-KR`), Japanese (`ja-JP`), Simplified Chinese (`zh-CN`).

Cross-language contamination is a release blocker:

- Korean visible system copy must be Korean and must not contain Japanese hiragana/katakana or Simplified-Chinese-only system sentences.
- Japanese visible system copy must not contain Hangul and must not reuse Korean or Chinese system labels; normal Japanese kanji are allowed only inside genuine Japanese sentences.
- Simplified Chinese visible system copy must not contain Hangul, hiragana or katakana and must not reuse Korean/Japanese system sentences.
- Reports, charts, PDF, CSV/backup labels, notifications, validation messages, settings and empty/error states are included in the same isolation rule.
- User-authored names, notes, identifiers and multilingual custom messages are preserved exactly and are excluded from system-copy script checks.
- The three languages keep the same 791-key product source set and separate dynamic grammar, locale, number/date/currency and 29/161/154 catalog layers.
- Switching `ko -> ja -> zh -> ko` must never retain visible system copy from the previous locale.
