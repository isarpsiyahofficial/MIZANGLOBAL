# MİZAN Monetization Release Gate

This is the exact-release contract for the monetization branch. The branch must remain unmerged until every applicable automated gate passes on the same source SHA.

## Commercial model

- Lifetime PRO is the one-time, non-consumable Google Play product `premium_lifetime`.
- It is not a subscription and has no recurring renewal.
- User-facing price and currency come from live Google Play product metadata.
- A pending or failed purchase never unlocks permanent PRO.
- Only a valid Google Play ownership record unlocks purchased Permanent PRO.
- Ownership validation stays internal and no purchase-recovery control or promise is shown to the user.
- A previously stored permanent entitlement remains usable offline while valid local ownership state exists.

## Serverless architecture

- The application has no publisher-operated monetization Worker, D1 database, promotion API, entitlement API or billing-verification backend.
- `backend/monetization-worker` and `lib/monetization/monetization_api.dart` must not exist.
- Production builds must not require a monetization API URL, backend billing flag, Play Integrity cloud project value, Worker secret or Wrangler configuration.
- Google Play billing and Google Mobile Ads remain direct platform/provider integrations and are not publisher-operated servers.
- User financial records remain local to the device except when the user explicitly exports or shares a file.

## PRO isolation

- Permanent and temporary PRO suppress all App-served interstitial and rewarded ads immediately.
- PRO permits offline use and real PDF report export.
- The Reports PDF lock disappears as soon as live PRO is active.
- Temporary PRO displays remaining time and expires automatically without modifying financial records.
- When temporary PRO expires, free-mode internet, advertising and PDF restrictions return.

## Free mode and interstitial advertising

- Free use requires real internet reachability.
- Internet reachability is rechecked periodically and on connectivity/lifecycle changes.
- PDF export is rejected at the service boundary for free users; the UI shows a PRO lock and sample preview instead of real export actions.
- The global full-screen advertising cooldown is 120 seconds.
- Time-triggered advertising can become eligible only after the cooldown.
- Behavior-triggered advertising becomes eligible after 3 successfully completed meaningful actions, while still obeying the same 120-second global cooldown.
- Failed/no-inventory loads do not lock the App or count as a shown ad.
- UMP/required consent is resolved before regulated ad requests and privacy options remain accessible when required.

## Rewarded temporary PRO

- Only a free online user can start the rewarded-PRO flow.
- Closing or failing an ad before the provider reward callback does not increment progress.
- Reward progress is 1/3, 2/3, then 3/3.
- The third completed rewarded ad in the applicable reward day grants exactly 24 hours of temporary PRO.
- Reward progress and the temporary entitlement are stored locally.
- Reward inventory is never represented as guaranteed.

## Promotion codes

- The PRO/store surface contains the promotion-code field beside the lifetime purchase flow.
- Embedded fingerprints cover 7-day and 3-day temporary campaigns plus one removable permanent-PRO test campaign.
- Neither raw promotion code is present as an ordinary plaintext code constant in the shipping validator, tests or release documentation.
- The validator normalizes input and compares an HMAC-SHA256 fingerprint against embedded fingerprints.
- Successful redemption state is stored locally on the device and the same code is rejected again while that state exists.
- No promo code, redemption request, device identifier or entitlement state is sent to a publisher-operated promotion server.
- Because redemption memory is local, uninstall/data wipe/factory reset/backup behavior can remove or alter that state. The App must not claim immutable physical-device one-use enforcement without a server.

## Permanent-PRO backup gate

- CSV backup export and import are available only when permanent Google Play PRO ownership is active.
- Temporary PRO from rewarded advertising or promotion codes never unlocks CSV backup export or import.
- A permanent-PRO backup may carry a SHA-256 purchase fingerprint derived from the Google Play purchase proof; it never contains the Google account email or raw purchase token.
- A backup fingerprint never grants PRO by itself. Google Play ownership remains authoritative, preventing a shared or edited backup from becoming a transferable license.
- Existing permanent PRO is never downgraded or replaced by backup contents. Legacy backups without a purchase fingerprint remain data-compatible for a currently verified permanent-PRO user.
- Backup and report surfaces are covered by all-29-language copy and leakage tests.

## Google Play ownership validation

- Purchase ownership synchronization uses Google Play purchase history/ownership APIs directly.
- The App listener is initialized before ownership synchronization.
- A matching valid `premium_lifetime` ownership record sets Permanent PRO.
- If a successful online ownership query contains no matching purchase, stale locally cached permanent PRO can be cleared without deleting user financial records.
- No separate publisher billing server is required.

## Legal and localization

- Privacy Policy, Terms of Use and Purchase Terms accurately describe the serverless architecture.
- English and Turkish full legal masters no longer claim publisher-operated purchase, promotion or entitlement infrastructure.
- All 29 UI languages receive localized document names, guidance and acknowledgement/acceptance controls; the full legal masters remain Turkish and English.
- Purchase Terms describe only the purchased Permanent PRO product and do not expose reward, promotion or purchase-recovery implementation details.
- Mandatory first-run Privacy acknowledgement plus Terms acceptance and the independent Purchase Terms gate remain active.

## Exact-release validation

- `dart format --output=none --set-exit-if-changed lib test` passes.
- `flutter analyze --fatal-warnings` passes.
- The complete Flutter test suite passes.
- Monetization, legal acceptance, PDF access, reward binding, localization, record-currency, CSV and report contracts pass.
- The 29x28 language isolation test and all 29 deep-language surfaces pass.
- Android configuration contains no obsolete Play Integrity/device-identity bridge required by a publisher backend.
- Internal universal, arm64-v8a, armeabi-v7a and x86_64 release APKs build from the exact audited SHA.
- Draft PR remains unmerged until the exact head SHA is green.
