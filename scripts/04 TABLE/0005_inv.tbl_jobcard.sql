CREATE TABLE IF NOT EXISTS app.tbl_jobcard (
    uid         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id          SERIAL,
    
    customer_name VARCHAR(100) NOT NULL DEFAULT '',
    customer_address VARCHAR(100) NOT NULL,
    static_vehicle_type_id INT NOT NULL, -- scooter / bike
    static_vehicle_id INT NOT NULL, -- ntorq, raider, ronin...
    vehicle_registration_number VARCHAR(50) NOT NULL,
    odometer_reading TEXT NOT NULL,
    fuel_quantity VARCHAR(100) NOT NULL,
    chasis_number VARCHAR(100) NOT NULL,
    contact_number varchar(50) NOT NULL,
    problems JSONB DEFAULT '{}'::jsonb,
    -- later add status column enum (completed, payment_left, closed)
    remarks TEXT,

    is_active       BOOLEAN DEFAULT TRUE,
    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);

-- log table
CREATE TABLE app.tbl_jobcard_log AS
SELECT * FROM app.tbl_jobcard;