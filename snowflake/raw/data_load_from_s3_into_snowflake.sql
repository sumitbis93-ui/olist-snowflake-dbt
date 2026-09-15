USE ROLE TRANSFORM;
USE WAREHOUSE OLIST_WH;

USE DATABASE OLIST_DB;
USE SCHEMA RAW;

-- ============================================================
-- Load raw_customers
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_customers (
    customer_id VARCHAR,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR,
    customer_state VARCHAR
);

COPY INTO OLIST_DB.RAW.raw_customers
FROM '@OLIST_S3_STAGE/customers/olist_customers_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_orders
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_orders (
    order_id VARCHAR,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP_NTZ,
    order_approved_at TIMESTAMP_NTZ,
    order_delivered_carrier_date TIMESTAMP_NTZ,
    order_delivered_customer_date TIMESTAMP_NTZ,
    order_estimated_delivery_date TIMESTAMP_NTZ
);

COPY INTO OLIST_DB.RAW.raw_orders
FROM '@OLIST_S3_STAGE/orders/olist_orders_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_order_items
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_order_items (
    order_id VARCHAR,
    order_item_id INTEGER,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP_NTZ,
    price FLOAT,
    freight_value FLOAT
);

COPY INTO OLIST_DB.RAW.raw_order_items
FROM '@OLIST_S3_STAGE/order_items/olist_order_items_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_order_payments
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_order_payments (
    order_id VARCHAR,
    payment_sequential INTEGER,
    payment_type VARCHAR,
    payment_installments INTEGER,
    payment_value FLOAT
);

COPY INTO OLIST_DB.RAW.raw_order_payments
FROM '@OLIST_S3_STAGE/order_payments/olist_order_payments_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_order_reviews
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_order_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INTEGER,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP_NTZ,
    review_answer_timestamp TIMESTAMP_NTZ
);

COPY INTO OLIST_DB.RAW.raw_order_reviews
FROM '@OLIST_S3_STAGE/order_reviews/olist_order_reviews_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_products
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_products (
    product_id VARCHAR,
    product_category_name VARCHAR,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

COPY INTO OLIST_DB.RAW.raw_products
FROM '@OLIST_S3_STAGE/products/olist_products_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_sellers
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_sellers (
    seller_id VARCHAR,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR,
    seller_state VARCHAR
);

COPY INTO OLIST_DB.RAW.raw_sellers
FROM '@OLIST_S3_STAGE/sellers/olist_sellers_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_geolocation
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);

COPY INTO OLIST_DB.RAW.raw_geolocation
FROM '@OLIST_S3_STAGE/geolocation/olist_geolocation_dataset.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);


-- ============================================================
-- Load raw_product_category_translation
-- ============================================================

CREATE OR REPLACE TABLE OLIST_DB.RAW.raw_product_category_translation (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);

COPY INTO OLIST_DB.RAW.raw_product_category_translation
FROM '@OLIST_S3_STAGE/product_category_name_translation/product_category_name_translation.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);
