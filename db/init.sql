-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create daily_summary table
CREATE TABLE IF NOT EXISTS daily_summary (
    date DATE PRIMARY KEY,
    total_sales DECIMAL(10, 2) NOT NULL
);

-- Insert sample data into customers
INSERT INTO customers (name, email) VALUES
    ('Alice Smith', 'alice@example.com'),
    ('Bob Johnson', 'bob@example.com')
ON CONFLICT (email) DO NOTHING;

-- Insert sample data into menu_items
INSERT INTO menu_items (name, price) VALUES
    ('Burger', 12.50),
    ('Fries', 3.00),
    ('Soda', 2.00)
ON CONFLICT (name) DO NOTHING;

-- Insert sample data into orders
INSERT INTO orders (customer_id, total)
SELECT
    c.id, 17.50 -- Burger (12.50) + Fries (3.00) + Soda (2.00)
FROM
    customers c
WHERE
    c.email = 'alice@example.com';

INSERT INTO orders (customer_id, total)
SELECT
    c.id, 14.50 -- Burger (12.50) + Soda (2.00)
FROM
    customers c
WHERE
    c.email = 'bob@example.com';
