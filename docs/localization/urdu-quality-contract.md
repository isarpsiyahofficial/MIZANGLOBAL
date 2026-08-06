# Urdu Localization Quality Contract

Urdu (`ur`, `ur-PK`, `ur-IN`) is the next catalog language after Bengali.

This localization is not considered complete until all of the following pass on one exact candidate head, and then pass again independently:

- 791/791 static system strings translated into natural, neutral, native-level Urdu
- No Turkish, English, Bengali, Hindi, Arabic or Persian UI leakage except protected product names, ISO codes and user-authored content
- Dedicated Urdu dynamic grammar and interpolation rules; no reuse of another language as a fallback
- Full right-to-left layout, mixed-script isolation, punctuation, numerals and bidirectional safety
- `ur`, `ur-PK` and `ur-IN` runtime normalization
- PKR, INR and record-level currencies without conversion or merging
- Pakistan and India country, institution, category and currency catalog search coverage
- Reports, charts, calculations, totals, grouping, CSV, backup, PDF, notification and reminder output in the selected language
- All existing 19 languages remain byte- and behavior-compatible
- Responsive and visual baseline checks
- Every Flutter test file run in isolation
- Universal, ARM64, ARMv7 and x86_64 release APKs with byte counts and SHA-256 hashes
- Clean source tree after tests and builds

No partial result, fallback copy, duplicated formatter block, generated placeholder, untranslated label, or unreviewed machine output may be marked final.
