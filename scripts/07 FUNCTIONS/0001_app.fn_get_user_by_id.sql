

CREATE OR REPLACE FUNCTION app.fn_get_user_by_id(p_user_id INT)
RETURNS TABLE (
    user_id         INT,
    username        VARCHAR,
    email           VARCHAR,
    full_name       VARCHAR,
    phone           VARCHAR,
    is_active       BOOLEAN,
    created_at      TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id as user_id,
        u.username,
        u.email,
        u.full_name,
        u.phone,
        u.is_active,
        u.created_at
    FROM app.tbl_user u
    WHERE u.user_id = p_user_id;
END;
$$;