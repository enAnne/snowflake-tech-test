// Setup stored procedures for loading from S3 buckets
// 1. Customers
// 2. Products
// 3. Transactions

USE manage_db.procedures;

// --------------------------------------------------------------------------------
// Customers staging table - full truncate reload
CREATE OR REPLACE PROCEDURE customer_refresh_proc()
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        snowflake.execute({ sqlText: `TRUNCATE TABLE staging_db.dbo.customer;` });
        
        snowflake.execute({ sqlText: `COPY INTO staging_db.dbo.customer
                                        FROM @manage_db.external_stages.aws_stage
                                        FILE_FORMAT = manage_db.file_formats.csv_fileformat
                                        FILES = ('customers.csv')
                                        ON_ERROR = CONTINUE;` });
        
        snowflake.execute({ sqlText: `DELETE FROM staging_db.dbo.customer
                                        WHERE customer_id IS NULL` });
                
        return "Customers refreshed.";
        $$;
        
DESCRIBE PROCEDURE customer_refresh_proc();

// --------------------------------------------------------------------------------
// Products staging table - full truncate reload
CREATE OR REPLACE PROCEDURE product_refresh_proc()
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        snowflake.execute({ sqlText: `TRUNCATE TABLE staging_db.dbo.product;` });
        
        snowflake.execute({ sqlText: `COPY INTO staging_db.dbo.product
                                        FROM @manage_db.external_stages.aws_stage
                                        FILE_FORMAT = (type = csv field_delimiter=',' skip_header=1)
                                        FILES = ('products.csv')
                                        ON_ERROR = CONTINUE;` });
        
        snowflake.execute({ sqlText: `DELETE FROM staging_db.dbo.product
                                        WHERE product_id IS NULL` });
                
        return "Products refreshed.";
        $$;

DESCRIBE PROCEDURE product_refresh_proc();

// --------------------------------------------------------------------------------
// Transactions staging table - insert without duplicates
CREATE OR REPLACE PROCEDURE transaction_insert_proc()
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        snowflake.execute({ sqlText: `COPY INTO staging_db.dbo.transaction_json
                                        FROM @MANAGE_DB.external_stages.aws_stage 
                                        FILE_FORMAT = manage_db.file_formats.jsonformat
                                        PATTERN = '.*.transactions.json';` });
        
        return "Transactions inserted.";
        $$;

DESCRIBE PROCEDURE transaction_insert_proc();

// --------------------------------------------------------------------------------

SHOW PROCEDURES;

// CALL customer_refresh_proc()
// CALL product_refresh_proc()
// CALL transaction_insert_proc()


