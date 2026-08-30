CREATE TABLE IF NOT EXISTS app.tbl_settlement(
    uid UUID DEFAULT uuid_generate_v4(),
    id SERIAL,

    transaction_date DATE NOT NULL DEFAULT NOW(),
    job_card_id VARCHAR(100) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    card_number VARCHAR(50),
    card_expiry_date DATE,
    name_on_card VARCHAR (100),
    settled_amount NUMERIC(10,2) NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

CREATE TABLE app.tbl_settlement_log AS
SELECT * FROM app.tbl_settlement;