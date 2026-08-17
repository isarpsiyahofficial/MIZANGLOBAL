# MİZAN Legal Acceptance Architecture

The legal flow is part of the release contract, not an informational-only screen.

- Initial region/language/currency setup is completed first so consent UI is rendered in the selected language.
- Normal application content is then blocked until the current legal bundle is accepted.
- Privacy Policy, Terms of Use and Purchase Terms must each be opened and read to the end before the global acceptance control becomes available.
- Acceptance is versioned using the controlling legal effective date. A later legal version can therefore require renewed acceptance without deleting financial data.
- Every legal document screen contains a native-language explanatory summary for the selected one of 29 UI languages, followed by the full Turkish reference text and full English controlling text.
- Turkish and English full legal texts are intentional bilingual legal content and are not treated as UI-language leakage. Navigation, instructions, consent state, headings describing those legal masters, Premium/store copy, promo copy and errors must still remain native to the selected UI language.
- To the extent permitted by applicable law, the English legal text controls; mandatory local consumer rights are not waived by that language clause.
- Permanent Premium checkout is independently gated by the current Purchase Terms acceptance. If the current version is not accepted, checkout cannot start until Purchase Terms have been read to the end.
- Acceptance of the same current Purchase Terms during the mandatory first-run bundle satisfies the purchase gate; the user is not asked to accept an identical version twice.
- Existing Google Play ownership is synchronized silently. There is no user-facing Restore Purchases button.
- The Premium screen is the store surface: it contains lifetime Premium purchase, live Play price when available, rewarded temporary Premium, promotion-code redemption and legal links.
- Server promotion contract remains ESMANUR = 7 days and LEFFERION = 3 days, subject to server-side device/integrity protections.
- Legacy visual and deep-language regression fixtures explicitly seed acceptance of the current legal version before testing post-consent application surfaces. This test setup never bypasses or weakens the production first-run gate; the mandatory consent flow is covered separately by its own contract tests.
- Release CI must keep the 29-language Premium/store/consent key contract, full 29x28 isolation matrix, deep per-language surface tests and the read-before-accept/purchase-gate source contract green on the exact release SHA.
