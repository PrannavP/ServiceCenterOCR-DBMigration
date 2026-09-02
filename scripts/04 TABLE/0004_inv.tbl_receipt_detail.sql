CREATE TABLE IF NOT EXISTS inv.tbl_receipt_detail (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    
    receipt_id INT NOT NULL,
    receipt_uid UUID NOT NULL,
    part_id INT NOT NULL,
    quantity INT NOT NULL,
    rate NUMERIC(10,2) NOT NULL,
    total NUMERIC (10,2) NOT NULL,

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

CREATE TABLE inv.tbl_receipt_detail_log AS
SELECT * FROM inv.tbl_receipt_detail;