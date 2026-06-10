CREATE TABLE IF NOT EXISTS app.tbl_jobcard_detail (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    
    jobcard_id INT NOT NULL,
    jobcard_uid UUID NOT NULL,
    parts_id INT NOT NULL,
    quantity INT NOT NULL,
    rate NUMERIC(10,2) NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    remarks TEXT,

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

-- log table
CREATE TABLE app.tbl_jobcard_detail_log AS
SELECT * FROM app.tbl_jobcard_detail;