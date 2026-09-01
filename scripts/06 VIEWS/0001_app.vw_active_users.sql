

CREATE OR REPLACE VIEW app.vw_active_users AS
SELECT 
    u.id,
    u.username,
    u.email,
    u.full_name,
    u.phone,
    u.created_at
FROM app.tbl_user u
WHERE u.is_active = true;