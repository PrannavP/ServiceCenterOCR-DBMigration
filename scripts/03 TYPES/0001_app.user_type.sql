-- ============================================================
-- Type: app.user_type
-- Description: User types enum
-- ============================================================

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'app')) THEN
        CREATE TYPE app.user_type AS ENUM ('admin', 'front_office');
    END IF;
END$$;
