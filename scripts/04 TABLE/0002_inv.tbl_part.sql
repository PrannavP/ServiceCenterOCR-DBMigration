CREATE TABLE IF NOT EXISTS inv.tbl_part (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    name        VARCHAR(250) NOT NULL,
    part_number VARCHAR(100) NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

CREATE TABLE inv.tbl_part_log AS
SELECT * FROM inv.tbl_part;