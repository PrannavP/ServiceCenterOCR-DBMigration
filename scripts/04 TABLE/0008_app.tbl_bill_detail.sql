CREATE TABLE IF NOT EXISTS app.tbl_bill_detail (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    
    bill_id INT NOT NULL,
    bill_uid UUID NOT NULL,
    
    item_name TEXT NOT NULL,
    quantity INT NOT NULL,
    rate NUMERIC(10,2) NOT NULL,
    total NUMERIC(10,2) NOT NULL,

    tax_percentage INT NOT NULL,
    tax_amount NUMERIC(10,2) NOT NULL,

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

CREATE TABLE app.tbl_bill_detail_log AS
SELECT * FROM app.tbl_bill_detail;