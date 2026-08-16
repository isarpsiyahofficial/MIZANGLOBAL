# MİZAN Monetization Worker

This Worker is the server-side authority for promotion redemption and Google Play lifetime-Premium verification. The mobile app must not ship in production with local-only promotion or purchase verification.

## Production prerequisites

1. Create a Cloudflare D1 database named `mizan-monetization` and replace every `REPLACE_WITH_D1_DATABASE_ID` value in `wrangler.jsonc` with the real database ID.
2. Apply `schema.sql` to the remote D1 database.
3. Configure Worker secrets; never commit their values:
   - `PROMO_PEPPER`: at least 32 random bytes represented as a secret string.
   - `GOOGLE_SERVICE_ACCOUNT_EMAIL`: Google service-account email authorized for the app’s Google Play Developer API access.
   - `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY`: PKCS#8 private key for that service account.
4. Link the Android app to the Google Cloud project used by Play Integrity and configure the same numeric Cloud project number in the Android build as `MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER`.
5. Confirm the Google service account has only the permissions required to verify and acknowledge the app’s one-time products. Do not reuse an unrelated broad-privilege account.
6. Deploy the production Worker only after `npm run check` succeeds.
7. Build the production Android app with:
   - `MIZAN_MONETIZATION_API` set to the production Worker origin.
   - `MIZAN_REQUIRE_BILLING_BACKEND=true`.
   - the real Play Integrity Cloud project number.
   - production AdMob IDs and test-ads mode disabled.
8. Google Play must contain the one-time/non-consumable product ID `premium_lifetime`. Its checkout price is controlled by Google Play; the app displays `ProductDetails.price` and does not hard-code USD 5.

## Promotion contract

The server is the source of truth:

- `ESMANUR` grants seven days of temporary Premium.
- `LEFFERION` grants three days of temporary Premium.
- Each code is accepted at most once for a given eligible device pseudonym.
- Redemption time and expiry come from the server clock, not the handset clock.
- Production redemption requires a Play Integrity token bound to a SHA-256 request hash derived from the device pseudonym and promotion code.
- Raw Android IDs and raw promotion codes are not stored in D1; keyed cryptographic representations are stored instead.

A factory reset, a signing-key change, or other platform-level identity reset can produce a new Android app-scoped identifier. The system must not claim that ordinary Android APIs can identify the same physical device forever across every such reset.

## Purchase contract

`/v1/billing/google/verify` accepts a Google Play purchase token only for the expected package and `premium_lifetime` product. The Worker verifies current purchase state with Google Play, acknowledges a valid pending purchase when needed, and stores minimized hashes for entitlement/refund/support auditing.

The Android client also queries current owned purchases whenever the app resumes online. A successful online ownership query that no longer contains the lifetime product can revoke a stale cached permanent entitlement. Offline startup does not revoke a previously verified entitlement solely because Google Play cannot be reached.

## Local validation

```bash
npm install
npm run check
```

`npm run check` runs strict TypeScript checking and a Wrangler production bundle dry run. It does not prove that D1, Google Play credentials, Play Integrity configuration, or production secrets are live; those require real deployment/integration tests before release.
