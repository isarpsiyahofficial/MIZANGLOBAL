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

CREATE TABLE IF NOT EXISTS rewarded_sessions (
  session_id TEXT PRIMARY KEY NOT NULL,
  device_key TEXT NOT NULL,
  created_at_utc TEXT NOT NULL,
  expires_at_utc TEXT NOT NULL,
  rewarded_at_utc TEXT,
  transaction_id TEXT UNIQUE
);

CREATE INDEX IF NOT EXISTS idx_rewarded_sessions_device
  ON rewarded_sessions(device_key);

CREATE TABLE IF NOT EXISTS rewarded_daily_state (
  device_key TEXT PRIMARY KEY NOT NULL,
  reward_date_utc TEXT NOT NULL,
  rewarded_views INTEGER NOT NULL DEFAULT 0 CHECK (rewarded_views BETWEEN 0 AND 3),
  premium_until_utc TEXT,
  updated_at_utc TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS rewarded_transactions (
  transaction_id TEXT PRIMARY KEY NOT NULL,
  session_id TEXT NOT NULL,
  received_at_utc TEXT NOT NULL,
  ad_unit TEXT NOT NULL,
  reward_amount TEXT NOT NULL,
  reward_item TEXT NOT NULL,
  FOREIGN KEY(session_id) REFERENCES rewarded_sessions(session_id)
);
