CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ohlq_location_id TEXT,
    slug TEXT UNIQUE,
    name TEXT NOT NULL,
    street_1 TEXT,
    street_2 TEXT,
    city TEXT,
    state TEXT DEFAULT 'OH',
    postal_code TEXT,
    phone TEXT,
    hours_json JSONB,
    chain_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    geom GEOGRAPHY(POINT, 4326),
    source_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_locations_city ON locations(city);
CREATE INDEX IF NOT EXISTS idx_locations_chain_name ON locations(chain_name);
CREATE INDEX IF NOT EXISTS idx_locations_geom ON locations USING GIST(geom);
CREATE UNIQUE INDEX IF NOT EXISTS idx_locations_ohlq_location_id_unique
ON locations(ohlq_location_id)
WHERE ohlq_location_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ohlq_product_id TEXT,
    slug TEXT UNIQUE,
    name TEXT NOT NULL,
    category TEXT,
    subcategory TEXT,
    size_ml INTEGER,
    proof NUMERIC(6,2),
    abv NUMERIC(6,4),
    price NUMERIC(10,2),
    is_allocated_guess BOOLEAN NOT NULL DEFAULT FALSE,
    is_limit_one_official BOOLEAN NOT NULL DEFAULT FALSE,
    aliases TEXT[] NOT NULL DEFAULT '{}',
    source_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_products_ohlq_product_id_unique
ON products(ohlq_product_id)
WHERE ohlq_product_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_aliases_gin ON products USING GIN(aliases);

CREATE TABLE IF NOT EXISTS release_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type TEXT NOT NULL CHECK (source_type IN ('ohlq_event_page','ohlq_product_page','manual')),
    source_url TEXT NOT NULL,
    external_id TEXT,
    title TEXT NOT NULL,
    notes TEXT,
    event_starts_at TIMESTAMPTZ,
    event_ends_at TIMESTAMPTZ,
    sales_begin_at TIMESTAMPTZ,
    region_scope TEXT,
    raw_payload JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (source_type, source_url)
);

CREATE INDEX IF NOT EXISTS idx_release_events_start ON release_events(event_starts_at);
CREATE INDEX IF NOT EXISTS idx_release_events_sales_begin ON release_events(sales_begin_at);

CREATE TABLE IF NOT EXISTS release_event_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    release_event_id UUID NOT NULL REFERENCES release_events(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (release_event_id, location_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_release_event_locations_location ON release_event_locations(location_id);
CREATE INDEX IF NOT EXISTS idx_release_event_locations_product ON release_event_locations(product_id);

CREATE TABLE IF NOT EXISTS tracked_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform TEXT NOT NULL CHECK (platform IN ('x','reddit')),
    handle TEXT NOT NULL,
    display_name TEXT,
    priority INTEGER NOT NULL DEFAULT 100,
    reliability_score NUMERIC(4,3) NOT NULL DEFAULT 0.700,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (platform, handle)
);

CREATE TABLE IF NOT EXISTS signals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type TEXT NOT NULL CHECK (source_type IN (
        'ohlq_event_page',
        'ohlq_inventory',
        'ohlq_product_page',
        'reddit_post',
        'reddit_comment',
        'x_post',
        'manual'
    )),
    source_url TEXT NOT NULL,
    source_external_id TEXT,
    author_handle TEXT,
    author_account_id UUID REFERENCES tracked_accounts(id) ON DELETE SET NULL,
    observed_at TIMESTAMPTZ NOT NULL,
    captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    bottle_alias_raw TEXT,
    location_text_raw TEXT,
    raw_text TEXT,
    raw_payload JSONB NOT NULL DEFAULT '{}'::JSONB,
    extracted_json JSONB NOT NULL DEFAULT '{}'::JSONB,
    firsthand_claim BOOLEAN,
    confidence_base NUMERIC(4,3) NOT NULL DEFAULT 0.000,
    confidence_adjusted NUMERIC(4,3) NOT NULL DEFAULT 0.000,
    verification_status TEXT NOT NULL DEFAULT 'unverified' CHECK (verification_status IN ('unverified','corroborated','official','rejected','review_required')),
    dedupe_key TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (source_type, source_url, source_external_id)
);

CREATE INDEX IF NOT EXISTS idx_signals_observed_at ON signals(observed_at DESC);
CREATE INDEX IF NOT EXISTS idx_signals_location_product_time ON signals(location_id, product_id, observed_at DESC);
CREATE INDEX IF NOT EXISTS idx_signals_verification_status ON signals(verification_status);
CREATE INDEX IF NOT EXISTS idx_signals_extracted_json_gin ON signals USING GIN(extracted_json);

CREATE TABLE IF NOT EXISTS location_product_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('none','official_upcoming','official_seen','community_signal','corroborated','stale','sold_out_likely')),
    current_confidence NUMERIC(4,3) NOT NULL DEFAULT 0.000,
    latest_official_signal_id UUID REFERENCES signals(id) ON DELETE SET NULL,
    latest_community_signal_id UUID REFERENCES signals(id) ON DELETE SET NULL,
    latest_signal_at TIMESTAMPTZ,
    next_release_at TIMESTAMPTZ,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    explanation TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (location_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_location_product_state_status ON location_product_state(status);
CREATE INDEX IF NOT EXISTS idx_location_product_state_confidence ON location_product_state(current_confidence DESC);
CREATE INDEX IF NOT EXISTS idx_location_product_state_next_release ON location_product_state(next_release_at);

CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    location_id UUID REFERENCES locations(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    city TEXT,
    radius_miles INTEGER,
    min_confidence NUMERIC(4,3) NOT NULL DEFAULT 0.650,
    notify_via TEXT NOT NULL DEFAULT 'email' CHECK (notify_via IN ('email','webhook','push')),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_active ON alerts(active);

CREATE TABLE IF NOT EXISTS admin_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_id UUID NOT NULL REFERENCES signals(id) ON DELETE CASCADE,
    reviewer_id TEXT NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('approve','reject','edit')),
    notes TEXT,
    edited_extracted_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_reviews_signal ON admin_reviews(signal_id);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_locations_updated_at ON locations;
CREATE TRIGGER trg_locations_updated_at
BEFORE UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_release_events_updated_at ON release_events;
CREATE TRIGGER trg_release_events_updated_at
BEFORE UPDATE ON release_events
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_tracked_accounts_updated_at ON tracked_accounts;
CREATE TRIGGER trg_tracked_accounts_updated_at
BEFORE UPDATE ON tracked_accounts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_signals_updated_at ON signals;
CREATE TRIGGER trg_signals_updated_at
BEFORE UPDATE ON signals
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_alerts_updated_at ON alerts;
CREATE TRIGGER trg_alerts_updated_at
BEFORE UPDATE ON alerts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE FUNCTION sync_location_geom()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.longitude IS NOT NULL AND NEW.latitude IS NOT NULL THEN
        NEW.geom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_locations_sync_geom ON locations;
CREATE TRIGGER trg_locations_sync_geom
BEFORE INSERT OR UPDATE OF latitude, longitude ON locations
FOR EACH ROW EXECUTE FUNCTION sync_location_geom();
