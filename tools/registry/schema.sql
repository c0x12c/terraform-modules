-- D1 schema for registry download stats.
-- One row per (module_key, version); count is incremented atomically on each
-- tarball serve. Apply once after creating the DB:
--   wrangler d1 create c0x12c-tf-registry-stats
--   wrangler d1 execute c0x12c-tf-registry-stats --remote --file schema.sql
CREATE TABLE IF NOT EXISTS downloads (
  module_key TEXT    NOT NULL,            -- e.g. "c0x12c/rds/aws"
  version    TEXT    NOT NULL,            -- e.g. "0.6.5" (no leading v)
  count      INTEGER NOT NULL DEFAULT 0,
  last_at    TEXT,                        -- ISO-ish UTC of most recent download
  PRIMARY KEY (module_key, version)
);

-- Aggregate-by-module reads (landing catalog totals) hit module_key alone.
CREATE INDEX IF NOT EXISTS idx_downloads_module ON downloads (module_key);
