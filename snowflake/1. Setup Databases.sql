// Setup Databases for Staging, Production

// --------------------------------------------------------------------------------
// Create database for managing stage objects, file formats, scheduled tasks
CREATE OR REPLACE DATABASE manage_db;

USE manage_db;
CREATE OR REPLACE SCHEMA external_stages;
CREATE OR REPLACE SCHEMA file_formats;
CREATE OR REPLACE SCHEMA procedures;

// Create CSV file format
CREATE OR REPLACE FILE FORMAT manage_db.file_formats.csv_fileformat
    TYPE = csv
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL','null')
    EMPTY_FIELD_AS_NULL = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_BLANK_LINES = TRUE;
    
// Create JSON file format
CREATE OR REPLACE FILE FORMAT manage_db.file_formats.jsonformat
    TYPE = json;
    
// Create external stage
CREATE OR REPLACE STAGE manage_db.external_stages.aws_stage
    URL = 's3://snowflaketechtest/'
    STORAGE_INTEGRATION = s3_int;

LIST @manage_db.external_stages.aws_stage PATTERN = '.*.json';
LIST @manage_db.external_stages.aws_stage PATTERN = '.*.csv';

// --------------------------------------------------------------------------------
// Create staging database and schema
CREATE OR REPLACE DATABASE staging_db;
CREATE OR REPLACE SCHEMA dbo;

// Create customers table
CREATE OR REPLACE TABLE staging_db.dbo.customer(
    customer_id	VARCHAR(30),
    loyalty_score INT );
    
// Create products table    
CREATE OR REPLACE TABLE staging_db.dbo.product(
    product_id VARCHAR(30),
    product_description VARCHAR(30),
    product_category VARCHAR(30) );

// Create transactions json table
CREATE OR REPLACE TABLE staging_db.dbo.transaction_json(
    json_str variant );

// Create transactions table
CREATE OR REPLACE TABLE staging_db.dbo.transaction(
    customer_id VARCHAR(30),
    date_of_purchase DATE,
    product_id VARCHAR(30),
    price INT );
    
