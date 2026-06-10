-- ============================================================
-- Procedure: app.sp_create_user
-- Description: Creates a new user with validation
-- ============================================================

CREATE OR REPLACE PROCEDURE app.sp_create_user(
    p_username      VARCHAR,
    p_email         VARCHAR,
    p_password_hash VARCHAR,
    p_full_name     VARCHAR DEFAULT NULL,
    p_phone         VARCHAR DEFAULT NULL,
    p_created_by    INT DEFAULT 0
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate email format (basic check)
    IF p_email NOT LIKE '%_@_%.__%' THEN
        RAISE EXCEPTION 'Invalid email format: %', p_email;
    END IF;

    -- Validate username length
    IF LENGTH(p_username) < 3 THEN
        RAISE EXCEPTION 'Username must be at least 3 characters';
    END IF;

    -- Insert the user
    INSERT INTO app.tbl_user (username, email, password_hash, full_name, phone, created_by, updated_by)
    VALUES (p_username, p_email, p_password_hash, p_full_name, p_phone, p_created_by, p_created_by);
END;
$$;