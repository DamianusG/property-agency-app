-- =====================================
-- PROPERTY AGENCY LISTING MANAGEMENT
-- PostgreSQL Schema v1
-- =====================================

-- =====================================
-- USERS
-- =====================================

CREATE TABLE users (
    id_user BIGSERIAL PRIMARY KEY,

    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,

    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),

    role VARCHAR(20) NOT NULL
        CHECK (role IN ('Admin', 'Agent')),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- CUSTOMERS
-- =====================================

CREATE TABLE customers (
    id_customer BIGSERIAL PRIMARY KEY,

    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(20),
    address TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- PROPERTY TYPES
-- =====================================

CREATE TABLE property_types (
    id_property_type BIGSERIAL PRIMARY KEY,

    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- LISTINGS
-- =====================================

CREATE TABLE listings (
    id_listing BIGSERIAL PRIMARY KEY,

    created_by_user_id BIGINT NOT NULL,

    id_property_type BIGINT NOT NULL,

    title VARCHAR(150) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,

    price NUMERIC(18,2) NOT NULL,

    status VARCHAR(20) NOT NULL
        CHECK (status IN ('Available', 'Reserved', 'Sold', 'Inactive')),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_listing_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id_user),

    CONSTRAINT fk_listing_property_type
        FOREIGN KEY (id_property_type)
        REFERENCES property_types(id_property_type)
);

-- =====================================
-- TRANSACTION ITEMS
-- SERVICE CATALOG
-- =====================================

CREATE TABLE transaction_items (
    id_transaction_item BIGSERIAL PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,

    default_price NUMERIC(18,2) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- TRANSACTIONS
-- =====================================

CREATE TABLE transactions (
    id_transaction BIGSERIAL PRIMARY KEY,

    id_listing BIGINT NOT NULL,
    id_customer BIGINT NOT NULL,

    created_by_user_id BIGINT NOT NULL,

    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    payment_status VARCHAR(20) NOT NULL
        CHECK (payment_status IN ('Pending', 'Paid', 'Cancelled')),

    notes TEXT,

    total_amount NUMERIC(18,2) NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transaction_listing
        FOREIGN KEY (id_listing)
        REFERENCES listings(id_listing),

    CONSTRAINT fk_transaction_customer
        FOREIGN KEY (id_customer)
        REFERENCES customers(id_customer),

    CONSTRAINT fk_transaction_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id_user)
);

-- =====================================
-- TRANSACTION DETAILS
-- =====================================

CREATE TABLE transaction_details (
    id_transaction_detail BIGSERIAL PRIMARY KEY,

    id_transaction BIGINT NOT NULL,
    id_transaction_item BIGINT NOT NULL,

    quantity INTEGER NOT NULL CHECK (quantity > 0),

    price_at_transaction NUMERIC(18,2) NOT NULL,
    subtotal NUMERIC(18,2) NOT NULL,

    CONSTRAINT fk_detail_transaction
        FOREIGN KEY (id_transaction)
        REFERENCES transactions(id_transaction)
        ON DELETE CASCADE,

    CONSTRAINT fk_detail_transaction_item
        FOREIGN KEY (id_transaction_item)
        REFERENCES transaction_items(id_transaction_item)
);

-- =====================================
-- INDEXES
-- =====================================

CREATE INDEX idx_listing_status
ON listings(status);

CREATE INDEX idx_listing_property_type
ON listings(id_property_type);

CREATE INDEX idx_transaction_status
ON transactions(payment_status);

CREATE INDEX idx_transaction_customer
ON transactions(id_customer);

CREATE INDEX idx_transaction_listing
ON transactions(id_listing);