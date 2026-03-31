-- ═══════════════════════════════════════════════════════════════════
-- RapidX Hub Network Migration
-- Creates: hubs table with national/regional/local tiers across India
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS hubs (
    hub_id       SERIAL PRIMARY KEY,
    hub_name     VARCHAR(100) NOT NULL,
    hub_type     VARCHAR(20)  NOT NULL CHECK (hub_type IN ('national', 'regional', 'local')),
    region       VARCHAR(20)  NOT NULL CHECK (region IN ('north', 'west', 'east', 'south', 'central')),
    lat          DOUBLE PRECISION NOT NULL,
    lng          DOUBLE PRECISION NOT NULL,
    is_active    BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── NATIONAL HUBS ────────────────────────────────────────────────────────────
INSERT INTO hubs (hub_name, hub_type, region, lat, lng) VALUES
('Delhi',     'national', 'north',   28.56348467449849, 77.152755),
('Mumbai',    'national', 'west',    19.0760,           72.8777),
('Kolkata',   'national', 'east',    22.5726,           88.3639),
('Bengaluru', 'national', 'south',   12.9716,           77.5946),
('Nagpur',    'national', 'central', 21.1458,           79.0882);

-- ─── REGIONAL HUBS ────────────────────────────────────────────────────────────
INSERT INTO hubs (hub_name, hub_type, region, lat, lng) VALUES
-- North
('Delhi',       'regional', 'north',   28.56348467449849, 77.152755),
('Chandigarh',  'regional', 'north',   30.7333,           76.7794),
('Jaipur',      'regional', 'north',   26.9124,           75.7873),
('Lucknow',     'regional', 'north',   26.8467,           80.9462),
-- West
('Ahmedabad',   'regional', 'west',    23.0225,           72.5714),
('Mumbai',      'regional', 'west',    19.0760,           72.8777),
('Pune',        'regional', 'west',    18.5204,           73.8567),
('Nagpur',      'regional', 'west',    21.1458,           79.0882),
-- East
('Kolkata',     'regional', 'east',    22.5726,           88.3639),
('Bhubaneswar', 'regional', 'east',    20.2961,           85.8245),
('Patna',       'regional', 'east',    25.5941,           85.1376),
('Ranchi',      'regional', 'east',    23.3441,           85.3096),
-- South
('Bengaluru',   'regional', 'south',   12.9716,           77.5946),
('Hyderabad',   'regional', 'south',   17.3850,           78.4867),
('Chennai',     'regional', 'south',   13.0827,           80.2707),
('Kochi',       'regional', 'south',    9.9312,           76.2673),
-- Central
('Sagar',       'regional', 'central', 23.8388,           78.7378),
('Vidisha',     'regional', 'central', 23.5239,           77.8133),
('Hoshangabad', 'regional', 'central', 22.7533,           77.7246),
('Betul',       'regional', 'central', 21.9014,           77.8961);

-- ─── LOCAL HUBS ───────────────────────────────────────────────────────────────
INSERT INTO hubs (hub_name, hub_type, region, lat, lng) VALUES
-- North
('Delhi',          'local', 'north', 28.56348467449849, 77.152755),
('Gurugram',       'local', 'north', 28.4595,           77.0266),
('Noida',          'local', 'north', 28.5355,           77.3910),
('Ghaziabad',      'local', 'north', 28.6692,           77.4538),
('Chandigarh',     'local', 'north', 30.7333,           76.7794),
('Amritsar',       'local', 'north', 31.6340,           74.8723),
('Ludhiana',       'local', 'north', 30.9010,           75.8573),
('Jalandhar',      'local', 'north', 31.3260,           75.5762),
('Jaipur',         'local', 'north', 26.9124,           75.7873),
('Jodhpur',        'local', 'north', 26.2389,           73.0243),
('Udaipur',        'local', 'north', 24.5854,           73.7125),
('Kota',           'local', 'north', 25.2138,           75.8648),
('Lucknow',        'local', 'north', 26.8467,           80.9462),
('Kanpur',         'local', 'north', 26.4499,           80.3319),
('Varanasi',       'local', 'north', 25.3176,           82.9739),
('Agra',           'local', 'north', 27.1767,           78.0081),
('Meerut',         'local', 'north', 28.9845,           77.7064),
('Prayagraj',      'local', 'north', 25.4358,           81.8463),
('Dehradun',       'local', 'north', 30.3165,           78.0322),
('Shimla',         'local', 'north', 31.1048,           77.1734),
-- West
('Ahmedabad',      'local', 'west',  23.0225,           72.5714),
('Surat',          'local', 'west',  21.1702,           72.8311),
('Vadodara',       'local', 'west',  22.3072,           73.1812),
('Rajkot',         'local', 'west',  22.3039,           70.8022),
('Mumbai',         'local', 'west',  19.0760,           72.8777),
('Thane',          'local', 'west',  19.2183,           72.9781),
('Pune',           'local', 'west',  18.5204,           73.8567),
('Nashik',         'local', 'west',  19.9975,           73.7898),
('Nagpur',         'local', 'west',  21.1458,           79.0882),
('Aurangabad',     'local', 'west',  19.8762,           75.3433),
('Kolhapur',       'local', 'west',  16.7050,           74.2433),
('Panaji',         'local', 'west',  15.4909,           73.8278),
-- East
('Kolkata',        'local', 'east',  22.5726,           88.3639),
('Asansol',        'local', 'east',  23.6739,           86.9524),
('Siliguri',       'local', 'east',  26.7271,           88.3953),
('Patna',          'local', 'east',  25.5941,           85.1376),
('Gaya',           'local', 'east',  24.7914,           85.0002),
('Ranchi',         'local', 'east',  23.3441,           85.3096),
('Jamshedpur',     'local', 'east',  22.8046,           86.2029),
('Bhubaneswar',    'local', 'east',  20.2961,           85.8245),
('Cuttack',        'local', 'east',  20.4625,           85.8830),
-- South
('Bengaluru',      'local', 'south', 12.9716,           77.5946),
('Mysuru',         'local', 'south', 12.2958,           76.6394),
('Mangalore',      'local', 'south', 12.9141,           74.8560),
('Hyderabad',      'local', 'south', 17.3850,           78.4867),
('Vijayawada',     'local', 'south', 16.5062,           80.6480),
('Visakhapatnam',  'local', 'south', 17.6868,           83.2185),
('Chennai',        'local', 'south', 13.0827,           80.2707),
('Coimbatore',     'local', 'south', 11.0168,           76.9558),
('Madurai',        'local', 'south',  9.9252,           78.1198),
('Kochi',          'local', 'south',  9.9312,           76.2673),
('Thiruvananthapuram', 'local', 'south', 8.5241,        76.9366),
-- Central
('Bhopal',         'local', 'central', 23.2599,         77.4126),
('Indore',         'local', 'central', 22.7196,         75.8577),
('Gwalior',        'local', 'central', 26.2183,         78.1828),
('Jabalpur',       'local', 'central', 23.1815,         79.9864),
('Raipur',         'local', 'central', 21.2514,         81.6296);

-- Index for fast geo queries
CREATE INDEX IF NOT EXISTS idx_hubs_type ON hubs(hub_type);
CREATE INDEX IF NOT EXISTS idx_hubs_region ON hubs(region);
CREATE INDEX IF NOT EXISTS idx_hubs_coords ON hubs(lat, lng);
