-- ============================================================
-- Seed: This seed is for seeing the current tax for the service center billing
-- ============================================================

INSERT INTO app.tbl_tax (name, code, factor, is_active, is_deleted, created_by, updated_by)
VALUES 
('13% VAT', 'VAT', 13.00, true, false, 0, 0)