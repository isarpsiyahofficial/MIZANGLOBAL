# MİZAN Legal Acceptance Architecture

The legal flow is part of the release contract, not an informational-only screen.

- Initial region/language/currency setup is completed first so consent UI is rendered in the selected language.
- Normal application content is blocked until the current legal bundle is accepted.
- Privacy Policy, Terms of Use and Purchase Terms must each be opened and read to the end before the global acceptance control becomes available.
- Acceptance is versioned using the controlling legal effective date. A later legal version can require renewed acceptance without deleting financial data.
- Every legal document screen contains a native-language explanatory summary for the selected one of 29 UI languages, followed by the full Turkish reference text and full English controlling text.
- Turkish and English full legal texts are intentional bilingual legal content and are not treated as UI-language leakage. Navigation, instructions, consent state, headings, PRO/store copy, promo copy and errors must remain native to the selected UI language.
- To the extent permitted by applicable law, the English legal text controls; mandatory local consumer rights are not waived by that language clause.
- Permanent PRO checkout is independently gated by current Purchase Terms acceptance. If the current version is not accepted, checkout cannot start until Purchase Terms have been read to the end.
- Acceptance of the same current Purchase Terms during the mandatory first-run bundle satisfies the purchase gate; the user is not asked to accept an identical version twice.
- Existing Google Play ownership is synchronized silently through Google Play purchase ownership/history. There is no user-facing Restore Purchases button and no publisher-operated billing server.
- The PRO screen contains lifetime PRO purchase, live Play price when available, rewarded temporary PRO, local promotion-code redemption and legal links.
- Promotion validation is embedded locally using cryptographic fingerprints. The two embedded campaigns grant 7 days and 3 days respectively; neither raw code is stored as ordinary plaintext in the shipping validator, tests or release documentation.
- Five completed rewarded ads in the applicable reward day grant 24 hours of temporary PRO. Reward progress is stored locally.
- Legacy visual and deep-language regression fixtures seed acceptance of the current legal version only for post-consent surface tests. The production first-run gate remains covered independently.
- Release CI keeps the 29-language PRO/store/consent key contract, full 29x28 isolation matrix, deep per-language surface tests, read-before-accept contract, serverless monetization contract and exact-SHA build gate green before merge.
