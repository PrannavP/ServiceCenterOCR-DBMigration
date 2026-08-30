ALTER TABLE app.tbl_jobcard
ADD COLUMN is_settled BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE app.tbl_jobcard_log
ADD COLUMN is_settled BOOLEAN NOT NULL DEFAULT false;