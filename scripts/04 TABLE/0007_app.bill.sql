CREATE TABLE IF NOT EXISTS app.tbl_bill (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    
    jobcard_id INT NOT NULL,
    jobcard_uid UUID NOT NULL,
    customer_name VARCHAR(100) NOT NULL DEFAULT '',
    customer_address VARCHAR(100) NOT NULL,
    static_vehicle_type_id INT NOT NULL, -- scooter / bike
    static_vehicle_id INT NOT NULL, -- ntorq, raider, ronin...
    vehicle_number VARCHAR(50) NOT NULL,
    payment_method VARCHAR(100) NOT NULL,
    print_count INT DEFAULT 0,

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

-- log table
CREATE TABLE app.tbl_bill_log AS
SELECT * FROM app.tbl_bill;