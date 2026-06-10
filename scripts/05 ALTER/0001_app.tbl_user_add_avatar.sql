-- ============================================================
-- Alter: app.tbl_user - Add avatar column
-- Description: Adds avatar_url column to user table
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'app' AND table_name = 'tbl_user' AND column_name = 'avatar_url'
    ) THEN
        ALTER TABLE app.tbl_user ADD COLUMN avatar_url VARCHAR(500);
    END IF;
END$$;
