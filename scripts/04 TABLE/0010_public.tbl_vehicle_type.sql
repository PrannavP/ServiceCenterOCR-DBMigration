CREATE TABLE IF NOT EXISTS public.tbl_vehicle_type(
    uid UUID DEFAULT uuid_generate_v4(),
    id SERIAL,

    name VARCHAR(100) NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_by      int not null DEFAULT 0,
    updated_by      int not null DEFAULT 0
);