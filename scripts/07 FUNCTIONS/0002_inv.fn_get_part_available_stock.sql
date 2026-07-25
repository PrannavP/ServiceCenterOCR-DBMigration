CREATE OR REPLACE FUNCTION inv.fn_get_part_available_stock()
RETURNS TABLE
(
    receipt_id INT,
    receipt_date      TIMESTAMP,
    part_id           INT,
    part_name         VARCHAR,
    rate              NUMERIC(10,2),
    available_qty     INT
)
LANGUAGE sql
AS
$$
SELECT
    r.id AS receipt_id,
    r.transaction_date AS receipt_date,
    rd.part_id,
    p.name AS part_name,
    rd.rate,
    rd.quantity AS available_qty
FROM inv.tbl_receipt_detail rd
INNER JOIN inv.tbl_receipt r
    ON r.id = rd.receipt_id
INNER JOIN inv.tbl_part p
    ON p.id = rd.part_id
WHERE rd.is_active = TRUE
  AND rd.is_deleted = FALSE
  AND r.is_active = TRUE
  AND r.is_deleted = FALSE
  AND p.is_active = TRUE
  AND p.is_deleted = FALSE
ORDER BY
    rd.part_id,
    r.transaction_date,
    rd.id;
$$;