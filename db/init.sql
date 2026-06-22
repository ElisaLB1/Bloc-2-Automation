-- ============================================================
-- OPERATIONAL SCHEMA (tables sources)
-- ============================================================

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    certification VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL,
    phone       VARCHAR(30),
    city        VARCHAR(100),
    region      VARCHAR(100),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    product_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id  UUID NOT NULL REFERENCES suppliers(supplier_id),
    name         VARCHAR(255) NOT NULL,
    category     VARCHAR(100),
    price        NUMERIC(10, 2) NOT NULL,
    is_sustainable BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS orders (
    order_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(customer_id),
    order_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(50) DEFAULT 'pending',
    total_amount NUMERIC(10, 2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id   UUID NOT NULL REFERENCES orders(order_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL
);

-- ============================================================
-- ANALYTICS SCHEMA (star schema)
-- ============================================================

CREATE TABLE IF NOT EXISTS dim_date (
    date_id  DATE PRIMARY KEY,
    day      INTEGER,
    month    INTEGER,
    quarter  INTEGER,
    year     INTEGER,
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id UUID PRIMARY KEY,
    full_name   VARCHAR(255),
    email       VARCHAR(255),
    city        VARCHAR(100),
    region      VARCHAR(100),
    created_at  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id    UUID PRIMARY KEY,
    name          VARCHAR(255),
    category      VARCHAR(100),
    supplier_name VARCHAR(255),
    is_sustainable BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id   UUID PRIMARY KEY,
    name          VARCHAR(255),
    region        VARCHAR(100),
    certification VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS fact_order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id      UUID,
    customer_id   UUID REFERENCES dim_customer(customer_id),
    product_id    UUID REFERENCES dim_product(product_id),
    supplier_id   UUID REFERENCES dim_supplier(supplier_id),
    date_id       DATE REFERENCES dim_date(date_id),
    quantity      INTEGER,
    unit_price    NUMERIC(10, 2),
    total         NUMERIC(10, 2)
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO suppliers (supplier_id, name, contact_email, certification) VALUES
    ('a1b2c3d4-0000-0000-0000-000000000001', 'GreenFarm Co.', 'contact@greenfarm.io', 'Bio EU'),
    ('a1b2c3d4-0000-0000-0000-000000000002', 'EcoRoots', 'hello@ecoroots.fr', 'Label Rouge')
ON CONFLICT DO NOTHING;

INSERT INTO customers (customer_id, first_name, last_name, email, city, region) VALUES
    ('b1b2c3d4-0000-0000-0000-000000000001', 'Alice', 'Martin', 'alice@example.com', 'Paris', 'Île-de-France'),
    ('b1b2c3d4-0000-0000-0000-000000000002', 'Bob', 'Dupont', 'bob@example.com', 'Lyon', 'Auvergne-Rhône-Alpes')
ON CONFLICT DO NOTHING;

INSERT INTO products (product_id, supplier_id, name, category, price, is_sustainable) VALUES
    ('c1b2c3d4-0000-0000-0000-000000000001', 'a1b2c3d4-0000-0000-0000-000000000001', 'Salade bio', 'Légumes', 2.50, TRUE),
    ('c1b2c3d4-0000-0000-0000-000000000002', 'a1b2c3d4-0000-0000-0000-000000000001', 'Carottes bio', 'Légumes', 1.80, TRUE),
    ('c1b2c3d4-0000-0000-0000-000000000003', 'a1b2c3d4-0000-0000-0000-000000000002', 'Poulet fermier', 'Viandes', 12.00, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO orders (order_id, customer_id, status, total_amount) VALUES
    ('d1b2c3d4-0000-0000-0000-000000000001', 'b1b2c3d4-0000-0000-0000-000000000001', 'completed', 16.30),
    ('d1b2c3d4-0000-0000-0000-000000000002', 'b1b2c3d4-0000-0000-0000-000000000002', 'completed', 13.80)
ON CONFLICT DO NOTHING;

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    ('d1b2c3d4-0000-0000-0000-000000000001', 'c1b2c3d4-0000-0000-0000-000000000001', 2, 2.50),
    ('d1b2c3d4-0000-0000-0000-000000000001', 'c1b2c3d4-0000-0000-0000-000000000003', 1, 12.00),
    ('d1b2c3d4-0000-0000-0000-000000000002', 'c1b2c3d4-0000-0000-0000-000000000002', 2, 1.80),
    ('d1b2c3d4-0000-0000-0000-000000000002', 'c1b2c3d4-0000-0000-0000-000000000003', 1, 12.00)
ON CONFLICT DO NOTHING;
