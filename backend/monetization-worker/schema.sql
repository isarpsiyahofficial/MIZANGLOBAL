CREATE TABLE IF NOT EXISTS promo_redemptions (
  redemption_key TEXT PRIMARY KEY NOT NULL,
  device_key TEXT NOT NULL,
  code_key TEXT NOT NULL,
  redeemed_at_utc TEXT NOT NULL,
  premium_until_utc TEXT NOT NULL,
  app_package TEXT NOT NULL,
  platform TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_promo_device
  ON promo_redemptions(device_key);

CREATE TABLE IF NOT EXISTS billing_purchases (
  purchase_token_hash TEXT PRIMARY KEY NOT NULL,
  product_id TEXT NOT NULL,
  app_package TEXT NOT NULL,
  purchase_state TEXT NOT NULL,
  acknowledgement_state TEXT NOT NULL,
  verified_at_utc TEXT NOT NULL,
  purchase_completion_time TEXT,
  order_id_hash TEXT
);
