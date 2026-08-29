CREATE TABLE IF NOT EXISTS public.tbl_vehicle(
    uid UUID DEFAULT uuid_generate_v4(),
    id SERIAL,

    name VARCHAR(100) NOT NULL,
    vehicle_type_id INT NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);