# MİZAN Legal Acceptance Architecture

The legal flow is part of the release contract, not an informational-only screen.

- Initial region, language and default-currency setup is completed first so the consent UI is rendered in the selected interface language.
- Normal application content is blocked until the current general legal bundle is completed.
- The first-run general legal bundle contains Privacy Policy and Terms of Use only. Both documents must be opened and read to the end; Privacy is acknowledged as read/informed while Terms are accepted separately.
- General legal acceptance is versioned independently from Purchase Terms acceptance. A later legal version can require renewed acceptance without deleting financial data.
- Full legal documents are maintained in Turkish and English. The other 27 supported interface languages localize document names, navigation, read/accept guidance, consent state, PRO/store copy, promo copy and errors; they do not introduce separate translated controlling legal texts.
- Turkish and English legal content is intentional and is not treated as cross-language UI leakage. The surrounding application interface must remain in the selected UI language.
- To the extent permitted by applicable law, the English legal text controls; mandatory local consumer rights are not waived by that language clause.
- Permanent PRO checkout is independently gated by the current Purchase Terms version. Purchase Terms are presented and explicitly accepted in the pre-purchase flow, immediately before checkout when the current version has not yet been accepted.
- Reading a Purchase Terms document does not by itself persist purchase acceptance. Checkout can begin only after the current Purchase Terms acceptance is durably recorded; a failed persistence write must not open the purchase gate.
- Likewise, the first-run Privacy acknowledgement + Terms acceptance gate opens only after the current general state is durably recorded; a failed persistence write keeps the gate closed and allows retry.
- Google Play ownership validation remains an internal billing implementation detail and no recovery promise or control is shown to the user.
- The PRO screen contains lifetime PRO purchase, live Play price when available, rewarded temporary PRO, local promotion-code redemption and legal links.
- Promotion validation remains serverless and local using the application's cryptographic validation design; no Worker, D1 or publisher-operated validation server is part of this release.
- Three completed rewarded ads in the applicable reward day grant 24 hours of temporary PRO. Reward progress is stored locally.
- Legacy visual and deep-language regression fixtures may seed current general acceptance only for post-consent surface tests. Production first-run consent and pre-purchase Purchase Terms gates remain covered independently.
- Release CI must keep the 29-language PRO/store/consent interface contract, 29x28 language isolation, deep per-language surface tests, read-before-accept contracts, persistence-failure guards, serverless monetization contract and exact-SHA build gates green before final acceptance.
- The notification subsystem is intentionally absent from this release and must not be reintroduced by legal-flow or regression-fixture code.
