# MİZAN Monetization Release Gate

This document is a hard release contract for the monetization branch. A green Flutter build alone is not sufficient. The draft PR must stay unmerged until every required item below is verified against the exact release commit.

## 1. Commercial contract

- [ ] Google Play contains a one-time/non-consumable product with the exact ID `premium_lifetime`.
- [ ] The product is not configured as a subscription and has no recurring renewal.
- [ ] The intended base commercial price is approximately USD 5, while the user-facing checkout price/currency is always the live value supplied by Google Play.
- [ ] A real license-test purchase succeeds from the Play-distributed test build.
- [ ] A pending purchase never unlocks Premium.
- [ ] A completed verified purchase unlocks permanent Premium.
- [ ] The purchase is acknowledged within the Google Play-required window through the verified flow.
- [ ] A refunded/revoked purchase is removed after reliable online ownership synchronization without deleting the user’s financial records.

## 2. Silent restore contract

- [ ] There is no visible Restore Purchases button in the Premium UI.
- [ ] The purchase listener is initialized before ownership synchronization.
- [ ] Existing ownership is synchronized automatically at first online startup and when the app resumes online.
- [ ] Reinstall on the same valid purchasing Google account restores `premium_lifetime` automatically once Google Play can be reached.
- [ ] A compatible replacement device using the same valid purchasing Google account restores ownership automatically once online.
- [ ] A previously verified Premium entitlement opens offline without waiting for network, AdMob or Google Play.
- [ ] A fresh reinstall cannot restore ownership while fully offline because the local entitlement cache no longer exists; the first restore requires Google Play connectivity. The product copy and support text must not promise the impossible offline-reinstall case.

## 3. Premium isolation contract

For permanent and temporary Premium:

- [ ] No interstitial ad can be loaded or shown after Premium becomes active.
- [ ] Any already-loaded interstitial is disposed when Premium becomes active.
- [ ] No rewarded-Premium control is visible while Premium is active.
- [ ] Any already-loaded rewarded ad is disposed when Premium becomes active.
- [ ] Offline startup and continued offline use are allowed.
- [ ] PDF generation succeeds through the Premium-gated service.
- [ ] The PDF lock disappears from the Reports UI as soon as live Premium entitlement becomes active, and the real PDF save/share actions become available.
- [ ] Temporary Premium shows remaining time and expires automatically.
- [ ] When temporary Premium expires, free-mode internet, ad and PDF restrictions return without modifying financial records.

## 4. Free-mode contract

- [ ] A free user can use the app only while real internet reachability is available.
- [ ] Internet reachability is rechecked at least every 10 seconds and on connectivity/lifecycle changes.
- [ ] Launching online and then disabling internet blocks the free app after detection instead of leaving it usable indefinitely without ads.
- [ ] The offline block screen is localized separately in all 29 supported languages.
- [ ] PDF generation is rejected at the PDF service boundary, not merely hidden in the UI.
- [ ] The Reports UI shows a clear PRO lock instead of real PDF save/share actions for a free user.
- [ ] The free PDF preview uses only sample data, is visibly identified as a sample, and never exposes or exports the user’s own records.
- [ ] Free financial data is never deleted merely because connectivity disappears.

## 5. Full-screen advertising contract

- [ ] Development and CI builds use only Google sample/test AdMob IDs.
- [ ] The 120-second time gate counts foreground-active app time rather than time spent in the background.
- [ ] A time-based interstitial becomes eligible only after 120 seconds of active free use and is displayed only at a natural top-level transition.
- [ ] Behavior count is based on successfully persisted financial/app-state mutations, not repeated taps or tab spam.
- [ ] Three completed durable mutations constitute the behavior threshold.
- [ ] Behavior-triggered opportunities obey the same global 120-second full-screen cooldown, so time and behavior paths cannot stack two ads.
- [ ] No interstitial appears while a text field/form is being edited, during startup before content, immediately on app exit, or over another full-screen ad.
- [ ] Failed/no-inventory ad loads do not lock the app or count as a shown ad.
- [ ] UMP/required consent is resolved before regulated ad requests, and privacy options remain accessible when required.

## 6. Rewarded Premium contract

- [ ] Only a free online user can start a rewarded-Premium ad.
- [ ] Closing/failing an ad before the provider reward callback does not increment progress.
- [ ] First successful reward = 1/3.
- [ ] Second successful reward = 2/3.
- [ ] Third successful reward = 3/3 and grants exactly 24 hours of temporary Premium.
- [ ] Premium becomes ad-free immediately after the third verified reward.
- [ ] Reward progress uses the trusted local anti-clock-rollback logic and resets for the next reward day as defined by the app.
- [ ] Reward inventory is never represented as guaranteed.

## 7. Promotion contract

Server source of truth:

- [ ] `ESMANUR` grants exactly 7 days of temporary Premium.
- [ ] `LEFFERION` grants exactly 3 days of temporary Premium.
- [ ] Each code can be accepted at most once for the same eligible device pseudonym.
- [ ] Uninstall/reinstall does not erase the server redemption record.
- [ ] Promotion expiry is calculated by server UTC time, not the handset clock.
- [ ] Production redemption requires Play Integrity and a request hash bound to the device pseudonym and code.
- [ ] Raw Android IDs and raw redeemed promotion codes are not stored in D1.
- [ ] Duplicate, malformed, replayed, unrecognized-app and integrity-failed requests are rejected fail-closed.
- [ ] Factory reset/signing-key/OS identity-boundary cases are documented accurately; the app does not falsely claim a permanent immutable physical-device identifier.

## 8. Backend production gate

- [ ] Cloudflare D1 database `mizan-monetization` exists.
- [ ] `REPLACE_WITH_D1_DATABASE_ID` is replaced with the real D1 database ID in every production binding.
- [ ] `schema.sql` is applied to the exact production database.
- [ ] `PROMO_PEPPER` is configured as a high-entropy Worker secret and is not committed.
- [ ] `GOOGLE_SERVICE_ACCOUNT_EMAIL` is configured as a Worker secret.
- [ ] `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY` is configured as a Worker secret and is not committed.
- [ ] The service account has only the Play permissions required for product purchase verification/acknowledgement.
- [ ] The production Worker passes strict TypeScript and `wrangler deploy --dry-run`.
- [ ] The production Worker health endpoint and both POST endpoints are integration-tested after deployment.
- [ ] `MIZAN_MONETIZATION_API` points to the production Worker origin in the release build.
- [ ] `MIZAN_REQUIRE_BILLING_BACKEND=true` in the release build.
- [ ] Google Play real-time developer notifications / voided-purchase monitoring is configured or explicitly completed before final public release so refund/revocation handling does not rely only on a later client foreground sync.

## 9. Play Integrity gate

- [ ] Play Console app is linked to the intended Google Cloud project.
- [ ] The numeric Cloud project number is configured as `MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER` in the production build.
- [ ] Production Worker has `REQUIRE_PLAY_INTEGRITY=true`.
- [ ] A Play-recognized, correctly signed test build produces a valid standard integrity response.
- [ ] Wrong package, wrong request hash, stale token, tampered/unrecognized app and insufficient device-integrity cases are rejected.

## 10. AdMob production gate

- [ ] Test/sample IDs remain in development/CI only.
- [ ] A real AdMob app exists for the production package.
- [ ] Real production interstitial and rewarded unit IDs are configured only when ready for release.
- [ ] The production manifest uses the real AdMob app ID.
- [ ] The production build cannot accidentally ship with Google sample/test IDs.
- [ ] AdMob privacy/consent configuration matches the countries where the app is distributed.

## 11. Android release identity gate

- [ ] Release builds no longer use the debug signing configuration.
- [ ] Play App Signing/release key configuration is stable and documented.
- [ ] Package name remains `com.lefferionprime.mizanglobal`.
- [ ] Promotion device-identity behavior is retested with the final signing identity because Android’s app-scoped identifier behavior is signing-sensitive.

## 12. Legal and privacy gate

- [ ] English controlling Privacy Policy has been manually reviewed against the final code/data flows.
- [ ] English controlling Terms of Use has been manually reviewed against the final features and limitations.
- [ ] English controlling Purchase Terms has been manually reviewed against the final Google Play product and refund/restore behavior.
- [ ] All 29 locales show a native-language explanation plus the English controlling text; no locale silently falls back to English for the localized explanation.
- [ ] Privacy wording covers local financial records, CSV/PDF exports, free-mode reachability, advertising/consent, purchase-token verification, promotion-device pseudonym, Play Integrity, processors, retention, security and user rights.
- [ ] Purchase wording covers one-time/non-subscription status, live Google Play price, silent restore, same-account ownership, offline cache limits, refund/revocation, 3 rewarded ads -> 24 hours, ESMANUR 7 days and LEFFERION 3 days.
- [ ] Correct publisher/legal entity name, country/address where legally required, and support/privacy contact are inserted. Placeholder reliance on “the Google Play listing” is not considered final legal identity.
- [ ] A qualified legal review is completed for the intended countries before public release; code review is not treated as jurisdiction-specific legal advice.

## 13. 29-language purity gate

For each of the 29 supported language tags:

- [ ] Premium screen labels are native/localized.
- [ ] Offline gate is native/localized.
- [ ] Rewarded progress and promo messages are native/localized.
- [ ] PDF lock, preview explanation and preview-only sample labels are native/localized.
- [ ] Privacy explanation is native/localized.
- [ ] Terms explanation is native/localized.
- [ ] Purchase explanation is native/localized.
- [ ] No Turkish source strings leak into non-Turkish monetization screens.
- [ ] No English fallback leaks into localized explanations unless the selected UI language is English.
- [ ] RTL locales preserve readable layout and do not break codes/product IDs.

## 14. Exact-release test gate

- [ ] `flutter analyze` passes with zero errors.
- [ ] Entire Flutter test suite passes.
- [ ] Monetization contract tests pass.
- [ ] Free-PDF lock + sample preview + active-PRO unlock/save/share widget tests pass.
- [ ] 29-language monetization/localization tests pass.
- [ ] Worker TypeScript + Wrangler dry-run passes.
- [ ] Android debug APK with test ads builds in CI.
- [ ] Production-signed internal-test AAB/APK builds with production flags.
- [ ] Real-device matrix covers free online, free network loss, permanent Premium online/offline, temporary Premium online/offline, reward completion, reward failure, promotion first/duplicate/reinstall, purchase new/restore/refund and PDF free/Premium.
- [ ] Draft PR remains unmerged until the exact commit that will be merged has passed all applicable gates.