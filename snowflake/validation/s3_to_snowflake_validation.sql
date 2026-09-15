-- =============================================================================
-- Verify the S3 Files After Running COPY: TEST S3 -> SNOWFLAKE CONNECTION
-- =============================================================================

USE ROLE TRANSFORM;
USE WAREHOUSE OLIST_WH;

USE DATABASE OLIST_DB;
USE SCHEMA RAW;

DESC STAGE OLIST_DB.RAW.OLIST_S3_STAGE;
/* Value = ["s3://olist-de-s3-bucket/raw/olist/"] */

LIST @OLIST_DB.RAW.OLIST_S3_STAGE;
/* Value = ["s3://olist-de-s3-bucket/raw/olist/customers/olist_customers_dataset.csv"] */

/* So, new path = ["OLIST_S3_STAGE/customers/olist_customers_dataset.csv"] */
