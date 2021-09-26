BEGIN;
--
-- Create model Files
--
CREATE TABLE "s3_files" ("id" bigserial NOT NULL PRIMARY KEY, "uploaded_at" timestamp with time zone NOT NULL, "upload" varchar(100) NOT NULL);
COMMIT;