CREATE OR REPLACE VIEW inv.vw_part_current_stock AS
SELECT
    p.id AS part_id,
    p.name AS part_name,

    -- Current stock = total received - total used
    COALESCE(
        (
            SELECT SUM(COALESCE(rd.quantity, 0))
            FROM inv.tbl_receipt_detail rd
            WHERE rd.part_id = p.id and rd.is_active and p.is_active
        ), 0
    )
    -
    COALESCE(
        (
            SELECT SUM(COALESCE(jd.quantity, 0))
            FROM app.tbl_jobcard_detail jd
            WHERE jd.part_id = p.id and jd.is_active and p.is_active
        ), 0
    ) AS available_qty,

    -- Rate from the latest receipt of this part
    (
        SELECT rd.rate
        FROM inv.tbl_receipt_detail rd
        WHERE rd.part_id = p.id and rd.is_active
        ORDER BY rd.created_at DESC
        LIMIT 1
    ) AS rate

FROM inv.tbl_part p;