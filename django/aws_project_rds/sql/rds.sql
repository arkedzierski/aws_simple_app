BEGIN;
CREATE DATABASE ec2;
ALTER DATABASE ec2 OWNER TO ken;
--
-- Create model Images
--
CREATE TABLE "rds_images" ("id" bigserial NOT NULL PRIMARY KEY, "name" varchar(200) NOT NULL, "pub_date" timestamp with time zone NOT NULL);
COMMIT;
