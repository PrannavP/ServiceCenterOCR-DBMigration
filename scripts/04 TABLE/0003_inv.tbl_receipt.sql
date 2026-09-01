CREATE TABLE IF NOT EXISTS inv.tbl_receipt (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    
    transaction_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    remarks TEXT,
    number varchar(100),

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

CREATE TABLE inv.tbl_receipt_log AS
SELECT * FROM inv.tbl_receipt;