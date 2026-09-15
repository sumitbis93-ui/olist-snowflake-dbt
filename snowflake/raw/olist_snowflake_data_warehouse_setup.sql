-- ============================================================
-- OLIST SNOWFLAKE DATA WAREHOUSE SETUP
-- AWS S3 + Snowflake + dbt
-- ============================================================


-- ============================================================
-- STEP 1: ADMIN ROLE
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- STEP 2: CREATE TRANSFORM ROLE
-- ============================================================

CREATE ROLE IF NOT EXISTS TRANSFORM;

GRANT ROLE TRANSFORM
TO ROLE ACCOUNTADMIN;


-- ============================================================
-- STEP 3: CREATE DBT WAREHOUSE
-- ============================================================

CREATE WAREHOUSE IF NOT EXISTS OLIST_WH
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

GRANT USAGE, OPERATE
ON WAREHOUSE OLIST_WH
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 4: CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS OLIST_DB;

GRANT USAGE
ON DATABASE OLIST_DB
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 5: CREATE SCHEMAS
-- ============================================================

CREATE SCHEMA IF NOT EXISTS OLIST_DB.RAW;

CREATE SCHEMA IF NOT EXISTS OLIST_DB.STAGING;

CREATE SCHEMA IF NOT EXISTS OLIST_DB.INTERMEDIATE;

CREATE SCHEMA IF NOT EXISTS OLIST_DB.MARTS;


-- ============================================================
-- STEP 6: GRANT SCHEMA USAGE
-- ============================================================

GRANT USAGE
ON SCHEMA OLIST_DB.RAW
TO ROLE TRANSFORM;

GRANT USAGE
ON SCHEMA OLIST_DB.STAGING
TO ROLE TRANSFORM;

GRANT USAGE
ON SCHEMA OLIST_DB.INTERMEDIATE
TO ROLE TRANSFORM;

GRANT USAGE
ON SCHEMA OLIST_DB.MARTS
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 7: RAW TABLE READ PERMISSIONS
-- ============================================================

GRANT SELECT
ON ALL TABLES IN SCHEMA OLIST_DB.RAW
TO ROLE TRANSFORM;

GRANT SELECT
ON FUTURE TABLES IN SCHEMA OLIST_DB.RAW
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 8: DBT CREATE PERMISSIONS
-- ============================================================
GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA OLIST_DB.RAW
TO ROLE TRANSFORM;

GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA OLIST_DB.STAGING
TO ROLE TRANSFORM;

GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA OLIST_DB.INTERMEDIATE
TO ROLE TRANSFORM;

GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA OLIST_DB.MARTS
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 9: EXISTING TABLE PERMISSIONS
-- ============================================================

GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA OLIST_DB.STAGING
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA OLIST_DB.INTERMEDIATE
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA OLIST_DB.MARTS
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 10: FUTURE TABLE PERMISSIONS
-- ============================================================

GRANT ALL PRIVILEGES
ON FUTURE TABLES IN SCHEMA OLIST_DB.STAGING
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON FUTURE TABLES IN SCHEMA OLIST_DB.INTERMEDIATE
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON FUTURE TABLES IN SCHEMA OLIST_DB.MARTS
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 11: EXISTING VIEW PERMISSIONS
-- ============================================================

GRANT ALL PRIVILEGES
ON ALL VIEWS IN SCHEMA OLIST_DB.STAGING
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON ALL VIEWS IN SCHEMA OLIST_DB.INTERMEDIATE
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON ALL VIEWS IN SCHEMA OLIST_DB.MARTS
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 12: FUTURE VIEW PERMISSIONS
-- ============================================================

GRANT ALL PRIVILEGES
ON FUTURE VIEWS IN SCHEMA OLIST_DB.STAGING
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON FUTURE VIEWS IN SCHEMA OLIST_DB.INTERMEDIATE
TO ROLE TRANSFORM;

GRANT ALL PRIVILEGES
ON FUTURE VIEWS IN SCHEMA OLIST_DB.MARTS
TO ROLE TRANSFORM;


-- ============================================================
-- STEP 13: CREATE DBT USER
-- ============================================================

CREATE USER IF NOT EXISTS DBT
    PASSWORD = 'OlistDbt#2026!Snow'
    LOGIN_NAME = 'DBT'
    MUST_CHANGE_PASSWORD = FALSE
    DEFAULT_WAREHOUSE = 'OLIST_WH'
    DEFAULT_ROLE = 'TRANSFORM'
    DEFAULT_NAMESPACE = 'OLIST_DB.STAGING'
    COMMENT = 'DBT user used for Olist data transformation';


-- ============================================================
-- STEP 14: SET USER TYPE
-- ============================================================

ALTER USER DBT
SET TYPE = LEGACY_SERVICE;


-- ============================================================
-- STEP 15: ASSIGN TRANSFORM ROLE TO DBT USER
-- ============================================================

GRANT ROLE TRANSFORM
TO USER DBT;


-- ============================================================
-- STEP 16: CREATE CSV FILE FORMAT
-- ============================================================

USE DATABASE OLIST_DB;

USE SCHEMA RAW;

CREATE OR REPLACE FILE FORMAT OLIST_CSV_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    EMPTY_FIELD_AS_NULL = TRUE
    NULL_IF = ('NULL', 'null', '');


-- ============================================================
-- STEP 17: CREATE S3 EXTERNAL STAGE
-- ============================================================

CREATE OR REPLACE STAGE OLIST_S3_STAGE
    URL = 's3://olist-de-s3-bucket/raw/olist/'
    CREDENTIALS = (
        AWS_KEY_ID = '<DUMMY_KEY_ID>'
        AWS_SECRET_KEY = '<DUMMY_KEY>'
    )
    FILE_FORMAT = OLIST_CSV_FORMAT;


-- ============================================================
-- STEP 18: GRANT STAGE ACCESS
-- ============================================================

GRANT USAGE
ON STAGE OLIST_DB.RAW.OLIST_S3_STAGE
TO ROLE TRANSFORM;


