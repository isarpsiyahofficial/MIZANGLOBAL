import { Buffer } from "node:buffer";
import { verify as verifySignature } from "node:crypto";

interface SecretEnv {
  PROMO_PEPPER: string;
  GOOGLE_SERVICE_ACCOUNT_EMAIL: string;
  GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY: string;
}

type RuntimeEnv = Env & SecretEnv;
type JsonObject = Record<string, unknown>;

type GoogleTokenCache = {
  token: string;
  expiresAtMs: number;
  scope: string;
};

type RewardStateRow = {
  reward_date_utc: string;
  rewarded_views: number;
  premium_until_utc: string | null;
};

type RewardSessionRow = {
  session_id: string;
  device_key: string;
  created_at_utc: string;
  expires_at_utc: string;
  rewarded_at_utc: string | null;
  transaction_id: string | null;
};

type VerifierKey = {
  keyId: number;
  pem: string;
  base64: string;
};

type VerifierKeyResponse = {
  keys?: VerifierKey[];
};

let googleTokenCache: GoogleTokenCache | null = null;

const PROMOS: Record<string, number> = {
  ESMANUR: 7,
  LEFFERION: 3,
};

const encoder = new TextEncoder();
const ADMOB_VERIFIER_KEYS_URL =
  "https://www.gstatic.com/admob/reward/verifier-keys.json";
const REWARD_SESSION_TTL_MS = 30 * 60 * 1000;
const REWARD_PREMIUM_MS = 24 * 60 * 60 * 1000;
const REWARD_VIEWS_REQUIRED = 3;

function json(body: JsonObject, status = 200): Response {
  return Response.json(body, {
    status,
    headers: {
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    },
  });
}

async function readJson(request: Request): Promise<JsonObject | null> {
  if (!request.headers.get("content-type")?.toLowerCase().includes("application/json")) {
    return null;
  }
  try {
    const value = await request.json();
    return value && typeof value === "object" && !Array.isArray(value)
      ? (value as JsonObject)
      : null;
  } catch {
    return null;
  }
}

function base64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function base64UrlJson(value: JsonObject): string {
  return base64Url(encoder.encode(JSON.stringify(value)));
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", encoder.encode(value));
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, "0")).join("");
}

async function hmacHex(secret: string, value: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(value));
  return Array.from(new Uint8Array(signature), (b) => b.toString(16).padStart(2, "0")).join("");
}

function pemToPkcs8(pem: string): ArrayBuffer {
  const normalized = pem.replace(/\\n/g, "\n");
  const body = normalized
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");
  const binary = atob(body);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

async function googleAccessToken(env: RuntimeEnv, scope: string): Promise<string> {
  const now = Date.now();
  if (
    googleTokenCache &&
    googleTokenCache.scope === scope &&
    googleTokenCache.expiresAtMs - 60_000 > now
  ) {
    return googleTokenCache.token;
  }

  if (!env.GOOGLE_SERVICE_ACCOUNT_EMAIL || !env.GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY) {
    throw new Error("google_service_account_not_configured");
  }

  const issuedAt = Math.floor(now / 1000);
  const header = base64UrlJson({ alg: "RS256", typ: "JWT" });
  const claims = base64UrlJson({
    iss: env.GOOGLE_SERVICE_ACCOUNT_EMAIL,
    scope,
    aud: "https://oauth2.googleapis.com/token",
    iat: issuedAt,
    exp: issuedAt + 3600,
  });
  const signingInput = `${header}.${claims}`;
  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToPkcs8(env.GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    encoder.encode(signingInput),
  );
  const assertion = `${signingInput}.${base64Url(new Uint8Array(signature))}`;
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth-bearer",
      assertion,
    }),
  });
  if (!response.ok) throw new Error(`google_oauth_${response.status}`);
  const payload = (await response.json()) as {
    access_token?: string;
    expires_in?: number;
  };
  if (!payload.access_token) throw new Error("google_oauth_missing_token");
  googleTokenCache = {
    token: payload.access_token,
    scope,
    expiresAtMs: now + (payload.expires_in ?? 3600) * 1000,
  };
  return payload.access_token;
}

async function expectedIntegrityRequestHash(
  purpose: string,
  deviceHash: string,
  nonce: string,
): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    encoder.encode(`${purpose}|${deviceHash}|${nonce}`),
  );
  return base64Url(new Uint8Array(digest));
}

async function verifyPlayIntegrity(
  env: RuntimeEnv,
  integrityToken: string,
  expectedRequestHash: string,
): Promise<boolean> {
  if (!integrityToken) return false;
  const accessToken = await googleAccessToken(
    env,
    "https://www.googleapis.com/auth/playintegrity",
  );
  const endpoint =
    `https://playintegrity.googleapis.com/v1/${encodeURIComponent(env.EXPECTED_PACKAGE_NAME)}` +
    ":decodeIntegrityToken";
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ integrity_token: integrityToken }),
  });
  if (!response.ok) return false;
  const decoded = (await response.json()) as {
    tokenPayloadExternal?: {
      requestDetails?: {
        requestPackageName?: string;
        requestHash?: string;
        timestampMillis?: string;
      };
      appIntegrity?: {
        appRecognitionVerdict?: string;
        packageName?: string;
      };
      deviceIntegrity?: {
        deviceRecognitionVerdict?: string[];
      };
    };
  };
  const payload = decoded.tokenPayloadExternal;
  const requestDetails = payload?.requestDetails;
  const timestamp = Number(requestDetails?.timestampMillis ?? 0);
  const ageMs = Math.abs(Date.now() - timestamp);
  const deviceVerdicts = payload?.deviceIntegrity?.deviceRecognitionVerdict ?? [];
  return Boolean(
    payload &&
      requestDetails?.requestPackageName === env.EXPECTED_PACKAGE_NAME &&
      requestDetails.requestHash === expectedRequestHash &&
      ageMs <= 120_000 &&
      payload.appIntegrity?.appRecognitionVerdict === "PLAY_RECOGNIZED" &&
      payload.appIntegrity?.packageName === env.EXPECTED_PACKAGE_NAME &&
      deviceVerdicts.includes("MEETS_DEVICE_INTEGRITY"),
  );
}

async function validateDeviceRequest(
  body: JsonObject,
  env: RuntimeEnv,
  purpose: string,
): Promise<{ deviceHash: string } | Response> {
  const deviceHash = String(body.deviceHash ?? "").trim().toLowerCase();
  const packageName = String(body.packageName ?? "").trim();
  const platform = String(body.platform ?? "").trim().toLowerCase();
  const nonce = String(body.nonce ?? "").trim();
  const integrityToken = String(body.integrityToken ?? "").trim();

  if (
    !/^[a-f0-9]{64}$/.test(deviceHash) ||
    packageName !== env.EXPECTED_PACKAGE_NAME ||
    platform !== "android" ||
    nonce.length < 16 ||
    nonce.length > 128
  ) {
    return json({ accepted: false, messageCode: "invalid_request" }, 400);
  }

  if (env.REQUIRE_PLAY_INTEGRITY.toLowerCase() === "true") {
    try {
      const expectedHash = await expectedIntegrityRequestHash(purpose, deviceHash, nonce);
      if (!(await verifyPlayIntegrity(env, integrityToken, expectedHash))) {
        return json({ accepted: false, messageCode: "integrity_failed" }, 403);
      }
    } catch {
      return json({ accepted: false, messageCode: "integrity_unavailable" }, 503);
    }
  }
  return { deviceHash };
}

function utcDay(now: Date): string {
  return now.toISOString().slice(0, 10);
}

async function deviceKey(env: RuntimeEnv, deviceHash: string): Promise<string> {
  if (!env.PROMO_PEPPER || env.PROMO_PEPPER.length < 32) {
    throw new Error("server_not_configured");
  }
  return hmacHex(env.PROMO_PEPPER, `device|${deviceHash}`);
}

async function rewardState(
  env: RuntimeEnv,
  key: string,
  now: Date,
): Promise<{ rewardedViewsToday: number; rewardPremiumUntilUtc: string | null }> {
  const row = await env.DB.prepare(
    `SELECT reward_date_utc, rewarded_views, premium_until_utc
       FROM rewarded_daily_state
      WHERE device_key = ?1
      LIMIT 1`,
  )
    .bind(key)
    .first<RewardStateRow>();
  const count = row?.reward_date_utc === utcDay(now)
    ? Math.max(0, Math.min(REWARD_VIEWS_REQUIRED, Number(row.rewarded_views) || 0))
    : 0;
  const until = row?.premium_until_utc ?? null;
  const activeUntil = until && Date.parse(until) > now.getTime() ? until : null;
  return { rewardedViewsToday: count, rewardPremiumUntilUtc: activeUntil };
}

async function temporaryPremiumUntil(
  env: RuntimeEnv,
  key: string,
  now: Date,
): Promise<string | null> {
  const promo = await env.DB.prepare(
    `SELECT MAX(premium_until_utc) AS premium_until_utc
       FROM promo_redemptions
      WHERE device_key = ?1 AND premium_until_utc > ?2`,
  )
    .bind(key, now.toISOString())
    .first<{ premium_until_utc: string | null }>();
  const reward = await rewardState(env, key, now);
  const candidates = [promo?.premium_until_utc ?? null, reward.rewardPremiumUntilUtc]
    .filter((value): value is string => Boolean(value))
    .sort();
  return candidates.length === 0 ? null : candidates[candidates.length - 1] ?? null;
}

async function redeemPromo(request: Request, env: RuntimeEnv): Promise<Response> {
  const body = await readJson(request);
  if (!body) return json({ accepted: false, messageCode: "invalid_request" }, 400);

  const code = String(body.code ?? "").trim().toUpperCase();
  const days = PROMOS[code];
  if (!days) return json({ accepted: false, messageCode: "invalid_code" });

  const validation = await validateDeviceRequest(body, env, "mizan-promo-v1");
  if (validation instanceof Response) return validation;

  let key: string;
  try {
    key = await deviceKey(env, validation.deviceHash);
  } catch {
    return json({ accepted: false, messageCode: "server_not_configured" }, 503);
  }
  const codeKey = await hmacHex(env.PROMO_PEPPER, `code|${code}`);
  const redemptionKey = await hmacHex(
    env.PROMO_PEPPER,
    `redeem|${validation.deviceHash}|${code}`,
  );
  const now = new Date();
  const premiumUntil = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

  const result = await env.DB.prepare(
    `INSERT OR IGNORE INTO promo_redemptions
      (redemption_key, device_key, code_key, redeemed_at_utc, premium_until_utc, app_package, platform)
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`,
  )
    .bind(
      redemptionKey,
      key,
      codeKey,
      now.toISOString(),
      premiumUntil.toISOString(),
      env.EXPECTED_PACKAGE_NAME,
      "android",
    )
    .run();

  if ((result.meta.changes ?? 0) === 0) {
    return json({ accepted: false, messageCode: "already_used" });
  }
  return json({
    accepted: true,
    messageCode: "accepted",
    premiumUntilUtc: premiumUntil.toISOString(),
  });
}

async function createRewardSession(request: Request, env: RuntimeEnv): Promise<Response> {
  const body = await readJson(request);
  if (!body) return json({ accepted: false, messageCode: "invalid_request" }, 400);
  const validation = await validateDeviceRequest(body, env, "mizan-reward-session-v1");
  if (validation instanceof Response) return validation;

  let key: string;
  try {
    key = await deviceKey(env, validation.deviceHash);
  } catch {
    return json({ accepted: false, messageCode: "server_not_configured" }, 503);
  }

  const now = new Date();
  const state = await rewardState(env, key, now);
  if (state.rewardPremiumUntilUtc) {
    return json({
      accepted: false,
      messageCode: "pro_active",
      rewardedViewsToday: state.rewardedViewsToday,
      premiumUntilUtc: await temporaryPremiumUntil(env, key, now),
    });
  }
  if (state.rewardedViewsToday >= REWARD_VIEWS_REQUIRED) {
    return json({
      accepted: false,
      messageCode: "daily_limit_reached",
      rewardedViewsToday: state.rewardedViewsToday,
      premiumUntilUtc: await temporaryPremiumUntil(env, key, now),
    });
  }

  const sessionId = crypto.randomUUID();
  const expiresAt = new Date(now.getTime() + REWARD_SESSION_TTL_MS);
  const insert = await env.DB.prepare(
    `INSERT INTO rewarded_sessions
      (session_id, device_key, created_at_utc, expires_at_utc)
     SELECT ?1, ?2, ?3, ?4
      WHERE NOT EXISTS (
        SELECT 1 FROM rewarded_sessions
         WHERE device_key = ?2
           AND rewarded_at_utc IS NULL
           AND expires_at_utc > ?3
      )`,
  )
    .bind(sessionId, key, now.toISOString(), expiresAt.toISOString())
    .run();

  if ((insert.meta.changes ?? 0) === 0) {
    return json({
      accepted: false,
      messageCode: "reward_in_progress",
      rewardedViewsToday: state.rewardedViewsToday,
      premiumUntilUtc: await temporaryPremiumUntil(env, key, now),
    });
  }

  return json({
    accepted: true,
    messageCode: "accepted",
    sessionId,
    rewardedViewsToday: state.rewardedViewsToday,
    premiumUntilUtc: await temporaryPremiumUntil(env, key, now),
  });
}

async function rewardSessionStatus(request: Request, env: RuntimeEnv): Promise<Response> {
  const body = await readJson(request);
  if (!body) return json({ accepted: false, messageCode: "invalid_request" }, 400);
  const sessionId = String(body.sessionId ?? "").trim().toLowerCase();
  if (!/^[0-9a-f-]{36}$/.test(sessionId)) {
    return json({ accepted: false, messageCode: "invalid_request" }, 400);
  }
  const session = await env.DB.prepare(
    `SELECT session_id, device_key, created_at_utc, expires_at_utc, rewarded_at_utc, transaction_id
       FROM rewarded_sessions WHERE session_id = ?1 LIMIT 1`,
  )
    .bind(sessionId)
    .first<RewardSessionRow>();
  if (!session) return json({ accepted: false, messageCode: "unknown_session" }, 404);
  const now = new Date();
  const state = await rewardState(env, session.device_key, now);
  return json({
    accepted: true,
    messageCode: session.rewarded_at_utc ? "reward_verified" : "reward_pending",
    sessionRewarded: Boolean(session.rewarded_at_utc),
    rewardedViewsToday: state.rewardedViewsToday,
    premiumUntilUtc: await temporaryPremiumUntil(env, session.device_key, now),
  });
}

async function syncTemporaryEntitlement(request: Request, env: RuntimeEnv): Promise<Response> {
  const body = await readJson(request);
  if (!body) return json({ accepted: false, messageCode: "invalid_request" }, 400);
  const validation = await validateDeviceRequest(body, env, "mizan-entitlement-sync-v1");
  if (validation instanceof Response) return validation;
  let key: string;
  try {
    key = await deviceKey(env, validation.deviceHash);
  } catch {
    return json({ accepted: false, messageCode: "server_not_configured" }, 503);
  }
  const now = new Date();
  const state = await rewardState(env, key, now);
  return json({
    accepted: true,
    messageCode: "synced",
    rewardedViewsToday: state.rewardedViewsToday,
    premiumUntilUtc: await temporaryPremiumUntil(env, key, now),
  });
}

async function verifierPemForKey(
  keyId: number,
  ctx: ExecutionContext,
  bypassCache = false,
): Promise<string | null> {
  const cache = caches.default;
  const cacheRequest = new Request(ADMOB_VERIFIER_KEYS_URL, { method: "GET" });
  let response = bypassCache ? undefined : await cache.match(cacheRequest);
  if (!response) {
    const network = await fetch(cacheRequest);
    if (!network.ok) throw new Error(`admob_key_server_${network.status}`);
    const cacheable = new Response(network.body, network);
    cacheable.headers.set("Cache-Control", "public, max-age=21600");
    ctx.waitUntil(cache.put(cacheRequest, cacheable.clone()));
    response = cacheable;
  }
  const payload = (await response.json()) as VerifierKeyResponse;
  const match = payload.keys?.find((candidate) => Number(candidate.keyId) === keyId);
  if (match?.pem) return match.pem;
  if (!bypassCache) return verifierPemForKey(keyId, ctx, true);
  return null;
}

async function verifyAdMobSsv(
  request: Request,
  env: RuntimeEnv,
  ctx: ExecutionContext,
): Promise<{ params: URLSearchParams; signedContent: string } | null> {
  const question = request.url.indexOf("?");
  if (question < 0) return null;
  const rawQuery = request.url.slice(question + 1);
  const signatureMarker = "&signature=";
  const signatureIndex = rawQuery.lastIndexOf(signatureMarker);
  if (signatureIndex <= 0) return null;
  const signedContent = rawQuery.slice(0, signatureIndex);
  const signatureAndKey = rawQuery.slice(signatureIndex + 1);
  if (!signatureAndKey.startsWith("signature=")) return null;
  const keyMarker = "&key_id=";
  const keyIndex = signatureAndKey.indexOf(keyMarker);
  if (keyIndex <= "signature=".length) return null;
  const rawSignature = signatureAndKey.slice("signature=".length, keyIndex);
  const rawKeyId = signatureAndKey.slice(keyIndex + keyMarker.length);
  if (!/^\d+$/.test(rawKeyId)) return null;
  const keyId = Number(rawKeyId);
  if (!Number.isSafeInteger(keyId)) return null;

  const pem = await verifierPemForKey(keyId, ctx);
  if (!pem) return null;
  let signature: Buffer;
  try {
    signature = Buffer.from(decodeURIComponent(rawSignature), "base64url");
  } catch {
    return null;
  }
  const verified = verifySignature(
    "sha256",
    Buffer.from(signedContent, "utf8"),
    pem,
    signature,
  );
  if (!verified) return null;

  const params = new URLSearchParams(rawQuery);
  const expectedAdUnit = env.EXPECTED_REWARDED_AD_UNIT_ID.trim();
  if (
    env.ENVIRONMENT === "production" &&
    (!expectedAdUnit || expectedAdUnit.startsWith("REPLACE_WITH_"))
  ) {
    throw new Error("rewarded_ad_unit_not_configured");
  }
  if (expectedAdUnit && params.get("ad_unit") !== expectedAdUnit) return null;
  return { params, signedContent };
}

async function admobRewardSsv(
  request: Request,
  env: RuntimeEnv,
  ctx: ExecutionContext,
): Promise<Response> {
  let verified: { params: URLSearchParams; signedContent: string } | null;
  try {
    verified = await verifyAdMobSsv(request, env, ctx);
  } catch {
    return json({ accepted: false, messageCode: "ssv_verifier_unavailable" }, 503);
  }
  if (!verified) return json({ accepted: false, messageCode: "invalid_ssv" }, 403);

  const sessionId = (verified.params.get("custom_data") ?? "").trim().toLowerCase();
  const transactionId = (verified.params.get("transaction_id") ?? "").trim();
  const timestampMs = Number(verified.params.get("timestamp") ?? "0");
  const adUnit = (verified.params.get("ad_unit") ?? "").trim();
  const rewardAmount = (verified.params.get("reward_amount") ?? "").trim();
  const rewardItem = (verified.params.get("reward_item") ?? "").trim();
  if (
    !/^[0-9a-f-]{36}$/.test(sessionId) ||
    transactionId.length < 8 ||
    transactionId.length > 160 ||
    !Number.isFinite(timestampMs) ||
    timestampMs <= 0 ||
    !adUnit ||
    !rewardAmount ||
    !rewardItem
  ) {
    return json({ accepted: false, messageCode: "invalid_ssv_payload" }, 400);
  }

  const session = await env.DB.prepare(
    `SELECT session_id, device_key, created_at_utc, expires_at_utc, rewarded_at_utc, transaction_id
       FROM rewarded_sessions WHERE session_id = ?1 LIMIT 1`,
  )
    .bind(sessionId)
    .first<RewardSessionRow>();
  if (!session) return json({ accepted: false, messageCode: "unknown_session" }, 404);

  const createdMs = Date.parse(session.created_at_utc);
  const expiresMs = Date.parse(session.expires_at_utc);
  if (timestampMs < createdMs - 120_000 || timestampMs > expiresMs + 120_000) {
    return json({ accepted: false, messageCode: "ssv_outside_session" }, 403);
  }

  const now = new Date();
  const today = utcDay(now);
  const premiumUntil = new Date(now.getTime() + REWARD_PREMIUM_MS).toISOString();
  const nowIso = now.toISOString();

  await env.DB.batch([
    env.DB.prepare(
      `INSERT OR IGNORE INTO rewarded_transactions
        (transaction_id, session_id, received_at_utc, ad_unit, reward_amount, reward_item)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6)`,
    ).bind(transactionId, sessionId, nowIso, adUnit, rewardAmount, rewardItem),
    env.DB.prepare(
      `UPDATE rewarded_sessions
          SET rewarded_at_utc = ?1, transaction_id = ?2
        WHERE session_id = ?3
          AND rewarded_at_utc IS NULL
          AND EXISTS (
            SELECT 1 FROM rewarded_transactions
             WHERE transaction_id = ?2 AND session_id = ?3
          )`,
    ).bind(nowIso, transactionId, sessionId),
    env.DB.prepare(
      `INSERT INTO rewarded_daily_state
        (device_key, reward_date_utc, rewarded_views, premium_until_utc, updated_at_utc)
       SELECT s.device_key, ?1, 1, NULL, ?2
         FROM rewarded_sessions s
         JOIN rewarded_transactions t ON t.transaction_id = ?3
        WHERE s.session_id = ?4
          AND s.transaction_id = ?3
          AND t.session_id = ?4
          AND t.applied_at_utc IS NULL
       ON CONFLICT(device_key) DO UPDATE SET
         reward_date_utc = excluded.reward_date_utc,
         rewarded_views = CASE
           WHEN rewarded_daily_state.reward_date_utc = excluded.reward_date_utc
             THEN MIN(3, rewarded_daily_state.rewarded_views + 1)
           ELSE 1
         END,
         premium_until_utc = CASE
           WHEN rewarded_daily_state.reward_date_utc = excluded.reward_date_utc
                AND rewarded_daily_state.rewarded_views >= 2
             THEN CASE
               WHEN rewarded_daily_state.premium_until_utc IS NOT NULL
                    AND rewarded_daily_state.premium_until_utc > ?2
                 THEN rewarded_daily_state.premium_until_utc
               ELSE ?5
             END
           WHEN rewarded_daily_state.premium_until_utc IS NOT NULL
                AND rewarded_daily_state.premium_until_utc > ?2
             THEN rewarded_daily_state.premium_until_utc
           ELSE NULL
         END,
         updated_at_utc = excluded.updated_at_utc`,
    ).bind(today, nowIso, transactionId, sessionId, premiumUntil),
    env.DB.prepare(
      `UPDATE rewarded_transactions
          SET applied_at_utc = ?1
        WHERE transaction_id = ?2
          AND session_id = ?3
          AND applied_at_utc IS NULL
          AND EXISTS (
            SELECT 1 FROM rewarded_sessions
             WHERE session_id = ?3 AND transaction_id = ?2
          )`,
    ).bind(nowIso, transactionId, sessionId),
  ]);

  return json({ accepted: true, messageCode: "reward_recorded" });
}

type ProductPurchaseV2 = {
  purchaseStateContext?: { purchaseState?: string };
  acknowledgementState?: string;
  productLineItem?: Array<{ productId?: string }>;
  purchaseCompletionTime?: string;
  orderId?: string;
};

async function verifyBilling(request: Request, env: RuntimeEnv): Promise<Response> {
  const body = await readJson(request);
  if (!body) return json({ verified: false, purchaseState: "INVALID" }, 400);
  const packageName = String(body.packageName ?? "").trim();
  const productId = String(body.productId ?? "").trim();
  const purchaseToken = String(body.purchaseToken ?? "").trim();
  if (
    packageName !== env.EXPECTED_PACKAGE_NAME ||
    productId !== env.EXPECTED_PRODUCT_ID ||
    purchaseToken.length < 16 ||
    purchaseToken.length > 4096
  ) {
    return json({ verified: false, purchaseState: "INVALID" }, 400);
  }

  try {
    const accessToken = await googleAccessToken(
      env,
      "https://www.googleapis.com/auth/androidpublisher",
    );
    const endpoint =
      `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}` +
      `/purchases/productsv2/tokens/${encodeURIComponent(purchaseToken)}`;
    const response = await fetch(endpoint, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    if (!response.ok) {
      return json({ verified: false, purchaseState: "UNVERIFIED" });
    }
    const purchase = (await response.json()) as ProductPurchaseV2;
    const state = purchase.purchaseStateContext?.purchaseState ?? "UNKNOWN";
    const productMatches =
      purchase.productLineItem?.some((item) => item.productId === productId) ?? false;
    if (state !== "PURCHASED" || !productMatches) {
      return json({ verified: false, purchaseState: state });
    }

    let acknowledgementState = purchase.acknowledgementState ?? "UNKNOWN";
    if (acknowledgementState === "ACKNOWLEDGEMENT_STATE_PENDING") {
      const acknowledgeEndpoint =
        `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}` +
        `/purchases/products/${encodeURIComponent(productId)}/tokens/${encodeURIComponent(purchaseToken)}:acknowledge`;
      const acknowledge = await fetch(acknowledgeEndpoint, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: "{}",
      });
      if (!acknowledge.ok && acknowledge.status !== 409) {
        return json({ verified: false, purchaseState: "ACKNOWLEDGEMENT_FAILED" });
      }
      acknowledgementState = "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED";
    }

    const tokenHash = await sha256(purchaseToken);
    const orderHash = purchase.orderId ? await sha256(purchase.orderId) : null;
    await env.DB.prepare(
      `INSERT INTO billing_purchases
        (purchase_token_hash, product_id, app_package, purchase_state, acknowledgement_state,
         verified_at_utc, purchase_completion_time, order_id_hash)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
       ON CONFLICT(purchase_token_hash) DO UPDATE SET
         purchase_state = excluded.purchase_state,
         acknowledgement_state = excluded.acknowledgement_state,
         verified_at_utc = excluded.verified_at_utc,
         purchase_completion_time = excluded.purchase_completion_time,
         order_id_hash = excluded.order_id_hash`,
    )
      .bind(
        tokenHash,
        productId,
        packageName,
        state,
        acknowledgementState,
        new Date().toISOString(),
        purchase.purchaseCompletionTime ?? null,
        orderHash,
      )
      .run();

    return json({
      verified: true,
      purchaseState: "PURCHASED",
      acknowledgementState,
    });
  } catch {
    return json({ verified: false, purchaseState: "SERVER_ERROR" }, 503);
  }
}

export default {
  async fetch(request: Request, env: RuntimeEnv, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/health") {
      return json({ ok: true, service: "mizan-monetization", environment: env.ENVIRONMENT });
    }
    if (request.method === "POST" && url.pathname === "/v1/promo/redeem") {
      return redeemPromo(request, env);
    }
    if (request.method === "POST" && url.pathname === "/v1/reward/session") {
      return createRewardSession(request, env);
    }
    if (request.method === "POST" && url.pathname === "/v1/reward/session/status") {
      return rewardSessionStatus(request, env);
    }
    if (request.method === "POST" && url.pathname === "/v1/entitlement/temporary/sync") {
      return syncTemporaryEntitlement(request, env);
    }
    if (request.method === "GET" && url.pathname === "/v1/reward/admob/ssv") {
      return admobRewardSsv(request, env, ctx);
    }
    if (request.method === "POST" && url.pathname === "/v1/billing/google/verify") {
      return verifyBilling(request, env);
    }
    return json({ error: "not_found" }, 404);
  },
} satisfies ExportedHandler<RuntimeEnv>;
