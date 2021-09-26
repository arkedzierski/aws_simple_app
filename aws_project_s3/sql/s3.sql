BEGIN;
CREATE DATABASE s3;
CREATE USER ken;
ALTER DATABASE s3 OWNER TO ken;
GRANT rds_iam TO ken;
--
-- Create model Files
--
CREATE TABLE "s3_files" ("id" bigserial NOT NULL PRIMARY KEY, "uploaded_at" timestamp with time zone NOT NULL, "upload" varchar(100) NOT NULL);
COMMIT;