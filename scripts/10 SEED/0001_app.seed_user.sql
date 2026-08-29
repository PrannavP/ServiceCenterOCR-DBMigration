-- ============================================================
-- Seed: A user
-- Description: Inserts a user
-- ============================================================

INSERT INTO app.tbl_user (username, email, password_hash, full_name, phone, is_active, is_deleted, created_by, updated_by)
VALUES 
('admin', 'admin@admin.com', '$2b$10$A3QZ4rVYLiVPfneWWFXwRePf4QHBGzGSBJraB6C5dut81ZakVC6mK', 'Admin Admin', '1234567890', true, false, 0, 0)