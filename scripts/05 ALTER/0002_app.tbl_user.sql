ALTER TABLE app.tbl_user
ADD COLUMN user_type app.user_type NOT NULL DEFAULT 'front_office';

ALTER TABLE app.tbl_user_log
ADD COLUMN user_type app.user_type NOT NULL DEFAULT 'front_office';