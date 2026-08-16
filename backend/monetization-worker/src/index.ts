interface Env {
  DB: D1Database;
  ENVIRONMENT: string;
  EXPECTED_PACKAGE_NAME: string;
  EXPECTED_PRODUCT_ID: string;
  REQUIRE_PLAY_INTEGRITY: string;
  PROMO_PEPPER: string;
  GOOGLE_SERVICE_ACCOUNT_EMAIL: string;
  GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY: string;
}

type JsonObject = Record<string, unknown>;

type GoogleTokenCache = {
  token: string;
  expiresAtMs: number;
  scope: string;
};

let googleTokenCache: GoogleTokenCache | null = null;

const PROMOS: Record<string, number> = {
  ESMANUR: 7,
  LEFFERION: 3,
};

const encoder = new TextEncoder();

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

async function googleAccessToken(env: Env, scope: string): Promise<string> {
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
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
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

async function expectedIntegrityRequestHash(deviceHash: string, code: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    encoder.encode(`mizan-promo-v1|${deviceHash}|${code}`),
  );
  return base64Url(new Uint8Array(digest));
}

async function verifyPlayIntegrity(
  env: Env,
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

async function redeemPromo(request: Request, env: Env): Promise<Response> {
  const body = await readJson(request);
  if (!body) return json({ accepted: false, messageCode: "invalid_request" }, 400);

  const deviceHash = String(body.deviceHash ?? "").trim().toLowerCase();
  const code = String(body.code ?? "").trim().toUpperCase();
  const packageName = String(body.packageName ?? "").trim();
  const platform = String(body.platform ?? "").trim().toLowerCase();
  const integrityToken = String(body.integrityToken ?? "").trim();

  if (
    !/^[a-f0-9]{64}$/.test(deviceHash) ||
    packageName !== env.EXPECTED_PACKAGE_NAME ||
    platform !== "android"
  ) {
    return json({ accepted: false, messageCode: "invalid_request" }, 400);
  }

  const days = PROMOS[code];
  if (!days) return json({ accepted: false, messageCode: "invalid_code" }, 200);
  if (!env.PROMO_PEPPER || env.PROMO_PEPPER.length < 32) {
    return json({ accepted: false, messageCode: "server_not_configured" }, 503);
  }

  if (env.REQUIRE_PLAY_INTEGRITY.toLowerCase() === "true") {
    try {
      const expectedHash = await expectedIntegrityRequestHash(deviceHash, code);
      if (!(await verifyPlayIntegrity(env, integrityToken, expectedHash))) {
        return json({ accepted: false, messageCode: "integrity_failed" }, 403);
      }
    } catch {
      return json({ accepted: false, messageCode: "integrity_unavailable" }, 503);
    }
  }

  const deviceKey = await hmacHex(env.PROMO_PEPPER, `device|${deviceHash}`);
  const codeKey = await hmacHex(env.PROMO_PEPPER, `code|${code}`);
  const redemptionKey = await hmacHex(env.PROMO_PEPPER, `redeem|${deviceHash}|${code}`);
  const now = new Date();
  const premiumUntil = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

  const result = await env.DB.prepare(
    `INSERT OR IGNORE INTO promo_redemptions
      (redemption_key, device_key, code_key, redeemed_at_utc, premium_until_utc, app_package, platform)
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`,
  )
    .bind(
      redemptionKey,
      deviceKey,
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

type ProductPurchaseV2 = {
  purchaseStateContext?: { purchaseState?: string };
  acknowledgementState?: string;
  productLineItem?: Array<{ productId?: string }>;
  purchaseCompletionTime?: string;
  orderId?: string;
};

async function verifyBilling(request: Request, env: Env): Promise<Response> {
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
      return json({ verified: false, purchaseState: "UNVERIFIED" }, 200);
    }
    const purchase = (await response.json()) as ProductPurchaseV2;
    const state = purchase.purchaseStateContext?.purchaseState ?? "UNKNOWN";
    const productMatches =
      purchase.productLineItem?.some((item) => item.productId === productId) ?? false;
    if (state !== "PURCHASED" || !productMatches) {
      return json({ verified: false, purchaseState: state }, 200);
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
        return json({ verified: false, purchaseState: "ACKNOWLEDGEMENT_FAILED" }, 200);
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
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/health") {
      return json({ ok: true, service: "mizan-monetization", environment: env.ENVIRONMENT });
    }
    if (request.method === "POST" && url.pathname === "/v1/promo/redeem") {
      return redeemPromo(request, env);
    }
    if (request.method === "POST" && url.pathname === "/v1/billing/google/verify") {
      return verifyBilling(request, env);
    }
    return json({ error: "not_found" }, 404);
  },
} satisfies ExportedHandler<Env>;
