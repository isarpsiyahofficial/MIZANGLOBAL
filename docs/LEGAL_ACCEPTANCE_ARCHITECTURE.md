# MİZAN Legal Acceptance Architecture

The legal flow is part of the release contract, not an informational-only screen.

- Initial region, language and default-currency setup is completed first so the consent UI is rendered in the selected interface language.
- Normal application content is blocked until the current general legal bundle is completed.
- The first-run general legal bundle contains Privacy Policy and Terms of Use only. Both documents must be opened and read to the end; Privacy is acknowledged as read/informed while Terms are accepted separately.
- General legal acceptance is versioned independently from Purchase Terms acceptance. A later legal version can require renewed acceptance without deleting financial data.
- Full legal documents are maintained in Turkish and English. The other 27 supported interface languages localize document names, navigation, read/accept guidance, consent state, PRO/store copy, promo copy and errors; they do not introduce separate translated controlling legal texts.
- Turkish and English legal content is intentional and is not treated as cross-language UI leakage. The surrounding application interface must remain in the selected UI language.
- To the extent permitted by applicable law, the English legal text is the interpretation reference; mandatory local consumer rights are not waived by that language clause.
- Permanent PRO checkout is independently gated by the current Purchase Terms version. Purchase Terms are presented and explicitly accepted in the pre-purchase flow before Google Play checkout.
- Reading a Purchase Terms document does not by itself persist purchase acceptance. Checkout can begin only after the current Purchase Terms acceptance is durably recorded; a failed persistence write must not open the purchase gate.
- Likewise, the first-run Privacy acknowledgement + Terms acceptance gate opens only after the current general state is durably recorded; a failed persistence write keeps the gate closed and allows retry.
- Google Play ownership validation remains an internal billing implementation detail and no recovery promise or visible Restore control is shown to the user.
- The PRO screen contains the one-time lifetime PRO purchase path, live Play price when available, rewarded Temporary PRO, local promotion-code redemption and legal links. Permanent PRO hides the lifetime purchase CTA; Temporary PRO may still purchase lifetime PRO. Reward/promo offers do not stack while PRO is active.
- Promotion validation remains serverless and local using the application's HMAC fingerprint design; no Worker, D1 or publisher-operated validation server is part of this release.
- Three successful rewarded-provider callbacks grant 24 hours of Temporary PRO. Reward progress is stored locally.
- The intentional MİZAN error/user-verification warning is part of the product responsibility wording and must remain on the relevant form/PDF surface.
- Legacy visual/deep-language fixtures may seed current general acceptance only for post-consent surface checks. Production first-run consent and pre-purchase Purchase Terms gates remain independent.
- Before publication, source-only legal/localization/hygiene checks may run without Flutter build/test. Heavy Flutter tests, emulator checks and APK/AAB builds remain manual and are run only when the user explicitly starts the publication/testing phase.
- The notification subsystem is intentionally absent from this release and must not be reintroduced by legal-flow, documentation or regression-fixture code.
