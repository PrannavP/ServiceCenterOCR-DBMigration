CREATE TABLE IF NOT EXISTS app.tbl_tax (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,

    name        VARCHAR(250) NOT NULL,
    code        varchar(10) NOT NULL,
    factor      NUMERIC(10,2) NOT NULL,

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

CREATE TABLE app.tbl_tax_log AS
SELECT * FROM app.tbl_tax;