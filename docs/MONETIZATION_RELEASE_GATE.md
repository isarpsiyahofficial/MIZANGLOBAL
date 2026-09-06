# MİZAN Monetization Release Gate

This document is the current monetization/release contract for the authoritative `main` branch. Historical PR descriptions, old test names or older requirement documents do not override the current source and `docs/CURRENT_RELEASE_OVERRIDES.md`.

## Commercial model

- Lifetime PRO is the one-time, non-consumable Google Play product `premium_lifetime`.
- It is not a subscription and has no recurring renewal.
- User-facing price and currency come from live Google Play product metadata.
- A pending, canceled or failed purchase never unlocks Permanent PRO.
- Purchased Permanent PRO requires trusted Google Play ownership proof.
- Ownership synchronization is silent; there is no user-facing Restore button.
- A Permanent PRO user does not see the lifetime purchase CTA.
- A Temporary PRO user may purchase Permanent PRO before the temporary entitlement expires.

## Serverless architecture

- The application has no publisher-operated monetization Worker, D1 database, promotion API, entitlement API or billing-verification backend.
- Production builds must not require a publisher monetization API URL, Worker secret, Play Integrity cloud-project configuration or Wrangler deployment.
- Google Play Billing and Google Mobile Ads remain direct platform/provider integrations.
- User financial records remain local except when the user explicitly exports or shares a file.

## PRO isolation

- Permanent and Temporary PRO suppress App-served interstitial and rewarded ads.
- Active PRO permits offline use and real PDF report export.
- Temporary PRO displays remaining time and expires without modifying financial records.
- When Temporary PRO expires, free-mode internet, advertising and PDF restrictions return.
- Rewarded and promotion offers are hidden/blocked while any PRO entitlement is active, preventing entitlement stacking.

## Free mode and interstitial advertising

- Free use requires real internet reachability.
- Reachability is rechecked periodically and on connectivity/lifecycle changes.
- PDF export is rejected at the service boundary for free users; the UI exposes the PRO/sample-preview path instead of real export.
- The global full-screen advertising cooldown is **60 seconds**.
- Time-triggered advertising can become eligible only after that cooldown.
- Behavior-triggered advertising requires **3 successfully completed meaningful actions** and still obeys the same 60-second global cooldown.
- Failed/no-inventory loads do not lock the App or count as a shown ad.
- UMP/required consent is resolved before regulated ad requests; privacy options remain available where required.

## Rewarded Temporary PRO

- Only a free online user can start the rewarded-PRO flow.
- Closing/failing an ad before the provider reward callback does not increment progress.
- Reward progress is 1/3, 2/3, then 3/3.
- The third successful provider reward grants **24 hours** of Temporary PRO.
- Reward progress and temporary entitlement are stored locally.
- Reward inventory is never represented as guaranteed.

## Promotion codes

- Promo verification is fully local and uses normalized HMAC-SHA256 fingerprints; raw promo strings are not stored as ordinary shipping constants.
- The current shipping fingerprint table contains **four Temporary PRO campaigns** with durations **7 days, 3 days, 7 days and 30 days**.
- There is **no Permanent PRO shipping promo campaign**.
- Historical ESMANUR and IBRAHIM Permanent-PRO test behavior is not part of the current release.
- Successful redemption state is local and the same fingerprint is rejected again while that local state exists.
- No promo code, redemption request, device identifier or entitlement state is sent to a publisher-operated promo server.
- Local-only redemption cannot honestly claim immutable physical-device one-use enforcement after uninstall/data wipe/factory reset; the App does not make that claim.

## Permanent-PRO CSV backup gate

- CSV backup export/import is available only to Permanent PRO.
- Temporary PRO from rewarded advertising or promotion codes does not unlock CSV backup.
- Backup proof uses a SHA-256 purchase fingerprint, never the Google-account email or raw purchase token.
- A backup fingerprint never grants PRO by itself; Google Play ownership remains authoritative for purchased Permanent PRO.
- Android automatic cloud backup/device transfer is disabled so App financial records and entitlement state are not silently moved outside the controlled CSV mechanism.

## Google Play ownership validation

- Purchase synchronization uses Google Play ownership APIs directly.
- The purchase listener is initialized before ownership synchronization.
- A matching trusted `premium_lifetime` ownership record grants Permanent PRO.
- A successful online ownership query with no matching trusted purchase may clear stale purchased Permanent PRO without deleting financial records.
- A valid local-promotion Permanent PRO source is not currently shipped because the active promo table contains no permanent campaign.

## Legal and localization

- Privacy Policy, Terms of Use and Purchase Terms describe the serverless/local-data architecture.
- Full legal masters are Turkish and English only.
- All 29 UI languages receive localized document names, guidance and acknowledgement/acceptance controls; no independent legal summaries are generated for the other 27 languages.
- Purchase Terms are separately read/accepted before Google Play purchase starts.
- The intentional user-responsibility warning that MİZAN can make mistakes remains visible on the relevant form/PDF surface.

## Android / production fail-closed rules

- Package ID is `com.lefferionprime.mizanglobal`.
- Production release must contain real AdMob App, Interstitial and Rewarded IDs; Google sample IDs are rejected.
- Production release must use release signing credentials; missing signing is rejected.
- Production integrity gate verifies targetSdk 36, package identity, final logo hash and modern APK signature.
- Flutter production workflow is pinned to the current known-safe 3.44.6 toolchain rather than blindly upgrading a working release.
- The production workflow includes a Billing Library horizon gate that refuses publication after the supported Billing 8 extension window if the billing plugin has not been upgraded.

## Pre-publication validation policy

- Heavy Flutter test/analyze runs, emulator/runtime validation, APK/AAB builds and ad tests are **not run automatically before publication** under the current user instruction.
- Source-only structural validators, localization leak audits and hygiene/security inspections may be used without building or testing the App.
- All heavy GitHub workflows are manual-only via `workflow_dispatch`; no push/PR trigger may silently run them.
- When the user explicitly starts final publication/testing, the exact `main` SHA should be validated and the production workflow should be run with real account secrets.

## External publication inputs

The repository can be source-complete while publication still requires account-side values/actions: real AdMob IDs and UMP/privacy setup, `app-ads.txt`, release signing secrets, Google Play `premium_lifetime` product configuration, store listing/Data Safety/ads declarations, and a versionCode not already used in Play Console.
